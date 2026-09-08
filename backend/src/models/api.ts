import type { Pagination, Topic } from "./topic";
import type { Entry, TopicDetail, TopicPagination, TopicSort } from "./entry";

export interface CacheMetadata {
  cached: boolean;
  stale: boolean;
  fetchedAt: string;
}

export interface TrendingPayload {
  topics: Topic[];
  pagination: Pagination;
}

export interface TrendingData extends TrendingPayload {
  cache: CacheMetadata;
}

export interface TrendingResponse {
  success: true;
  data: TrendingData;
}

export interface TopicPayload {
  topic: TopicDetail;
  entries: Entry[];
  pagination: TopicPagination;
  sort: TopicSort;
}

export interface TopicData extends TopicPayload {
  cache: CacheMetadata;
}

export interface TopicResponse {
  success: true;
  data: TopicData;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
}
