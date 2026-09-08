import { EKSI_BASE_URL } from "../config";
import { TopicParseError } from "../errors/app-error";
import type {
  Entry,
  ParsedTopicPage,
  TopicDetail,
  TopicPagination,
} from "../models/entry";
import { normalizeDecodedText } from "../utils/text";

const AUTHOR_PATH_PATTERN = /^\/biri\/([^/?#]+)\/?$/u;
const CONTENT_MARKER_PREFIX = "EKSI_READER_CONTENT";

interface EntryBuilder {
  id: number;
  authorId: number;
  username: string;
  authorSlug: string | null;
  avatarUrl: string | null;
  dateText: string;
  favoriteCount: number;
  commentCount: number;
  likeCount: number;
  permalink: string | null;
  marker: string;
  hasContent: boolean;
}

function positiveInteger(value: string | null): number | null {
  if (value === null || !/^\d+$/u.test(value)) {
    return null;
  }
  const parsed = Number(value);
  return Number.isSafeInteger(parsed) && parsed > 0 ? parsed : null;
}

function nonNegativeInteger(value: string | null): number {
  if (value === null || !/^\d+$/u.test(value)) {
    return 0;
  }
  const parsed = Number(value);
  return Number.isSafeInteger(parsed) && parsed >= 0 ? parsed : 0;
}

function absoluteUrl(value: string | null): string | null {
  if (value === null || value.trim() === "") {
    return null;
  }
  if (value.startsWith("//")) {
    return `https:${value}`;
  }
  try {
    const url = new URL(value, EKSI_BASE_URL);
    return url.protocol === "http:" || url.protocol === "https:" ? url.toString() : null;
  } catch {
    return null;
  }
}

function authorSlugFromHref(href: string | null): string | null {
  if (href === null) {
    return null;
  }
  try {
    const match = AUTHOR_PATH_PATTERN.exec(new URL(href, EKSI_BASE_URL).pathname);
    if (!match?.[1]) {
      return null;
    }
    return decodeURIComponent(match[1]);
  } catch {
    return null;
  }
}

class TopicHandler implements HTMLRewriterElementContentHandlers {
  topic: TopicDetail | null = null;

  element(element: Element): void {
    const id = positiveInteger(element.getAttribute("data-id"));
    const title = normalizeDecodedText(element.getAttribute("data-title") ?? "");
    const slug = element.getAttribute("data-slug")?.trim() ?? "";
    if (id !== null && title !== "" && slug !== "") {
      this.topic = { id, title, slug };
    }
  }
}

class PagerHandler implements HTMLRewriterElementContentHandlers {
  found = false;
  pagination: Pick<TopicPagination, "currentPage" | "pageCount"> | null = null;

  element(element: Element): void {
    this.found = true;
    const currentPage = positiveInteger(element.getAttribute("data-currentpage"));
    const pageCount = positiveInteger(element.getAttribute("data-pagecount"));
    if (currentPage !== null && pageCount !== null) {
      this.pagination = { currentPage, pageCount };
    }
  }
}

class PresenceHandler implements HTMLRewriterElementContentHandlers {
  found = false;

  element(): void {
    this.found = true;
  }
}

class EntryCollector implements HTMLRewriterElementContentHandlers {
  readonly entries: EntryBuilder[] = [];
  current: EntryBuilder | null = null;
  private markerSequence = 0;

  element(element: Element): void {
    const id = positiveInteger(element.getAttribute("data-id"));
    const authorId = positiveInteger(element.getAttribute("data-author-id"));
    const username = normalizeDecodedText(element.getAttribute("data-author") ?? "");
    const marker = `${CONTENT_MARKER_PREFIX}_${this.markerSequence++}`;
    const builder = id === null || authorId === null || username === ""
      ? null
      : {
          id,
          authorId,
          username,
          authorSlug: null,
          avatarUrl: null,
          dateText: "",
          favoriteCount: nonNegativeInteger(element.getAttribute("data-favorite-count")),
          commentCount: nonNegativeInteger(element.getAttribute("data-comment-count")),
          likeCount: nonNegativeInteger(element.getAttribute("data-likecount")),
          permalink: null,
          marker,
          hasContent: false,
        };

    this.current = builder;
    element.onEndTag(() => {
      if (builder !== null) {
        this.entries.push(builder);
      }
      if (this.current === builder) {
        this.current = null;
      }
    });
  }
}

class ContentHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector) {}

  element(element: Element): void {
    const entry = this.collector.current;
    if (entry === null) {
      return;
    }
    entry.hasContent = true;
    element.prepend(`<!--${entry.marker}_START-->`, { html: true });
    element.append(`<!--${entry.marker}_END-->`, { html: true });
  }
}

class AuthorHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.authorSlug = authorSlugFromHref(element.getAttribute("href"));
    }
  }
}

class AvatarHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.avatarUrl = absoluteUrl(element.getAttribute("src"));
    }
  }
}

class DateHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.permalink = absoluteUrl(element.getAttribute("href"));
    }
  }

  text(text: Text): void {
    if (this.collector.current !== null) {
      this.collector.current.dateText += text.text;
    }
  }
}

class RemoveElementHandler implements HTMLRewriterElementContentHandlers {
  element(element: Element): void {
    element.remove();
  }
}

class SanitizeElementHandler implements HTMLRewriterElementContentHandlers {
  element(element: Element): void {
    const attributes = Array.from(element.attributes);
    for (const attribute of attributes) {
      const name = attribute[0];
      const value = attribute[1] ?? "";
      if (name === undefined) {
        continue;
      }
      const lowerName = name.toLowerCase();
      if (lowerName.startsWith("on") || lowerName === "srcdoc") {
        element.removeAttribute(name);
        continue;
      }
      if ((lowerName === "href" || lowerName === "src") && /^\s*javascript:/iu.test(value)) {
        element.removeAttribute(name);
      }
    }
  }
}

function buildPagination(
  parsed: Pick<TopicPagination, "currentPage" | "pageCount"> | null,
  requestedPage: number,
): TopicPagination {
  const currentPage = parsed?.currentPage ?? requestedPage;
  const pageCount = parsed?.pageCount ?? 1;
  const hasPreviousPage = currentPage > 1;
  const hasNextPage = currentPage < pageCount;
  return {
    currentPage,
    pageCount,
    hasPreviousPage,
    previousPage: hasPreviousPage ? currentPage - 1 : null,
    hasNextPage,
    nextPage: hasNextPage ? currentPage + 1 : null,
  };
}

function extractContentHtml(html: string, marker: string): string | null {
  const startMarker = `<!--${marker}_START-->`;
  const endMarker = `<!--${marker}_END-->`;
  const start = html.indexOf(startMarker);
  const end = html.indexOf(endMarker, start + startMarker.length);
  if (start < 0 || end < 0) {
    return null;
  }
  return html.slice(start + startMarker.length, end).trim();
}

function toEntry(builder: EntryBuilder, transformedHtml: string): Entry | null {
  const contentHtml = extractContentHtml(transformedHtml, builder.marker);
  const contentText = contentHtml === null
    ? ""
    : normalizeDecodedText(contentHtml.replace(/<[^>]*>/gu, " "));
  const dateText = normalizeDecodedText(builder.dateText);
  if (
    !builder.hasContent
    || contentHtml === null
    || contentText === ""
    || builder.authorSlug === null
    || dateText === ""
    || builder.permalink === null
  ) {
    return null;
  }

  return {
    id: builder.id,
    contentText,
    contentHtml,
    author: {
      id: builder.authorId,
      username: builder.username,
      slug: builder.authorSlug,
      avatarUrl: builder.avatarUrl,
    },
    dateText,
    favoriteCount: builder.favoriteCount,
    commentCount: builder.commentCount,
    likeCount: builder.likeCount,
    permalink: builder.permalink,
  };
}

export async function parseTopicHtml(html: string, requestedPage: number): Promise<ParsedTopicPage> {
  if (html.trim() === "") {
    throw new TopicParseError("HTML boş.");
  }

  const topicHandler = new TopicHandler();
  const pagerHandler = new PagerHandler();
  const entryListHandler = new PresenceHandler();
  const entryCollector = new EntryCollector();

  try {
    const transformed = new HTMLRewriter()
      .on("h1#title", topicHandler)
      .on(".pager", pagerHandler)
      .on("#entry-item-list", entryListHandler)
      .on("#entry-item-list > li#entry-item", entryCollector)
      .on("#entry-item-list > li#entry-item .content", new ContentHandler(entryCollector))
      .on("#entry-item-list > li#entry-item .entry-author", new AuthorHandler(entryCollector))
      .on("#entry-item-list > li#entry-item img.avatar", new AvatarHandler(entryCollector))
      .on("#entry-item-list > li#entry-item .entry-date.permalink", new DateHandler(entryCollector))
      .on("#entry-item-list > li#entry-item .content script", new RemoveElementHandler())
      .on("#entry-item-list > li#entry-item .content style", new RemoveElementHandler())
      .on("#entry-item-list > li#entry-item .content *", new SanitizeElementHandler())
      .transform(new Response(html));
    const transformedHtml = await transformed.text();

    if (topicHandler.topic === null) {
      throw new TopicParseError("h1#title bulunamadı veya metadata geçersiz.");
    }
    if (!entryListHandler.found) {
      throw new TopicParseError("#entry-item-list bulunamadı.");
    }
    if (pagerHandler.found && pagerHandler.pagination === null) {
      throw new TopicParseError(".pager pagination metadata'sı geçersiz.");
    }

    const entries = entryCollector.entries
      .map((builder) => toEntry(builder, transformedHtml))
      .filter((entry): entry is Entry => entry !== null);
    if (entries.length === 0) {
      throw new TopicParseError("Entry listesinde geçerli entry bulunamadı.");
    }

    return {
      topic: topicHandler.topic,
      entries,
      pagination: buildPagination(pagerHandler.pagination, requestedPage),
    };
  } catch (error) {
    if (error instanceof TopicParseError) {
      throw error;
    }
    throw new TopicParseError("HTMLRewriter topic HTML'ini işleyemedi.", { cause: error });
  }
}
