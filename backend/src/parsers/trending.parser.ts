import { TrendingParseError } from "../errors/app-error";
import type { ParsedTrendingPage, Topic } from "../models/topic";

const TOPIC_PATH_PATTERN = /^\/([^/?#]+)--(\d+)\/?$/;

function normalizeWhitespace(value: string): string {
  return value.replace(/\s+/gu, " ").trim();
}

const NAMED_ENTITIES: Readonly<Record<string, string>> = {
  amp: "&",
  apos: "'",
  gt: ">",
  lt: "<",
  nbsp: " ",
  quot: '"',
};

function decodeHtmlEntities(value: string): string {
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
      return named === undefined ? entity as string : (NAMED_ENTITIES[named.toLowerCase()] ?? entity as string);
    },
  );
}

function parseTopicHref(href: string): Pick<Topic, "id" | "slug"> | null {
  let pathname: string;
  try {
    pathname = new URL(href, "https://eksisozluk.com").pathname;
  } catch {
    return null;
  }

  const match = TOPIC_PATH_PATTERN.exec(pathname);
  if (!match?.[1] || !match[2]) {
    return null;
  }

  const id = Number.parseInt(match[2], 10);
  if (!Number.isSafeInteger(id)) {
    return null;
  }

  return { id, slug: match[1] };
}

class PresenceHandler implements HTMLRewriterElementContentHandlers {
  found = false;

  element(): void {
    this.found = true;
  }
}

class TopicAnchorHandler implements HTMLRewriterElementContentHandlers {
  readonly topics: Topic[] = [];
  private current: { href: string; text: string } | null = null;

  element(element: Element): void {
    const href = element.getAttribute("href");
    this.current = href === null ? null : { href, text: "" };
    element.onEndTag(() => this.finishCurrent());
  }

  text(chunk: Text): void {
    if (this.current !== null) {
      this.current.text += chunk.text;
    }
  }

  private finishCurrent(): void {
    if (this.current === null) {
      return;
    }

    const parsedHref = parseTopicHref(this.current.href);
    const normalizedText = normalizeWhitespace(this.current.text);
    this.current = null;
    if (parsedHref === null) {
      return;
    }

    const textMatch = /^(.*?)\s+(\d[\d.]*)$/u.exec(normalizedText);
    if (!textMatch?.[1] || !textMatch[2]) {
      return;
    }

    const entryCount = Number.parseInt(textMatch[2].replaceAll(".", ""), 10);
    if (!Number.isSafeInteger(entryCount)) {
      return;
    }

    this.topics.push({
      ...parsedHref,
      title: normalizeWhitespace(decodeHtmlEntities(textMatch[1])),
      entryCount,
    });
  }
}

class PaginationHandler implements HTMLRewriterElementContentHandlers {
  nextPage: number | null = null;

  element(element: Element): void {
    const href = element.getAttribute("href");
    if (href === null) {
      return;
    }

    try {
      const pageValue = new URL(href, "https://eksisozluk.com").searchParams.get("p");
      if (pageValue === null) {
        return;
      }
      const page = Number(pageValue);
      if (Number.isSafeInteger(page) && page > 0) {
        this.nextPage = page;
      }
    } catch {
      // Malformed pagination links are treated as absent.
    }
  }
}

export async function parseTrendingHtml(html: string): Promise<ParsedTrendingPage> {
  if (html.trim().length === 0) {
    throw new TrendingParseError("HTML boş.");
  }

  const topicList = new PresenceHandler();
  const anchors = new TopicAnchorHandler();
  const pagination = new PaginationHandler();

  try {
    const transformed = new HTMLRewriter()
      .on(".topic-list", topicList)
      .on(".topic-list li > a[href]", anchors)
      .on("#quick-index-continue-link", pagination)
      .transform(new Response(html));
    await transformed.arrayBuffer();
  } catch (error) {
    throw new TrendingParseError("HTMLRewriter HTML'i işleyemedi.", { cause: error });
  }

  if (!topicList.found) {
    throw new TrendingParseError(".topic-list bulunamadı.");
  }
  if (anchors.topics.length === 0) {
    throw new TrendingParseError(".topic-list içinde geçerli topic bulunamadı.");
  }

  return {
    topics: anchors.topics,
    pagination: {
      hasNextPage: pagination.nextPage !== null,
      nextPage: pagination.nextPage,
    },
  };
}
