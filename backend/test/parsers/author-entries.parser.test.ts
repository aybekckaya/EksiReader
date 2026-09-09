import { beforeAll, describe, expect, it } from "vitest";
import { AuthorEntriesParseError } from "../../src/errors/app-error";
import type { ParsedAuthorEntries } from "../../src/models/author";
import { parseAuthorEntries } from "../../src/parsers/author-entries.parser";
import authorEntriesHtml from "../fixtures/author-entries.html?raw";
import authorEntriesLastPageHtml from "../fixtures/author-entries-last-page.html?raw";

const OPTIONS = {
  requestedPage: 1,
  authorSlug: "sakarninja",
  expectedUsername: "sakarninja",
};

describe("parseAuthorEntries", () => {
  let parsed: ParsedAuthorEntries;

  beforeAll(async () => {
    parsed = await parseAuthorEntries(authorEntriesHtml, OPTIONS);
  });

  it("üç topic-item parse eder", () => {
    expect(parsed.items).toHaveLength(3);
  });

  it("topic id parse eder", () => {
    expect(parsed.items[0]?.topic.id).toBe(38998);
  });

  it("topic title parse eder", () => {
    expect(parsed.items[0]?.topic.title).toBe("ibanez");
  });

  it("topic slug parse eder", () => {
    expect(parsed.items[0]?.topic.slug).toBe("ibanez");
  });

  it("entry id parse eder", () => {
    expect(parsed.items[0]?.entry.id).toBe(9396215);
  });

  it("author id parse eder", () => {
    expect(parsed.items[0]?.entry.author.id).toBe(9200);
  });

  it("author username parse eder", () => {
    expect(parsed.items[0]?.entry.author.username).toBe("sakarninja");
  });

  it("author slug'ını entry href'inden parse eder", () => {
    expect(parsed.items[0]?.entry.author.slug).toBe("sakarninja");
  });

  it("favoriteCount parse eder", () => {
    expect(parsed.items[0]?.entry.favoriteCount).toBe(2);
  });

  it("commentCount parse eder", () => {
    expect(parsed.items[0]?.entry.commentCount).toBe(1);
  });

  it("likeCount parse eder", () => {
    expect(parsed.items[0]?.entry.likeCount).toBe(4);
  });

  it("contentText'i tagsiz ve normalize edilmiş döndürür", () => {
    expect(parsed.items[0]?.entry.contentText).toBe("ilk güvenli link içeriği");
  });

  it("ortak sanitizer unsafe content'i temizler", () => {
    const contentHtml = parsed.items[0]?.entry.contentHtml ?? "";
    expect(contentHtml).toContain('<a href="/entry/42">');
    expect(contentHtml).not.toMatch(/<script|<style|onclick=|javascript:/iu);
  });

  it("dateText parse eder", () => {
    expect(parsed.items[0]?.entry.dateText).toBe("12.04.2006 05:13");
  });

  it("relative permalink'i absolute URL'ye çevirir", () => {
    expect(parsed.items[0]?.entry.permalink).toBe("https://eksisozluk.com/entry/9396215");
  });

  it("currentPage değerini requested page'den alır", () => {
    expect(parsed.pagination.currentPage).toBe(1);
  });

  it("page 1 için previous false/null döner", () => {
    expect(parsed.pagination).toMatchObject({ hasPreviousPage: false, previousPage: null });
  });

  it("page 2 için previous true/1 döner", async () => {
    const result = await parseAuthorEntries(authorEntriesHtml, { ...OPTIONS, requestedPage: 2 });
    expect(result.pagination).toMatchObject({
      currentPage: 2,
      hasPreviousPage: true,
      previousPage: 1,
    });
  });

  it("no-more-data yok ve item varsa next page üretir", () => {
    expect(parsed.pagination).toMatchObject({ hasNextPage: true, nextPage: 2 });
  });

  it("no-more-data varsa last page üretir", async () => {
    const result = await parseAuthorEntries(authorEntriesLastPageHtml, {
      ...OPTIONS,
      requestedPage: 3,
    });
    expect(result.pagination).toMatchObject({ hasNextPage: false, nextPage: null });
  });

  it("invalid topic id için kontrollü parse error verir", async () => {
    await expect(parseAuthorEntries(
      authorEntriesHtml.replace('data-id="38998"', 'data-id="bad"'),
      OPTIONS,
    )).rejects.toBeInstanceOf(AuthorEntriesParseError);
  });

  it("invalid entry id için kontrollü parse error verir", async () => {
    await expect(parseAuthorEntries(
      authorEntriesHtml.replace('data-id="9396215"', 'data-id="bad"'),
      OPTIONS,
    )).rejects.toBeInstanceOf(AuthorEntriesParseError);
  });

  it("beklenmeyen boş response için kontrollü parse error verir", async () => {
    await expect(parseAuthorEntries("<div></div>", OPTIONS))
      .rejects.toBeInstanceOf(AuthorEntriesParseError);
  });

  it("no-more-data içeren boş son sayfayı güvenli şekilde kabul eder", async () => {
    const result = await parseAuthorEntries('<div class="no-more-data"></div>', OPTIONS);
    expect(result).toMatchObject({
      items: [],
      pagination: { hasNextPage: false, nextPage: null },
    });
  });

  it("beklenen username ile eşleşmeyen entry'yi reddeder", async () => {
    await expect(parseAuthorEntries(authorEntriesHtml, {
      ...OPTIONS,
      expectedUsername: "başka yazar",
    })).rejects.toBeInstanceOf(AuthorEntriesParseError);
  });
});
