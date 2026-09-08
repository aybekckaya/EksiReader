import type { Topic } from "../models/topic";

export class TopicRepository {
  constructor(private readonly db: D1Database) {}

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
