import { AuthorEntriesParseError } from "../errors/app-error";
import type {
  AuthorEntryTopic,
  ParsedAuthorEntries,
} from "../models/author";
import { normalizeDecodedText } from "../utils/text";
import { positiveInteger, SharedEntryParser } from "./shared/entry.parser";

interface TopicContext {
  topic: AuthorEntryTopic | null;
}

export interface AuthorEntriesParseOptions {
  requestedPage: number;
  authorSlug: string;
  expectedUsername: string;
}

class TopicItemCollector implements HTMLRewriterElementContentHandlers {
  readonly items: TopicContext[] = [];
  current: TopicContext | null = null;

  element(element: Element): void {
    const context: TopicContext = { topic: null };
    this.current = context;
    this.items.push(context);
    element.onEndTag(() => {
      if (this.current === context) {
        this.current = null;
      }
    });
  }
}

class TopicTitleHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: TopicItemCollector) {}

  element(element: Element): void {
    const context = this.collector.current;
    if (context === null) {
      return;
    }
    const id = positiveInteger(element.getAttribute("data-id"));
    const title = normalizeDecodedText(element.getAttribute("data-title") ?? "");
    const slug = element.getAttribute("data-slug")?.trim() ?? "";
    if (id !== null && title !== "" && slug !== "") {
      context.topic = { id, title, slug };
    }
  }
}

function comparableUsername(value: string): string {
  return normalizeDecodedText(value).toLocaleLowerCase("tr-TR");
}

export async function parseAuthorEntries(
  html: string,
  options: AuthorEntriesParseOptions,
): Promise<ParsedAuthorEntries> {
  if (html.trim() === "") {
    throw new AuthorEntriesParseError("HTML boş.");
  }

  const topicItems = new TopicItemCollector();
  const entryParser = new SharedEntryParser(() => topicItems.current);
  const hasNoMoreData = /\bno-more-data\b/iu.test(html);

  try {
    const rewriter = new HTMLRewriter()
      .on(".topic-item", topicItems)
      .on(".topic-item h1#title", new TopicTitleHandler(topicItems));
    const transformed = entryParser
      .install(rewriter, ".topic-item #entry-item-list > li#entry-item")
      .transform(new Response(html));
    const transformedHtml = await transformed.text();
    const parsedEntries = entryParser.parse(transformedHtml);

    if (topicItems.items.some(({ topic }) => topic === null)) {
      throw new AuthorEntriesParseError("Topic metadata'sı eksik veya geçersiz.");
    }
    if (parsedEntries.invalidEntryCount > 0) {
      throw new AuthorEntriesParseError("Entry metadata'sı eksik veya geçersiz.");
    }
    if (parsedEntries.entries.length === 0 && !hasNoMoreData) {
      throw new AuthorEntriesParseError("Beklenmeyen boş author entries response'u.");
    }

    const expectedUsername = comparableUsername(options.expectedUsername);
    const items = parsedEntries.entries.map(({ entry, context }) => {
      if (context?.topic === null || context === null) {
        throw new AuthorEntriesParseError("Entry bir topic ile eşleştirilemedi.");
      }
      if (comparableUsername(entry.author.username) !== expectedUsername) {
        throw new AuthorEntriesParseError(
          `Entry yazarı beklenen profile ait değil: ${options.authorSlug}.`,
        );
      }
      return { topic: context.topic, entry };
    });

    const hasPreviousPage = options.requestedPage > 1;
    const hasNextPage = !hasNoMoreData && items.length > 0;
    return {
      items,
      pagination: {
        currentPage: options.requestedPage,
        hasPreviousPage,
        previousPage: hasPreviousPage ? options.requestedPage - 1 : null,
        hasNextPage,
        nextPage: hasNextPage ? options.requestedPage + 1 : null,
      },
    };
  } catch (error) {
    if (error instanceof AuthorEntriesParseError) {
      throw error;
    }
    throw new AuthorEntriesParseError("HTMLRewriter author entries HTML'ini işleyemedi.", {
      cause: error,
    });
  }
}
