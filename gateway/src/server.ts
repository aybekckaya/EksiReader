import { timingSafeEqual } from "node:crypto";

const DEFAULT_UPSTREAM_BASE_URL = "https://eksisozluk.com";
const DEFAULT_TIMEOUT_MS = 10_000;
const DEFAULT_MAX_BODY_BYTES = 2 * 1024 * 1024;
const MIN_PAGE = 1;
const MAX_TRENDING_PAGE = 20;
const MAX_CONTENT_PAGE = 1_000;
const MAX_SLUG_LENGTH = 200;
const MAX_QUERY_LENGTH = 100;

export type FetchImplementation = (
  input: string | URL | Request,
  init?: RequestInit,
) => Promise<Response>;

export interface GatewayOptions {
  token: string;
  fetchImplementation?: FetchImplementation;
  upstreamBaseUrl?: string;
  timeoutMs?: number;
  maxBodyBytes?: number;
}

interface UpstreamRequest {
  url: URL;
  redirect: RequestRedirect;
  headers?: HeadersInit;
}

class GatewayInputError extends Error {
  constructor(
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "GatewayInputError";
  }
}

function jsonResponse(body: unknown, status: number): Response {
  return Response.json(body, {
    status,
    headers: {
      "Cache-Control": "no-store",
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ success: false, error: { code, message } }, status);
}

function tokenMatches(authorization: string | null, expectedToken: string): boolean {
  if (authorization === null || !authorization.startsWith("Bearer ")) {
    return false;
  }
  const receivedToken = authorization.slice("Bearer ".length);
  const received = Buffer.from(receivedToken);
  const expected = Buffer.from(expectedToken);
  return received.length === expected.length && timingSafeEqual(received, expected);
}

function positiveInteger(
  value: string | null,
  field: string,
  maximum: number,
  defaultValue?: number,
): number {
  if (value === null && defaultValue !== undefined) {
    return defaultValue;
  }
  if (value === null || !/^\d+$/u.test(value)) {
    throw new GatewayInputError("INVALID_PARAMETER", `${field} geçersiz.`);
  }
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < MIN_PAGE || parsed > maximum) {
    throw new GatewayInputError("INVALID_PARAMETER", `${field} geçersiz.`);
  }
  return parsed;
}

function safeText(
  value: string | null,
  field: string,
  maximumLength: number,
): string {
  const normalized = value?.trim() ?? "";
  if (
    normalized === ""
    || normalized.length > maximumLength
    || /[\u0000-\u001f\u007f]/u.test(normalized)
  ) {
    throw new GatewayInputError("INVALID_PARAMETER", `${field} geçersiz.`);
  }
  return normalized;
}

function safeSlug(value: string | null, field: string): string {
  const slug = safeText(value, field, MAX_SLUG_LENGTH);
  if (slug === "." || slug === ".." || /[\\/]/u.test(slug)) {
    throw new GatewayInputError("INVALID_PARAMETER", `${field} geçersiz.`);
  }
  return slug;
}

function buildUpstreamRequest(requestUrl: URL, upstreamBaseUrl: string): UpstreamRequest {
  switch (requestUrl.pathname) {
    case "/source/trending": {
      const page = positiveInteger(
        requestUrl.searchParams.get("page"),
        "page",
        MAX_TRENDING_PAGE,
        1,
      );
      const url = new URL("/basliklar/gundem", upstreamBaseUrl);
      if (page > 1) {
        url.searchParams.set("p", String(page));
      }
      return { url, redirect: "follow" };
    }
    case "/source/topic": {
      const slug = safeSlug(requestUrl.searchParams.get("slug"), "slug");
      const id = positiveInteger(requestUrl.searchParams.get("id"), "id", Number.MAX_SAFE_INTEGER);
      const page = positiveInteger(
        requestUrl.searchParams.get("page"),
        "page",
        MAX_CONTENT_PAGE,
        1,
      );
      const sort = requestUrl.searchParams.get("sort") ?? "popular";
      if (sort !== "popular") {
        throw new GatewayInputError("INVALID_PARAMETER", "sort geçersiz.");
      }
      const url = new URL(`/${encodeURIComponent(slug)}--${id}`, upstreamBaseUrl);
      url.searchParams.set("a", sort);
      if (page > 1) {
        url.searchParams.set("p", String(page));
      }
      return { url, redirect: "follow" };
    }
    case "/source/profile": {
      const slug = safeSlug(requestUrl.searchParams.get("slug"), "slug");
      return {
        url: new URL(`/biri/${encodeURIComponent(slug)}`, upstreamBaseUrl),
        redirect: "follow",
      };
    }
    case "/source/author-entries": {
      const nick = safeText(requestUrl.searchParams.get("nick"), "nick", MAX_SLUG_LENGTH);
      const page = positiveInteger(
        requestUrl.searchParams.get("page"),
        "page",
        MAX_CONTENT_PAGE,
        1,
      );
      const url = new URL("/son-entryleri", upstreamBaseUrl);
      url.searchParams.set("nick", nick);
      url.searchParams.set("p", String(page));
      return {
        url,
        redirect: "follow",
        headers: { "X-Requested-With": "XMLHttpRequest" },
      };
    }
    case "/source/resolve": {
      const query = safeText(requestUrl.searchParams.get("q"), "q", MAX_QUERY_LENGTH);
      const url = new URL("/", upstreamBaseUrl);
      url.searchParams.set("q", query);
      return { url, redirect: "manual" };
    }
    default:
      throw new GatewayInputError("NOT_FOUND", "Gateway endpoint bulunamadı.");
  }
}

function upstreamResponseHeaders(response: Response): Headers {
  const headers = new Headers({ "Cache-Control": "no-store" });
  for (const name of ["content-type", "location", "cf-mitigated"] as const) {
    const value = response.headers.get(name);
    if (value !== null) {
      headers.set(name, value);
    }
  }
  return headers;
}

export function createGatewayHandler(options: GatewayOptions) {
  if (options.token.length < 32) {
    throw new Error("GATEWAY_TOKEN en az 32 karakter olmalıdır.");
  }

  const fetchImplementation = options.fetchImplementation ?? fetch;
  const upstreamBaseUrl = options.upstreamBaseUrl ?? DEFAULT_UPSTREAM_BASE_URL;
  const timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
  const maxBodyBytes = options.maxBodyBytes ?? DEFAULT_MAX_BODY_BYTES;

  return async function handleGatewayRequest(request: Request): Promise<Response> {
    const requestUrl = new URL(request.url);
    if (request.method === "GET" && requestUrl.pathname === "/health") {
      return jsonResponse({ status: "ok", service: "eksi-reader-fetch-gateway" }, 200);
    }
    if (request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Yalnızca GET desteklenir.", 405);
    }
    if (!tokenMatches(request.headers.get("authorization"), options.token)) {
      return errorResponse("UNAUTHORIZED", "Gateway yetkilendirmesi başarısız.", 401);
    }

    let upstreamRequest: UpstreamRequest;
    try {
      upstreamRequest = buildUpstreamRequest(requestUrl, upstreamBaseUrl);
    } catch (error) {
      if (error instanceof GatewayInputError) {
        const status = error.code === "NOT_FOUND" ? 404 : 400;
        return errorResponse(error.code, error.message, status);
      }
      throw error;
    }

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    let upstreamResponse: Response;
    try {
      upstreamResponse = await fetchImplementation(upstreamRequest.url, {
        headers: {
          Accept: "text/html,application/xhtml+xml",
          "Accept-Language": "tr-TR,tr;q=0.9",
          "User-Agent": "EksiReaderGateway/1.0 (public read-only API)",
          ...upstreamRequest.headers,
        },
        redirect: upstreamRequest.redirect,
        signal: controller.signal,
      });
    } catch (error) {
      const timedOut = error instanceof DOMException && error.name === "AbortError";
      return errorResponse(
        timedOut ? "UPSTREAM_TIMEOUT" : "UPSTREAM_FETCH_FAILED",
        timedOut ? "Kaynak isteği zaman aşımına uğradı." : "Kaynak isteği başarısız.",
        timedOut ? 504 : 502,
      );
    } finally {
      clearTimeout(timeout);
    }

    const contentLength = Number(upstreamResponse.headers.get("content-length") ?? "0");
    if (Number.isFinite(contentLength) && contentLength > maxBodyBytes) {
      return errorResponse("UPSTREAM_RESPONSE_TOO_LARGE", "Kaynak response çok büyük.", 502);
    }

    const body = new Uint8Array(await upstreamResponse.arrayBuffer());
    if (body.byteLength > maxBodyBytes) {
      return errorResponse("UPSTREAM_RESPONSE_TOO_LARGE", "Kaynak response çok büyük.", 502);
    }
    const bodylessStatus = upstreamResponse.status === 204
      || upstreamResponse.status === 205
      || upstreamResponse.status === 304;
    return new Response(bodylessStatus ? null : body, {
      status: upstreamResponse.status,
      headers: upstreamResponseHeaders(upstreamResponse),
    });
  };
}
