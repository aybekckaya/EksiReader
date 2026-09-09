import {
  EKSI_BASE_URL,
  EKSI_REQUEST_TIMEOUT_MS,
} from "../config";
import {
  SearchResolveError,
  SearchResolveNotFoundError,
  SearchResolveUnavailableError,
  TopicFetchError,
  TrendingFetchError,
} from "../errors/app-error";
import type { TopicSort } from "../models/entry";

export type FetchImplementation = typeof fetch;
type UpstreamError =
  | TrendingFetchError
  | TopicFetchError
  | SearchResolveError;
type ErrorFactory = (message: string, options?: ErrorOptions) => UpstreamError;

const REDIRECT_STATUSES = new Set([301, 302, 303, 307, 308]);

export class EksiClient {
  constructor(
    private readonly fetchImplementation: FetchImplementation = (input, init) => fetch(input, init),
    private readonly timeoutMs = EKSI_REQUEST_TIMEOUT_MS,
  ) {}

  async fetchTrendingPage(page: number): Promise<string> {
    const url = new URL("/basliklar/gundem", EKSI_BASE_URL);
    if (page > 1) {
      url.searchParams.set("p", String(page));
    }

    return this.fetchHtml(url, (message, options) => new TrendingFetchError(message, options));
  }

  async fetchTopicPage(
    slug: string,
    topicId: number,
    page: number,
    sort: TopicSort,
  ): Promise<string> {
    const url = new URL(`/${slug}--${topicId}`, EKSI_BASE_URL);
    url.searchParams.set("a", sort);
    if (page > 1) {
      url.searchParams.set("p", String(page));
    }

    return this.fetchHtml(url, (message, options) => new TopicFetchError(message, options));
  }

  async fetchSearchResolveLocation(query: string): Promise<string> {
    const url = new URL("/", EKSI_BASE_URL);
    url.searchParams.set("q", query);
    const createError: ErrorFactory = (message, options) =>
      new SearchResolveError(message, options);
    const response = await this.fetchResponse(
      url,
      "text/html,application/xhtml+xml",
      createError,
      "manual",
    );

    if (response.status === 200) {
      throw new SearchResolveNotFoundError("Ekşi redirect yerine search result HTML döndürdü.");
    }
    if (
      response.status === 403
      && response.headers.get("cf-mitigated")?.toLowerCase() === "challenge"
    ) {
      throw new SearchResolveUnavailableError("Ekşi resolve isteği Managed Challenge aldı.");
    }
    if (!REDIRECT_STATUSES.has(response.status)) {
      throw createError(`Ekşi resolve HTTP ${response.status} döndürdü.`);
    }
    const location = response.headers.get("location");
    if (location === null || location.trim() === "") {
      throw createError("Ekşi resolve response Location header içermiyor.");
    }
    return location;
  }

  private async fetchHtml(
    url: URL,
    createError: ErrorFactory,
  ): Promise<string> {
    const response = await this.fetchResponse(
      url,
      "text/html,application/xhtml+xml",
      createError,
    );

    if (response.status !== 200) {
      throw createError(`Ekşi HTTP ${response.status} döndürdü.`);
    }

    const contentType = response.headers.get("content-type") ?? "";
    if (!contentType.toLowerCase().includes("text/html")) {
      throw createError(`Beklenmeyen Content-Type: ${contentType || "yok"}.`);
    }

    const html = await response.text();
    if (html.trim().length === 0) {
      throw createError("Ekşi boş HTML döndürdü.");
    }

    return html;
  }

  private async fetchResponse(
    url: URL,
    accept: string,
    createError: ErrorFactory,
    redirect?: RequestInit["redirect"],
  ): Promise<Response> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      return await this.fetchImplementation(url, {
        headers: {
          Accept: accept,
          "Accept-Language": "tr-TR,tr;q=0.9",
          "User-Agent": "EksiReader/1.0 (public read-only API)",
        },
        redirect,
        signal: controller.signal,
      });
    } catch (error) {
      const reason = error instanceof Error ? error.message : "Bilinmeyen network hatası";
      throw createError(`Ekşi isteği başarısız: ${reason}.`, { cause: error });
    } finally {
      clearTimeout(timeout);
    }
  }

}
