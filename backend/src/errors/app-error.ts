export type ErrorCode =
  | "INVALID_TOPIC_ID"
  | "INVALID_PAGE"
  | "INVALID_SORT"
  | "TOPIC_NOT_FOUND"
  | "TOPIC_FETCH_FAILED"
  | "TOPIC_PARSE_FAILED"
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
