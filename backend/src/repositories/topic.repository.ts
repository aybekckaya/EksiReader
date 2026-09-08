import type { Topic } from "../models/topic";

interface TopicRow {
  id: number;
  title: string;
  slug: string;
  entry_count: number;
}

export class TopicRepository {
  constructor(private readonly db: D1Database) {}

  async findTopicById(id: number): Promise<Topic | null> {
    const row = await this.db
      .prepare("SELECT id, title, slug, entry_count FROM topics WHERE id = ?1")
      .bind(id)
      .first<TopicRow>();

    return row === null
      ? null
      : {
          id: row.id,
          title: row.title,
          slug: row.slug,
          entryCount: row.entry_count,
        };
  }

  async upsertMany(topics: Topic[], lastSeenAt: number): Promise<void> {
    if (topics.length === 0) {
      return;
    }

    const statement = this.db.prepare(
      `INSERT INTO topics (id, title, slug, entry_count, last_seen_at)
       VALUES (?1, ?2, ?3, ?4, ?5)
       ON CONFLICT(id) DO UPDATE SET
         title = excluded.title,
         slug = excluded.slug,
         entry_count = excluded.entry_count,
         last_seen_at = excluded.last_seen_at`,
    );

    await this.db.batch(
      topics.map((topic) =>
        statement.bind(topic.id, topic.title, topic.slug, topic.entryCount, lastSeenAt),
      ),
    );
  }
}
