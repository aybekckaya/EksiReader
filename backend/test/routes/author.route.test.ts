import { describe, expect, it } from "vitest";
import {
  parseAuthorEntriesPage,
  parseAuthorSlug,
} from "../../src/routes/author.route";

describe("author route validation", () => {
  it("author slug çevresindeki whitespace'i trim edip bir kez decode eder", () => {
    expect(parseAuthorSlug("%20sosyopatiz-elhamdurillah%20"))
      .toBe("sosyopatiz-elhamdurillah");
  });

  it.each(["", "%20%20", ".", "..", "a%2Fb", "a%5Cb", "%E0%A4%A", "a\\b"])(
    "geçersiz author slug değerini reddeder: %s",
    (value) => {
      expect(() => parseAuthorSlug(value))
        .toThrowError(expect.objectContaining({ code: "INVALID_AUTHOR_SLUG" }));
    },
  );

  it("100 karakterden uzun author slug değerini reddeder", () => {
    expect(() => parseAuthorSlug("a".repeat(101)))
      .toThrowError(expect.objectContaining({ code: "INVALID_AUTHOR_SLUG" }));
  });

  it("page verilmezse 1 döner", () => {
    expect(parseAuthorEntriesPage(new Request("https://api.test/v1/authors/a/entries")))
      .toBe(1);
  });

  it("1 ile 1000 arasındaki page değerini kabul eder", () => {
    expect(parseAuthorEntriesPage(new Request(
      "https://api.test/v1/authors/a/entries?page=1000",
    ))).toBe(1000);
  });

  it.each(["0", "1001", "1.5", "abc", "-1"])("geçersiz page değerini reddeder: %s", (page) => {
    expect(() => parseAuthorEntriesPage(new Request(
      `https://api.test/v1/authors/a/entries?page=${page}`,
    ))).toThrowError(expect.objectContaining({ code: "INVALID_PAGE" }));
  });
});
