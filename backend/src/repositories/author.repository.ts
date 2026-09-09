import type { AuthorMetadata, AuthorProfile } from "../models/author";

interface AuthorRow {
  slug: string;
  username: string;
  author_id: number | null;
  avatar_url: string | null;
  rank_text: string | null;
  registration_date_text: string | null;
  entry_count: number | null;
  follower_count: number | null;
  following_count: number | null;
}

export type AuthorIdUpdateResult = "updated" | "unchanged" | "conflict" | "missing";

export class AuthorRepository {
  constructor(private readonly db: D1Database) {}

  async findBySlug(slug: string): Promise<AuthorMetadata | null> {
    const row = await this.db
      .prepare(
        `SELECT slug, username, author_id, avatar_url, rank_text,
                registration_date_text, entry_count, follower_count, following_count
         FROM authors
         WHERE slug = ?1`,
      )
      .bind(slug)
      .first<AuthorRow>();

    return row === null ? null : this.toMetadata(row);
  }

  async upsertProfile(profile: AuthorProfile, lastSeenAt: number): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO authors (
           slug, username, author_id, avatar_url, rank_text, registration_date_text,
           entry_count, follower_count, following_count, last_seen_at
         ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)
         ON CONFLICT(slug) DO UPDATE SET
           username = excluded.username,
           author_id = COALESCE(excluded.author_id, authors.author_id),
           avatar_url = COALESCE(excluded.avatar_url, authors.avatar_url),
           rank_text = COALESCE(excluded.rank_text, authors.rank_text),
           registration_date_text = COALESCE(
             excluded.registration_date_text,
             authors.registration_date_text
           ),
           entry_count = COALESCE(excluded.entry_count, authors.entry_count),
           follower_count = COALESCE(excluded.follower_count, authors.follower_count),
           following_count = COALESCE(excluded.following_count, authors.following_count),
           last_seen_at = excluded.last_seen_at`,
      )
      .bind(
        profile.slug,
        profile.username,
        profile.id,
        profile.avatarUrl,
        profile.rankText,
        profile.registrationDateText,
        profile.stats.entryCount,
        profile.stats.followerCount,
        profile.stats.followingCount,
        lastSeenAt,
      )
      .run();
  }

  async updateAuthorId(slug: string, authorId: number): Promise<AuthorIdUpdateResult> {
    const current = await this.findBySlug(slug);
    if (current === null) {
      return "missing";
    }
    if (current.id === authorId) {
      return "unchanged";
    }
    if (current.id !== null) {
      return "conflict";
    }

    await this.db
      .prepare("UPDATE authors SET author_id = ?2 WHERE slug = ?1 AND author_id IS NULL")
      .bind(slug, authorId)
      .run();
    return "updated";
  }

  private toMetadata(row: AuthorRow): AuthorMetadata {
    return {
      id: row.author_id,
      username: row.username,
      slug: row.slug,
      avatarUrl: row.avatar_url,
      rankText: row.rank_text,
      registrationDateText: row.registration_date_text,
      stats: {
        entryCount: row.entry_count,
        followerCount: row.follower_count,
        followingCount: row.following_count,
      },
    };
  }
}
