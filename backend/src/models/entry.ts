export type TopicSort = "popular";

export interface TopicDetail {
  id: number;
  title: string;
  slug: string;
  entryCount?: number;
}

export interface EntryAuthor {
  id: number;
  username: string;
  slug: string;
  avatarUrl: string | null;
}

export interface Entry {
  id: number;
  contentText: string;
  contentHtml: string;
  author: EntryAuthor;
  dateText: string;
  favoriteCount: number;
  commentCount: number;
  likeCount: number;
  permalink: string;
}

export interface TopicPagination {
  currentPage: number;
  pageCount: number;
  hasPreviousPage: boolean;
  previousPage: number | null;
  hasNextPage: boolean;
  nextPage: number | null;
}

export interface ParsedTopicPage {
  topic: TopicDetail;
  entries: Entry[];
  pagination: TopicPagination;
}
