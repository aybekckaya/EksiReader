import type { SearchTopicSuggestion } from "../models/search";
import type { Topic, TopicMetadata } from "../models/topic";
import { normalizeSearchText } from "../utils/search";

interface TopicRow {
  id: number;
  title: string;
  slug: string;
  entry_count: number;
  entry_count_known: number;
}

function escapeLikePattern(value: string): string {
  return value.replace(/[\\%_]/gu, (character) => `\\${character}`);
}

export class TopicRepository {
  constructor(private readonly db: D1Database) {}

  async findTopicById(id: number): Promise<TopicMetadata | null> {
    const row = await this.db
      .prepare(
        "SELECT id, title, slug, entry_count, entry_count_known FROM topics WHERE id = ?1",
      )
      .bind(id)
      .first<TopicRow>();

    return row === null
      ? null
      : {
          id: row.id,
          title: row.title,
          slug: row.slug,
          entryCount: row.entry_count_known === 1 ? row.entry_count : null,
        };
  }

  async upsertResolvedTopic(
    topic: Pick<Topic, "id" | "title" | "slug">,
    lastSeenAt: number,
  ): Promise<void> {
    await this.upsertManyResolvedTopics([topic], lastSeenAt);
  }

  async upsertManyResolvedTopics(
    topics: Pick<Topic, "id" | "title" | "slug">[],
    lastSeenAt: number,
  ): Promise<void> {
    if (topics.length === 0) {
      return;
    }

    const statement = this.db.prepare(
        `INSERT INTO topics (
           id, title, slug, entry_count, last_seen_at, entry_count_known, search_title
         ) VALUES (?1, ?2, ?3, 0, ?4, 0, ?5)
         ON CONFLICT(id) DO UPDATE SET
           title = excluded.title,
           slug = excluded.slug,
           search_title = excluded.search_title,
           last_seen_at = excluded.last_seen_at`,
    );
    await this.db.batch(
      topics.map((topic) => statement.bind(
        topic.id,
        topic.title,
        topic.slug,
        lastSeenAt,
        normalizeSearchText(topic.title),
      )),
    );
  }

  async searchTopics(normalizedQuery: string, limit: number): Promise<SearchTopicSuggestion[]> {
    const safeLimit = Math.min(Math.max(Math.trunc(limit), 1), 10);
    const escapedQuery = escapeLikePattern(normalizedQuery);
    const prefixRows = await this.searchByPattern(
      `${escapedQuery}%`,
      normalizedQuery,
      safeLimit,
    );
    if (prefixRows.length > 0) {
      return prefixRows.map((row) => this.toSearchSuggestion(row));
    }

    const containsRows = await this.searchByPattern(
      `%${escapedQuery}%`,
      normalizedQuery,
      safeLimit,
    );
    return containsRows.map((row) => this.toSearchSuggestion(row));
  }

  async upsertMany(topics: Topic[], lastSeenAt: number): Promise<void> {
    if (topics.length === 0) {
      return;
    }

    const statement = this.db.prepare(
      `INSERT INTO topics (id, title, slug, entry_count, last_seen_at, search_title)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6)
       ON CONFLICT(id) DO UPDATE SET
         title = excluded.title,
         slug = excluded.slug,
         entry_count = excluded.entry_count,
         entry_count_known = 1,
         search_title = excluded.search_title,
         last_seen_at = excluded.last_seen_at`,
    );

    await this.db.batch(
      topics.map((topic) =>
        statement.bind(
          topic.id,
          topic.title,
          topic.slug,
          topic.entryCount,
          lastSeenAt,
          normalizeSearchText(topic.title),
        ),
      ),
    );
  }

  private async searchByPattern(
    pattern: string,
    normalizedQuery: string,
    limit: number,
  ): Promise<TopicRow[]> {
    const result = await this.db
      .prepare(
        `SELECT id, title, slug, entry_count, entry_count_known
         FROM topics
         WHERE search_title LIKE ?1 ESCAPE '\\'
         ORDER BY
           CASE WHEN search_title = ?2 THEN 0 ELSE 1 END,
           last_seen_at DESC
         LIMIT ?3`,
      )
      .bind(pattern, normalizedQuery, limit)
      .all<TopicRow>();
    return result.results;
  }

  private toSearchSuggestion(row: TopicRow): SearchTopicSuggestion {
    return {
      id: row.id,
      title: row.title,
      slug: row.slug,
      entryCount: row.entry_count_known === 1 ? row.entry_count : null,
    };
  }
}
