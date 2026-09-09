import { EKSI_BASE_URL } from "../config";
import { SearchResolveError } from "../errors/app-error";

const TOPIC_LOCATION_PATTERN = /^\/([^/?#]+)--(\d+)\/?$/u;

export interface ParsedTopicLocation {
  id: number;
  slug: string;
}

export function parseTopicLocation(location: string): ParsedTopicLocation {
  let pathname: string;
  try {
    pathname = new URL(location, EKSI_BASE_URL).pathname;
  } catch (error) {
    throw new SearchResolveError("Resolve Location geçerli bir URL değil.", { cause: error });
  }

  const match = TOPIC_LOCATION_PATTERN.exec(pathname);
  if (!match?.[1] || !match[2]) {
    throw new SearchResolveError("Resolve Location topic pattern'ine uymuyor.");
  }
  const id = Number(match[2]);
  if (!Number.isSafeInteger(id) || id <= 0) {
    throw new SearchResolveError("Resolve Location geçerli topic id içermiyor.");
  }
  return { id, slug: match[1] };
}
