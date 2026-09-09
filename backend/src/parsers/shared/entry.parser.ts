import { EKSI_BASE_URL } from "../../config";
import type { Entry } from "../../models/entry";
import { normalizeDecodedText } from "../../utils/text";

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

interface EntryRecord<TContext> {
  builder: EntryBuilder;
  context: TContext;
}

export interface ParsedEntryRecord<TContext> {
  entry: Entry;
  context: TContext;
}

export interface ParsedEntryCollection<TContext> {
  entries: ParsedEntryRecord<TContext>[];
  invalidEntryCount: number;
}

export function positiveInteger(value: string | null): number | null {
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

export function absoluteUrl(value: string | null): string | null {
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

class EntryCollector<TContext> implements HTMLRewriterElementContentHandlers {
  readonly records: EntryRecord<TContext>[] = [];
  invalidEntryCount = 0;
  current: EntryBuilder | null = null;
  private markerSequence = 0;

  constructor(private readonly contextProvider: () => TContext) {}

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
    const context = this.contextProvider();

    if (builder === null) {
      this.invalidEntryCount += 1;
    }
    this.current = builder;
    element.onEndTag(() => {
      if (builder !== null) {
        this.records.push({ builder, context });
      }
      if (this.current === builder) {
        this.current = null;
      }
    });
  }
}

class ContentHandler<TContext> implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector<TContext>) {}

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

class AuthorHandler<TContext> implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector<TContext>) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.authorSlug = authorSlugFromHref(element.getAttribute("href"));
    }
  }
}

class AvatarHandler<TContext> implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector<TContext>) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.avatarUrl = absoluteUrl(element.getAttribute("src"));
    }
  }
}

class DateHandler<TContext> implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: EntryCollector<TContext>) {}

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
    for (const attribute of Array.from(element.attributes)) {
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

export class SharedEntryParser<TContext> {
  private readonly collector: EntryCollector<TContext>;

  constructor(contextProvider: () => TContext) {
    this.collector = new EntryCollector(contextProvider);
  }

  install(rewriter: HTMLRewriter, entrySelector: string): HTMLRewriter {
    return rewriter
      .on(entrySelector, this.collector)
      .on(`${entrySelector} .content`, new ContentHandler(this.collector))
      .on(`${entrySelector} .entry-author`, new AuthorHandler(this.collector))
      .on(`${entrySelector} img.avatar`, new AvatarHandler(this.collector))
      .on(`${entrySelector} .entry-date.permalink`, new DateHandler(this.collector))
      .on(`${entrySelector} .content script`, new RemoveElementHandler())
      .on(`${entrySelector} .content style`, new RemoveElementHandler())
      .on(`${entrySelector} .content *`, new SanitizeElementHandler());
  }

  parse(transformedHtml: string): ParsedEntryCollection<TContext> {
    let invalidEntryCount = this.collector.invalidEntryCount;
    const entries: ParsedEntryRecord<TContext>[] = [];
    for (const record of this.collector.records) {
      const entry = toEntry(record.builder, transformedHtml);
      if (entry === null) {
        invalidEntryCount += 1;
      } else {
        entries.push({ entry, context: record.context });
      }
    }
    return { entries, invalidEntryCount };
  }
}
