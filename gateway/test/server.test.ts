import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  createGatewayHandler,
  type FetchImplementation,
} from "../src/server.js";

const TOKEN = "test-token-that-is-at-least-thirty-two-characters";

function authorizedRequest(path: string): Request {
  return new Request(`https://gateway.test${path}`, {
    headers: { Authorization: `Bearer ${TOKEN}` },
  });
}

function gatewayWith(fetchImplementation: FetchImplementation) {
  return createGatewayHandler({
    token: TOKEN,
    fetchImplementation,
    upstreamBaseUrl: "https://eksi.test",
  });
}

describe("fetch gateway", () => {
  it("health endpoint'ini auth olmadan sunar", async () => {
    const handler = gatewayWith(async () => new Response("unused"));
    const response = await handler(new Request("https://gateway.test/health"));

    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      status: "ok",
      service: "eksi-reader-fetch-gateway",
    });
  });

  it("source endpointlerinde bearer token zorunlu tutar", async () => {
    const handler = gatewayWith(async () => new Response("unused"));
    const response = await handler(new Request("https://gateway.test/source/trending?page=1"));

    assert.equal(response.status, 401);
    assert.equal((await response.json()).error.code, "UNAUTHORIZED");
  });

  it("trending page'i allowlist URL'ine map eder", async () => {
    let calledUrl = "";
    const handler = gatewayWith(async (input) => {
      calledUrl = String(input);
      return new Response("<html>ok</html>", {
        headers: { "Content-Type": "text/html" },
      });
    });

    const response = await handler(authorizedRequest("/source/trending?page=2"));

    assert.equal(response.status, 200);
    assert.equal(calledUrl, "https://eksi.test/basliklar/gundem?p=2");
    assert.equal(await response.text(), "<html>ok</html>");
  });

  it("topic parametrelerini validate edip source URL oluşturur", async () => {
    let calledUrl = "";
    const handler = gatewayWith(async (input) => {
      calledUrl = String(input);
      return new Response("topic", { headers: { "Content-Type": "text/html" } });
    });

    await handler(authorizedRequest(
      "/source/topic?slug=ornek-konu&id=42&page=3&sort=popular",
    ));

    assert.equal(calledUrl, "https://eksi.test/ornek-konu--42?a=popular&p=3");
  });

  it("profile slug'ını güvenli path segment olarak encode eder", async () => {
    let calledUrl = "";
    const handler = gatewayWith(async (input) => {
      calledUrl = String(input);
      return new Response("profile", { headers: { "Content-Type": "text/html" } });
    });

    await handler(authorizedRequest("/source/profile?slug=sosyopatiz%20elhamdurillah"));

    assert.equal(calledUrl, "https://eksi.test/biri/sosyopatiz%20elhamdurillah");
  });

  it("author entries isteğine AJAX header ekler", async () => {
    let requestedWith: string | null = null;
    let calledUrl = "";
    const handler = gatewayWith(async (input, init) => {
      calledUrl = String(input);
      requestedWith = new Headers(init?.headers).get("X-Requested-With");
      return new Response("entries", { headers: { "Content-Type": "text/html" } });
    });

    await handler(authorizedRequest("/source/author-entries?nick=sakarninja&page=1"));

    assert.equal(calledUrl, "https://eksi.test/son-entryleri?nick=sakarninja&p=1");
    assert.equal(requestedWith, "XMLHttpRequest");
  });

  it("resolve redirect'ini takip etmeden Location ile geçirir", async () => {
    let redirect: RequestRedirect | undefined;
    const handler = gatewayWith(async (_input, init) => {
      redirect = init?.redirect;
      return new Response(null, {
        status: 302,
        headers: { Location: "/ornek-konu--42" },
      });
    });

    const response = await handler(authorizedRequest("/source/resolve?q=ornek%20konu"));

    assert.equal(redirect, "manual");
    assert.equal(response.status, 302);
    assert.equal(response.headers.get("location"), "/ornek-konu--42");
  });

  it("challenge status, header ve HTML body'yi değiştirmeden geçirir", async () => {
    const handler = gatewayWith(async () => new Response(
      "<html><title>Just a moment...</title></html>",
      {
        status: 403,
        headers: {
          "Content-Type": "text/html",
          "cf-mitigated": "challenge",
          "Set-Cookie": "secret=cookie",
        },
      },
    ));

    const response = await handler(authorizedRequest("/source/profile?slug=sakarninja"));

    assert.equal(response.status, 403);
    assert.equal(response.headers.get("cf-mitigated"), "challenge");
    assert.equal(response.headers.get("set-cookie"), null);
    assert.match(await response.text(), /Just a moment/u);
  });

  it("serbest URL proxy'si sunmaz", async () => {
    let fetchCount = 0;
    const handler = gatewayWith(async () => {
      fetchCount += 1;
      return new Response("unused");
    });

    const response = await handler(authorizedRequest(
      "/source?url=https%3A%2F%2Fexample.com",
    ));

    assert.equal(response.status, 404);
    assert.equal(fetchCount, 0);
  });

  it("geçersiz page değerini upstream fetch öncesinde reddeder", async () => {
    let fetchCount = 0;
    const handler = gatewayWith(async () => {
      fetchCount += 1;
      return new Response("unused");
    });

    const response = await handler(authorizedRequest("/source/trending?page=0"));

    assert.equal(response.status, 400);
    assert.equal(fetchCount, 0);
  });

  it("response boyut limitini uygular", async () => {
    const handler = createGatewayHandler({
      token: TOKEN,
      upstreamBaseUrl: "https://eksi.test",
      maxBodyBytes: 4,
      fetchImplementation: async () => new Response("12345", {
        headers: { "Content-Type": "text/html" },
      }),
    });

    const response = await handler(authorizedRequest("/source/trending?page=1"));

    assert.equal(response.status, 502);
    assert.equal((await response.json()).error.code, "UPSTREAM_RESPONSE_TOO_LARGE");
  });
});
