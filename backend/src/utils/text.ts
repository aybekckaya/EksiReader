const NAMED_ENTITIES: Readonly<Record<string, string>> = {
  amp: "&",
  apos: "'",
  gt: ">",
  lt: "<",
  nbsp: " ",
  quot: '"',
};

export function normalizeWhitespace(value: string): string {
  return value.replace(/\s+/gu, " ").trim();
}

export function decodeHtmlEntities(value: string): string {
  return value.replace(
    /&(?:#(\d+)|#x([\da-f]+)|([a-z]+));/giu,
    (entity, decimal: string | undefined, hex: string | undefined, named: string | undefined) => {
      if (decimal !== undefined || hex !== undefined) {
        const codePoint = Number.parseInt(decimal ?? hex ?? "", decimal === undefined ? 16 : 10);
        try {
          return String.fromCodePoint(codePoint);
        } catch {
          return entity as string;
        }
      }
      return named === undefined
        ? entity as string
        : (NAMED_ENTITIES[named.toLowerCase()] ?? entity as string);
    },
  );
}

export function normalizeDecodedText(value: string): string {
  return normalizeWhitespace(decodeHtmlEntities(value));
}
