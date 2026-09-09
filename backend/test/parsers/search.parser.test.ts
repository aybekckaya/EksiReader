import { describe, expect, it } from "vitest";
import { SearchResolveError } from "../../src/errors/app-error";
import { parseTopicLocation } from "../../src/parsers/search.parser";

describe("parseTopicLocation", () => {
  it("relative Location içinden topic id ve slug çıkarır", () => {
    expect(parseTopicLocation(
      "/4-agustos-2021-guney-kore-turkiye-voleybol-maci--6994477",
    )).toEqual({
      id: 6994477,
      slug: "4-agustos-2021-guney-kore-turkiye-voleybol-maci",
    });
  });

  it("absolute Location URL'yi destekler", () => {
    expect(parseTopicLocation("https://eksisozluk.com/foo--123"))
      .toEqual({ id: 123, slug: "foo" });
  });

  it("topic pattern'ine uymayan Location için hata verir", () => {
    expect(() => parseTopicLocation("/basliklar/ara?q=foo"))
      .toThrow(SearchResolveError);
  });

  it("numeric olmayan topic id için hata verir", () => {
    expect(() => parseTopicLocation("/foo--abc"))
      .toThrow(SearchResolveError);
  });
});
