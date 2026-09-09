import type { Entry } from "./entry";

export interface AuthorProfileStats {
  entryCount: number | null;
  followerCount: number | null;
  followingCount: number | null;
}

export interface AuthorBadge {
  name: string;
  description: string | null;
  imageUrl: string | null;
}

export interface AuthorProfile {
  id: number | null;
  username: string;
  slug: string;
  avatarUrl: string | null;
  rankText: string | null;
  registrationDateText: string | null;
  stats: AuthorProfileStats;
  badges: AuthorBadge[];
}

export type AuthorMetadata = Omit<AuthorProfile, "badges">;

export interface AuthorSummary {
  id: number | null;
  username: string;
  slug: string;
}

export interface AuthorEntryTopic {
  id: number;
  title: string;
  slug: string;
}

export interface AuthorEntryItem {
  topic: AuthorEntryTopic;
  entry: Entry;
}

export interface AuthorEntriesPagination {
  currentPage: number;
  hasPreviousPage: boolean;
  previousPage: number | null;
  hasNextPage: boolean;
  nextPage: number | null;
}

export interface ParsedAuthorEntries {
  items: AuthorEntryItem[];
  pagination: AuthorEntriesPagination;
}
