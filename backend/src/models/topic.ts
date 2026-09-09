export interface Topic {
  id: number;
  title: string;
  slug: string;
  entryCount: number;
}

export interface TopicMetadata {
  id: number;
  title: string;
  slug: string;
  entryCount: number | null;
}

export interface Pagination {
  currentPage: number;
  nextPage: number | null;
  hasNextPage: boolean;
}

export interface ParsedTrendingPage {
  topics: Topic[];
  pagination: Pick<Pagination, "nextPage" | "hasNextPage">;
}
