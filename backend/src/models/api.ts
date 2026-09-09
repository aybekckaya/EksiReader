import type { Pagination, Topic } from "./topic";
import type { Entry, TopicDetail, TopicPagination, TopicSort } from "./entry";
import type { ResolvedTopic, SearchSuggestions } from "./search";
import type {
  AuthorEntriesPagination,
  AuthorEntryItem,
  AuthorProfile,
  AuthorSummary,
} from "./author";

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

export interface SearchSuggestionsResponse {
  success: true;
  data: SearchSuggestions;
}

export interface SearchResolveResponse {
  success: true;
  data: ResolvedTopic;
}

export interface AuthorProfilePayload {
  author: AuthorProfile;
}

export interface AuthorProfileData extends AuthorProfilePayload {
  cache: CacheMetadata;
}

export interface AuthorProfileResponse {
  success: true;
  data: AuthorProfileData;
}

export interface AuthorEntriesPayload {
  author: AuthorSummary;
  items: AuthorEntryItem[];
  pagination: AuthorEntriesPagination;
}

export interface AuthorEntriesData extends AuthorEntriesPayload {
  cache: CacheMetadata;
}

export interface AuthorEntriesResponse {
  success: true;
  data: AuthorEntriesData;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
}
