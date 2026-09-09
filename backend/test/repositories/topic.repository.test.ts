import { env } from "cloudflare:test";
import { beforeAll, beforeEach, describe, expect, it } from "vitest";
import { TopicRepository } from "../../src/repositories/topic.repository";

const db = env.DB;

describe("TopicRepository search", () => {
  beforeAll(async () => {
    await db.exec(
      "CREATE TABLE topics (id INTEGER PRIMARY KEY, title TEXT NOT NULL, slug TEXT NOT NULL, entry_count INTEGER NOT NULL DEFAULT 0, last_seen_at INTEGER NOT NULL, entry_count_known INTEGER NOT NULL DEFAULT 1, search_title TEXT);\nCREATE INDEX idx_topics_search_title ON topics(search_title);",
    );
  });

  beforeEach(async () => {
    await db.prepare("DELETE FROM topics").run();
  });

  it("exact match'i daha yeni prefix sonuçlarından önce sıralar", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertMany([
      { id: 1, title: "kad", slug: "kad", entryCount: 3 },
    ], 100);
    await repository.upsertMany([
      { id: 2, title: "kadın", slug: "kadin", entryCount: 4 },
    ], 200);

    const result = await repository.searchTopics("kad", 10);

    expect(result.map((topic) => topic.id)).toEqual([1, 2]);
  });

  it("Türkçe normalize edilmiş prefix search yapar", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertMany([
      { id: 1, title: "Kadın yazarlar", slug: "kadin-yazarlar", entryCount: 12 },
      { id: 2, title: "başka konu", slug: "baska-konu", entryCount: 5 },
    ], 100);

    const result = await repository.searchTopics("kadin", 10);

    expect(result).toEqual([{
      id: 1,
      title: "Kadın yazarlar",
      slug: "kadin-yazarlar",
      entryCount: 12,
    }]);
  });

  it("prefix sonucu yoksa contains fallback çalıştırır", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertMany([
      {
        id: 1,
        title: "8 eylül 2026 real madrid inter maçı",
        slug: "8-eylul-2026-real-madrid-inter-maci",
        entryCount: 100,
      },
    ], 100);

    const result = await repository.searchTopics("madrid", 10);

    expect(result[0]?.id).toBe(1);
  });

  it("sonuç sayısını en fazla 10 ile sınırlar", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertMany(
      Array.from({ length: 12 }, (_, index) => ({
        id: index + 1,
        title: `test konu ${index}`,
        slug: `test-konu-${index}`,
        entryCount: index,
      })),
      100,
    );

    const result = await repository.searchTopics("test", 50);

    expect(result).toHaveLength(10);
  });

  it("trending topic upsert sırasında search_title yazar", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertMany([
      { id: 1, title: "İstanbul Gündemi", slug: "istanbul-gundemi", entryCount: 8 },
    ], 100);

    const row = await db.prepare("SELECT search_title FROM topics WHERE id = 1")
      .first<{ search_title: string }>();

    expect(row?.search_title).toBe("istanbul gundemi");
  });

  it("resolve topic upsert search_title yazar ve bilinmeyen entryCount'u null döndürür", async () => {
    const repository = new TopicRepository(db);
    await repository.upsertResolvedTopic({
      id: 6994477,
      title: "4 ağustos 2021 güney kore türkiye voleybol maçı",
      slug: "4-agustos-2021-guney-kore-turkiye-voleybol-maci",
    }, 100);

    const result = await repository.searchTopics("4 agustos", 10);

    expect(result).toEqual([{
      id: 6994477,
      title: "4 ağustos 2021 güney kore türkiye voleybol maçı",
      slug: "4-agustos-2021-guney-kore-turkiye-voleybol-maci",
      entryCount: null,
    }]);
  });
});
