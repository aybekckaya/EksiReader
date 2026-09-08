import { describe, expect, it } from "vitest";
import { TrendingParseError } from "../../src/errors/app-error";
import { parseTrendingHtml } from "../../src/parsers/trending.parser";
import fixtureHtml from "../fixtures/trending.html?raw";

describe("parseTrendingHtml", () => {
  it("birden fazla topic'i tüm normalize alanlarıyla parse eder", async () => {
    const result = await parseTrendingHtml(fixtureHtml);

    expect(result.topics).toHaveLength(2);
    expect(result.topics[0]).toEqual({
      id: 8136213,
      title: "instagramdaki 80's akımı",
      slug: "instagramdaki-80s-akimi",
      entryCount: 618,
    });
    expect(result.topics[1]).toEqual({
      id: 8136321,
      title: "meydan okuyan kadın motorcunun feci ölümü",
      slug: "meydan-okuyan-kadin-motorcunun-feci-olumu",
      entryCount: 73,
    });
  });

  it("query string'i yok sayar ve bozuk href'i güvenle atlar", async () => {
    const result = await parseTrendingHtml(fixtureHtml);
    expect(result.topics.map((topic) => topic.id)).toEqual([8136213, 8136321]);
  });

  it("pagination link'inden nextPage çıkarır", async () => {
    const result = await parseTrendingHtml(fixtureHtml);
    expect(result.pagination).toEqual({ hasNextPage: true, nextPage: 2 });
  });

  it("pagination link'i yoksa sonraki sayfa olmadığını bildirir", async () => {
    const html = '<ul class="topic-list"><li><a href="/konu--42">konu <small>1</small></a></li></ul>';
    const result = await parseTrendingHtml(html);
    expect(result.pagination).toEqual({ hasNextPage: false, nextPage: null });
  });

  it("topic-list yoksa parser hatası verir", async () => {
    await expect(parseTrendingHtml("<html><body></body></html>"))
      .rejects.toBeInstanceOf(TrendingParseError);
  });

  it("boş HTML için parser hatası verir", async () => {
    await expect(parseTrendingHtml("   ")).rejects.toBeInstanceOf(TrendingParseError);
  });

  it("topic-list geçerli topic içermiyorsa parser hatası verir", async () => {
    await expect(parseTrendingHtml('<ul class="topic-list"><li>boş</li></ul>'))
      .rejects.toBeInstanceOf(TrendingParseError);
  });
});
