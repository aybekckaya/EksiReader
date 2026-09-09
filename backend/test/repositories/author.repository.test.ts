import { env } from "cloudflare:test";
import { beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { AuthorProfile } from "../../src/models/author";
import { AuthorRepository } from "../../src/repositories/author.repository";

const db = env.DB;
const PROFILE: AuthorProfile = {
  id: null,
  username: "sakarninja",
  slug: "sakarninja",
  avatarUrl: "https://example.com/avatar.png",
  rankText: "hippi (428)",
  registrationDateText: "mayıs 2001",
  stats: { entryCount: 2720, followerCount: 19, followingCount: 0 },
  badges: [],
};

describe("AuthorRepository", () => {
  beforeAll(async () => {
    await db.exec(
      "CREATE TABLE authors (slug TEXT PRIMARY KEY, username TEXT NOT NULL, author_id INTEGER, avatar_url TEXT, rank_text TEXT, registration_date_text TEXT, entry_count INTEGER, follower_count INTEGER, following_count INTEGER, last_seen_at INTEGER NOT NULL);\nCREATE INDEX idx_authors_author_id ON authors(author_id);\nCREATE INDEX idx_authors_username ON authors(username);",
    );
  });

  beforeEach(async () => {
    await db.prepare("DELETE FROM authors").run();
  });

  it("profile upsert edip slug ile bulur ve nullable authorId'yi korur", async () => {
    const repository = new AuthorRepository(db);
    await repository.upsertProfile(PROFILE, 100);

    await expect(repository.findBySlug("sakarninja")).resolves.toEqual({
      id: null,
      username: PROFILE.username,
      slug: PROFILE.slug,
      avatarUrl: PROFILE.avatarUrl,
      rankText: PROFILE.rankText,
      registrationDateText: PROFILE.registrationDateText,
      stats: PROFILE.stats,
    });
  });

  it("entries sonrası authorId alanını update eder", async () => {
    const repository = new AuthorRepository(db);
    await repository.upsertProfile(PROFILE, 100);

    await expect(repository.updateAuthorId("sakarninja", 9200)).resolves.toBe("updated");
    expect((await repository.findBySlug("sakarninja"))?.id).toBe(9200);
  });

  it("tutarsız bilinen authorId değerini overwrite etmez", async () => {
    const repository = new AuthorRepository(db);
    await repository.upsertProfile({ ...PROFILE, id: 9200 }, 100);

    await expect(repository.updateAuthorId("sakarninja", 9999)).resolves.toBe("conflict");
    expect((await repository.findBySlug("sakarninja"))?.id).toBe(9200);
  });

  it("incoming null alanlarla mevcut iyi metadata'yı silmez", async () => {
    const repository = new AuthorRepository(db);
    await repository.upsertProfile(PROFILE, 100);
    await repository.upsertProfile({
      ...PROFILE,
      avatarUrl: null,
      rankText: null,
      registrationDateText: null,
      stats: { entryCount: null, followerCount: null, followingCount: null },
    }, 200);

    const result = await repository.findBySlug("sakarninja");
    expect(result).toMatchObject({
      avatarUrl: PROFILE.avatarUrl,
      rankText: PROFILE.rankText,
      registrationDateText: PROFILE.registrationDateText,
      stats: PROFILE.stats,
    });
  });

  it("upsert sırasında last_seen_at değerini günceller", async () => {
    const repository = new AuthorRepository(db);
    await repository.upsertProfile(PROFILE, 100);
    await repository.upsertProfile(PROFILE, 250);

    const row = await db.prepare("SELECT last_seen_at FROM authors WHERE slug = ?1")
      .bind(PROFILE.slug)
      .first<{ last_seen_at: number }>();
    expect(row?.last_seen_at).toBe(250);
  });
});
