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
  | "INVALID_AUTHOR_SLUG"
  | "AUTHOR_NOT_FOUND"
  | "AUTHOR_FETCH_FAILED"
  | "AUTHOR_PARSE_FAILED"
  | "AUTHOR_ENTRIES_FETCH_FAILED"
  | "AUTHOR_ENTRIES_PARSE_FAILED"
  | "AUTHOR_SOURCE_CHALLENGE"
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

export class AuthorNotFoundError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_NOT_FOUND", 404, "Yazar bulunamadı.", options);
    this.name = "AuthorNotFoundError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class AuthorFetchError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_FETCH_FAILED", 502, "Yazar profili alınamadı.", options);
    this.name = "AuthorFetchError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class AuthorParseError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_PARSE_FAILED", 502, "Yazar profili işlenemedi.", options);
    this.name = "AuthorParseError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class AuthorEntriesFetchError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_ENTRIES_FETCH_FAILED", 502, "Yazar entry'leri alınamadı.", options);
    this.name = "AuthorEntriesFetchError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class AuthorEntriesParseError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_ENTRIES_PARSE_FAILED", 502, "Yazar entry'leri işlenemedi.", options);
    this.name = "AuthorEntriesParseError";
    Object.defineProperty(this, "message", { value: message });
  }
}

export class AuthorSourceChallengeError extends AppError {
  constructor(message: string, options?: ErrorOptions) {
    super("AUTHOR_SOURCE_CHALLENGE", 502, "Yazar kaynağı şu anda kullanılamıyor.", options);
    this.name = "AuthorSourceChallengeError";
    Object.defineProperty(this, "message", { value: message });
  }
}
