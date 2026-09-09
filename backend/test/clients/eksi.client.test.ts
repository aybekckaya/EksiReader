import { describe, expect, it, vi } from "vitest";
import { EksiClient } from "../../src/clients/eksi.client";
import {
  AuthorEntriesFetchError,
  AuthorFetchError,
  AuthorNotFoundError,
  AuthorSourceChallengeError,
  SearchResolveError,
  SearchResolveNotFoundError,
  SearchResolveUnavailableError,
  TopicFetchError,
  TrendingFetchError,
} from "../../src/errors/app-error";

function mockFetch(response: Response): typeof fetch {
  return vi.fn<typeof fetch>().mockResolvedValue(response);
}

describe("EksiClient", () => {
  it("200 HTML response döndürür ve doğru URL/header'ları kullanır", async () => {
    const fetchMock = mockFetch(new Response("<html>ok</html>", {
      status: 200,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    }));
    const client = new EksiClient(fetchMock);

    await expect(client.fetchTrendingPage(2)).resolves.toBe("<html>ok</html>");
    const [url, init] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    expect(String(url)).toBe("https://eksisozluk.com/basliklar/gundem?p=2");
    expect(new Headers(init?.headers).get("Accept-Language")).toBe("tr-TR,tr;q=0.9");
  });

  it.each([403, 429, 500])("HTTP %i için fetch hatası verir", async (status) => {
    const client = new EksiClient(mockFetch(new Response("no", {
      status,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchTrendingPage(1)).rejects.toBeInstanceOf(TrendingFetchError);
  });

  it("yanlış content-type için fetch hatası verir", async () => {
    const client = new EksiClient(mockFetch(Response.json({ ok: true })));
    await expect(client.fetchTrendingPage(1)).rejects.toBeInstanceOf(TrendingFetchError);
  });

  it("timeout sırasında request'i abort eder", async () => {
    const hangingFetch: typeof fetch = (_input, init) => new Promise((_resolve, reject) => {
      init?.signal?.addEventListener("abort", () => reject(new DOMException("Aborted", "AbortError")));
    });
    const client = new EksiClient(hangingFetch, 1);
    await expect(client.fetchTrendingPage(1)).rejects.toBeInstanceOf(TrendingFetchError);
  });

  it("topic sayfası için slug, id, sort ve page ile tek HTML isteği oluşturur", async () => {
    const fetchMock = mockFetch(new Response("<html>topic</html>", {
      status: 200,
      headers: { "Content-Type": "text/html" },
    }));
    const client = new EksiClient(fetchMock);

    await client.fetchTopicPage("ornek-konu", 42, 2, "popular");

    expect(fetchMock).toHaveBeenCalledOnce();
    const [url] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    expect(String(url)).toBe("https://eksisozluk.com/ornek-konu--42?a=popular&p=2");
  });

  it("topic HTTP hatalarını TOPIC_FETCH_FAILED olarak sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("no", {
      status: 429,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchTopicPage("ornek-konu", 42, 1, "popular"))
      .rejects.toBeInstanceOf(TopicFetchError);
  });

  it("resolve redirect'ini manual kullanıp Location döndürür", async () => {
    const fetchMock = mockFetch(new Response(null, {
      status: 302,
      headers: { Location: "/ornek-konu--42" },
    }));
    const client = new EksiClient(fetchMock);

    await expect(client.fetchSearchResolveLocation("örnek konu"))
      .resolves.toBe("/ornek-konu--42");

    const [url, init] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    expect(new URL(String(url)).searchParams.get("q")).toBe("örnek konu");
    expect(init?.redirect).toBe("manual");
    expect(fetchMock).toHaveBeenCalledOnce();
  });

  it("Location bulunmayan redirect için kontrollü hata verir", async () => {
    const client = new EksiClient(mockFetch(new Response(null, { status: 302 })));
    await expect(client.fetchSearchResolveLocation("örnek konu"))
      .rejects.toBeInstanceOf(SearchResolveError);
  });

  it.each([403, 429, 500])("resolve HTTP %i için kontrollü hata verir", async (status) => {
    const client = new EksiClient(mockFetch(new Response("no", { status })));
    await expect(client.fetchSearchResolveLocation("örnek konu"))
      .rejects.toBeInstanceOf(SearchResolveError);
  });

  it("resolve Managed Challenge'ı unavailable olarak sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("challenge", {
      status: 403,
      headers: { "cf-mitigated": "challenge" },
    })));
    await expect(client.fetchSearchResolveLocation("örnek konu"))
      .rejects.toBeInstanceOf(SearchResolveUnavailableError);
  });

  it("resolve 200 HTML response'unu topic kabul etmez", async () => {
    const client = new EksiClient(mockFetch(new Response("<html>arama</html>", {
      status: 200,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchSearchResolveLocation("serbest arama"))
      .rejects.toBeInstanceOf(SearchResolveNotFoundError);
  });

  it("author profile slug'ını güvenli path segment olarak gönderir", async () => {
    const fetchMock = mockFetch(new Response("<html>profile</html>", {
      status: 200,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    }));
    const client = new EksiClient(fetchMock);

    await client.fetchAuthorProfile("sosyopatiz elhamdurillah");

    const [url] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    expect(String(url)).toBe("https://eksisozluk.com/biri/sosyopatiz%20elhamdurillah");
  });

  it("author entries için nick ve page ile tek request atıp cachebuster eklemez", async () => {
    const fetchMock = mockFetch(new Response("<div>entries</div>", {
      status: 200,
      headers: { "Content-Type": "text/html" },
    }));
    const client = new EksiClient(fetchMock);

    await client.fetchAuthorEntries("sakarninja", 2);

    expect(fetchMock).toHaveBeenCalledOnce();
    const [url] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    const parsedUrl = new URL(String(url));
    expect(parsedUrl.pathname).toBe("/son-entryleri");
    expect(parsedUrl.searchParams.get("nick")).toBe("sakarninja");
    expect(parsedUrl.searchParams.get("p")).toBe("2");
    expect(parsedUrl.searchParams.has("_")).toBe(false);
    const [, init] = vi.mocked(fetchMock).mock.calls[0] ?? [];
    expect(new Headers(init?.headers).get("X-Requested-With")).toBe("XMLHttpRequest");
  });

  it("profile 404 response'unu author not found olarak sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("not found", {
      status: 404,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchAuthorProfile("yok"))
      .rejects.toBeInstanceOf(AuthorNotFoundError);
  });

  it("author profile HTTP hatasını kontrollü sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("error", {
      status: 500,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchAuthorProfile("sakarninja"))
      .rejects.toBeInstanceOf(AuthorFetchError);
  });

  it("author entries HTTP hatasını kontrollü sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("error", {
      status: 429,
      headers: { "Content-Type": "text/html" },
    })));
    await expect(client.fetchAuthorEntries("sakarninja", 1))
      .rejects.toBeInstanceOf(AuthorEntriesFetchError);
  });

  it("cf-mitigated author challenge'ını parser'a vermeden sınıflandırır", async () => {
    const client = new EksiClient(mockFetch(new Response("challenge", {
      status: 403,
      headers: { "Content-Type": "text/html", "cf-mitigated": "challenge" },
    })));
    await expect(client.fetchAuthorProfile("sakarninja"))
      .rejects.toBeInstanceOf(AuthorSourceChallengeError);
  });

  it("200 response içindeki Just a moment challenge HTML'ini algılar", async () => {
    const client = new EksiClient(mockFetch(new Response(
      "<html><title>Just a moment...</title><script>window._cf_chl_opt={}</script></html>",
      { status: 200, headers: { "Content-Type": "text/html" } },
    )));
    await expect(client.fetchAuthorEntries("sakarninja", 1))
      .rejects.toBeInstanceOf(AuthorSourceChallengeError);
  });
});
