import type { Pagination, Topic } from "./topic";

export interface TrendingPayload {
  topics: Topic[];
  pagination: Pagination;
}

export interface TrendingData extends TrendingPayload {
  cache: {
    cached: boolean;
    stale: boolean;
    fetchedAt: string;
  };
}

export interface TrendingResponse {
  success: true;
  data: TrendingData;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
}
