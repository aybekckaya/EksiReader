import { describe, expect, it } from "vitest";
import { normalizeSearchText } from "../../src/utils/search";

describe("normalizeSearchText", () => {
  it.each([
    ["Kadın", "kadin"],
    ["KADIN", "kadin"],
    ["İSTANBUL", "istanbul"],
    ["  kadın   yazarlar ", "kadin yazarlar"],
    ["ŞĞÜÖÇ", "sguoc"],
  ])("%s değerini %s olarak normalize eder", (input, expected) => {
    expect(normalizeSearchText(input)).toBe(expected);
  });
});
