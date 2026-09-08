import { describe, expect, it, vi } from "vitest";
import { EksiClient } from "../../src/clients/eksi.client";
import { TopicFetchError, TrendingFetchError } from "../../src/errors/app-error";

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
});
