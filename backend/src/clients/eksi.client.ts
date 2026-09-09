import {
  EKSI_BASE_URL,
  EKSI_REQUEST_TIMEOUT_MS,
} from "../config";
import {
  AuthorEntriesFetchError,
  AuthorFetchError,
  AuthorNotFoundError,
  AuthorSourceChallengeError,
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
  | SearchResolveError
  | AuthorFetchError
  | AuthorEntriesFetchError;
type ErrorFactory = (message: string, options?: ErrorOptions) => UpstreamError;

const REDIRECT_STATUSES = new Set([301, 302, 303, 307, 308]);
const CLOUDFLARE_CHALLENGE_HTML = [
  /<title>\s*just a moment(?:\.\.\.)?\s*<\/title>/iu,
  /\bchallenge-platform\b/iu,
  /\b_cf_chl_opt\b/iu,
  /\bchallenge-error-text\b/iu,
];

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

  async fetchAuthorProfile(authorSlug: string): Promise<string> {
    const url = new URL(`/biri/${encodeURIComponent(authorSlug)}`, EKSI_BASE_URL);
    return this.fetchAuthorHtml(
      url,
      (message, options) => new AuthorFetchError(message, options),
      true,
    );
  }

  async fetchAuthorEntries(username: string, page: number): Promise<string> {
    const url = new URL("/son-entryleri", EKSI_BASE_URL);
    url.searchParams.set("nick", username);
    url.searchParams.set("p", String(page));
    return this.fetchAuthorHtml(
      url,
      (message, options) => new AuthorEntriesFetchError(message, options),
      false,
      { "X-Requested-With": "XMLHttpRequest" },
    );
  }

  private async fetchAuthorHtml(
    url: URL,
    createError: ErrorFactory,
    profileRequest: boolean,
    additionalHeaders?: HeadersInit,
  ): Promise<string> {
    const response = await this.fetchResponse(
      url,
      "text/html,application/xhtml+xml",
      createError,
      undefined,
      additionalHeaders,
    );

    if (
      response.status === 403
      && response.headers.get("cf-mitigated")?.toLowerCase() === "challenge"
    ) {
      throw new AuthorSourceChallengeError("Ekşi yazar isteği Managed Challenge aldı.");
    }
    if (profileRequest && response.status === 404) {
      throw new AuthorNotFoundError("Ekşi yazar profili HTTP 404 döndürdü.");
    }

    const contentType = response.headers.get("content-type") ?? "";
    const isHtml = contentType.toLowerCase().includes("text/html");
    const html = isHtml ? await response.text() : "";
    if (CLOUDFLARE_CHALLENGE_HTML.some((pattern) => pattern.test(html))) {
      throw new AuthorSourceChallengeError("Ekşi yazar isteği challenge HTML'i döndürdü.");
    }
    if (response.status !== 200) {
      throw createError(`Ekşi HTTP ${response.status} döndürdü.`);
    }
    if (!isHtml) {
      throw createError(`Beklenmeyen Content-Type: ${contentType || "yok"}.`);
    }
    if (html.trim() === "") {
      throw createError("Ekşi boş HTML döndürdü.");
    }
    return html;
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
    additionalHeaders?: HeadersInit,
  ): Promise<Response> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      return await this.fetchImplementation(url, {
        headers: {
          Accept: accept,
          "Accept-Language": "tr-TR,tr;q=0.9",
          "User-Agent": "EksiReader/1.0 (public read-only API)",
          ...additionalHeaders,
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
