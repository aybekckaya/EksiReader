export type ErrorCode =
  | "INVALID_TOPIC_ID"
  | "INVALID_PAGE"
  | "INVALID_SORT"
  | "TOPIC_NOT_FOUND"
  | "TOPIC_FETCH_FAILED"
  | "TOPIC_PARSE_FAILED"
  | "INVALID_SEARCH_QUERY"
  | "SEARCH_SUGGESTIONS_FAILED"
  | "SEARCH_RESOLVE_FAILED"
  | "SEARCH_RESOLVE_NOT_FOUND"
  | "SEARCH_RESOLVE_UNAVAILABLE"
  | "AUTHOR_RESOLVE_NOT_SUPPORTED"
  | "TRENDING_FETCH_FAILED"
  | "TRENDING_PARSE_FAILED"
  | "INTERNAL_ERROR"
  | "NOT_FOUND";

export class AppError extends Error {
  constructor(
    public readonly code: ErrorCode,
    public readonly status: number,
    public readonly publicMessage: string,
    options?: ErrorOptions,
  ) {
    super(publicMessage, options);
    this.name = "AppError";
  }
}

export class TrendingFetchError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("TRENDING_FETCH_FAILED", 502, "Gündem verisi alınamadı.", options);
    this.name = "TrendingFetchError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class TrendingParseError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("TRENDING_PARSE_FAILED", 502, "Gündem verisi işlenemedi.", options);
    this.name = "TrendingParseError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class TopicFetchError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("TOPIC_FETCH_FAILED", 502, "Başlık verisi alınamadı.", options);
    this.name = "TopicFetchError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class TopicParseError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("TOPIC_PARSE_FAILED", 502, "Başlık verisi işlenemedi.", options);
    this.name = "TopicParseError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class SearchSuggestionsError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("SEARCH_SUGGESTIONS_FAILED", 502, "Arama önerileri alınamadı.", options);
    this.name = "SearchSuggestionsError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class SearchResolveError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("SEARCH_RESOLVE_FAILED", 502, "Başlık çözümlenemedi.", options);
    this.name = "SearchResolveError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class SearchResolveNotFoundError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("SEARCH_RESOLVE_NOT_FOUND", 404, "Arama sonucu başlığa çözümlenemedi.", options);
    this.name = "SearchResolveNotFoundError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class SearchResolveUnavailableError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("SEARCH_RESOLVE_UNAVAILABLE", 503, "Arama şu anda kullanılamıyor.", options);
    this.name = "SearchResolveUnavailableError";
    Object.defineProperty(this, "message", { value: message });
  }
}
