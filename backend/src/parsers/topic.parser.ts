import { TopicParseError } from "../errors/app-error";
import type {
  ParsedTopicPage,
  TopicDetail,
  TopicPagination,
} from "../models/entry";
import { normalizeDecodedText } from "../utils/text";
import { positiveInteger, SharedEntryParser } from "./shared/entry.parser";

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

export async function parseTopicHtml(html: string, requestedPage: number): Promise<ParsedTopicPage> {
  if (html.trim() === "") {
    throw new TopicParseError("HTML boş.");
  }

  const topicHandler = new TopicHandler();
  const pagerHandler = new PagerHandler();
  const entryListHandler = new PresenceHandler();
  const entryParser = new SharedEntryParser(() => undefined);

  try {
    const rewriter = new HTMLRewriter()
      .on("h1#title", topicHandler)
      .on(".pager", pagerHandler)
      .on("#entry-item-list", entryListHandler);
    const transformed = entryParser
      .install(rewriter, "#entry-item-list > li#entry-item")
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

    const entries = entryParser.parse(transformedHtml).entries.map(({ entry }) => entry);
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
