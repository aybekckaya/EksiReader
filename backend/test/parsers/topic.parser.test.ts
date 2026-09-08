import { beforeAll, describe, expect, it } from "vitest";
import { TopicParseError } from "../../src/errors/app-error";
import type { ParsedTopicPage } from "../../src/models/entry";
import { parseTopicHtml } from "../../src/parsers/topic.parser";
import topicHtml from "../fixtures/topic.html?raw";

describe("parseTopicHtml", () => {
  let parsed: ParsedTopicPage;

  beforeAll(async () => {
    parsed = await parseTopicHtml(topicHtml, 1);
  });

  it("topic id parse eder", () => {
    expect(parsed.topic.id).toBe(8136443);
  });

  it("topic title parse eder", () => {
    expect(parsed.topic.title).toBe("8 eylül 2026 real madrid inter maçı");
  });

  it("topic slug parse eder", () => {
    expect(parsed.topic.slug).toBe("8-eylul-2026-real-madrid-inter-maci");
  });

  it("currentPage parse eder", () => {
    expect(parsed.pagination.currentPage).toBe(1);
  });

  it("pageCount parse eder", () => {
    expect(parsed.pagination.pageCount).toBe(23);
  });

  it("hasNextPage ve nextPage hesaplar", () => {
    expect(parsed.pagination).toMatchObject({ hasNextPage: true, nextPage: 2 });
  });

  it("son sayfada hasNextPage false döndürür", async () => {
    const lastPageHtml = topicHtml
      .replace('data-currentpage="1"', 'data-currentpage="23"');
    const result = await parseTopicHtml(lastPageHtml, 23);
    expect(result.pagination).toMatchObject({ hasNextPage: false, nextPage: null });
  });

  it("entry id parse eder", () => {
    expect(parsed.entries[0]?.id).toBe(186257381);
  });

  it("author id parse eder", () => {
    expect(parsed.entries[0]?.author.id).toBe(1200425);
  });

  it("author username parse eder", () => {
    expect(parsed.entries[0]?.author.username).toBe("sosyopatiz elhamdurillah");
  });

  it("author slug'ını href üzerinden parse eder", () => {
    expect(parsed.entries[0]?.author.slug).toBe("sosyopatiz-elhamdurillah");
  });

  it("absolute avatar URL'yi korur", () => {
    expect(parsed.entries[0]?.author.avatarUrl)
      .toBe("https://img.ekstat.com/profiles/sosyopatiz.jpg");
  });

  it("protocol-relative avatar URL'yi HTTPS'e çevirir", () => {
    expect(parsed.entries[1]?.author.avatarUrl)
      .toBe("https://ekstat.com/img/default-profile-picture-light.svg");
  });

  it("favoriteCount parse eder", () => {
    expect(parsed.entries[0]?.favoriteCount).toBe(3);
  });

  it("commentCount parse eder", () => {
    expect(parsed.entries[0]?.commentCount).toBe(2);
  });

  it("likeCount parse eder", () => {
    expect(parsed.entries[0]?.likeCount).toBe(5);
  });

  it("dateText parse edip normalize eder", () => {
    expect(parsed.entries[0]?.dateText).toBe("08.09.2026 19:50 ~ 20:00");
  });

  it("permalink'i absolute URL'ye çevirir", () => {
    expect(parsed.entries[0]?.permalink).toBe("https://eksisozluk.com/entry/186257381");
  });

  it("contentText'i tagsiz, decode edilmiş metne çevirir", () => {
    expect(parsed.entries[0]?.contentText).toBe(
      "arda'nın kırmızı kart cezasından kaynaklı ilk 11 başlamayacağı maç. 22:00'de başlayacak güvensiz protokol",
    );
  });

  it("contentHtml linkleri korurken tehlikeli içeriği temizler", () => {
    const contentHtml = parsed.entries[0]?.contentHtml ?? "";
    expect(contentHtml).toContain('<a href="/entry/42">');
    expect(contentHtml).not.toMatch(/<script|<style|onclick=/iu);
    expect(contentHtml).not.toContain("alert('kötü')");
    expect(contentHtml).not.toMatch(/href=["']javascript:/iu);
  });

  it("birden fazla entry parse eder", () => {
    expect(parsed.entries).toHaveLength(3);
  });

  it("topic selector yoksa parse error verir", async () => {
    await expect(parseTopicHtml(topicHtml.replace('id="title"', 'id="old-title"'), 1))
      .rejects.toBeInstanceOf(TopicParseError);
  });

  it("entry listesi yoksa kontrollü parse error verir", async () => {
    await expect(parseTopicHtml(topicHtml.replace('id="entry-item-list"', 'id="old-list"'), 1))
      .rejects.toBeInstanceOf(TopicParseError);
  });

  it("pager yoksa tek sayfa fallback uygular", async () => {
    const noPagerHtml = topicHtml.replace(
      '<div class="pager" data-currentpage="1" data-pagecount="23"></div>',
      "",
    );
    const result = await parseTopicHtml(noPagerHtml, 1);
    expect(result.pagination).toEqual({
      currentPage: 1,
      pageCount: 1,
      hasPreviousPage: false,
      previousPage: null,
      hasNextPage: false,
      nextPage: null,
    });
  });

  it("eksik avatar ve geçersiz count alanlarına güvenli fallback uygular", () => {
    expect(parsed.entries[2]?.author.avatarUrl).toBeNull();
    expect(parsed.entries[2]).toMatchObject({ favoriteCount: 0, commentCount: 0, likeCount: 0 });
  });
});
