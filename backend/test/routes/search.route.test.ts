import { describe, expect, it } from "vitest";
import { parseSearchQuery } from "../../src/routes/search.route";

describe("search query validation", () => {
  it("query çevresindeki whitespace'i trim eder", () => {
    expect(parseSearchQuery(new Request("https://api.test/v1/search/suggestions?q=%20voleybol%20")))
      .toBe("voleybol");
  });

  it.each([
    "https://api.test/v1/search/suggestions",
    "https://api.test/v1/search/suggestions?q=%20%20",
    "https://api.test/v1/search/suggestions?q=v",
  ])("eksik, boş veya kısa query'yi reddeder: %s", (url) => {
    expect(() => parseSearchQuery(new Request(url)))
      .toThrowError(expect.objectContaining({ code: "INVALID_SEARCH_QUERY" }));
  });

  it("100 karakterden uzun query'yi reddeder", () => {
    const query = "a".repeat(101);
    expect(() => parseSearchQuery(new Request(
      `https://api.test/v1/search/suggestions?q=${query}`,
    ))).toThrowError(expect.objectContaining({ code: "INVALID_SEARCH_QUERY" }));
  });
});
