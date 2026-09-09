import { afterEach, describe, expect, it, vi } from "vitest";
import { TopicFetchError } from "../../src/errors/app-error";
import type { TopicPayload } from "../../src/models/api";
import type { TopicMetadata } from "../../src/models/topic";
import type { CachedValue } from "../../src/repositories/cache.repository";
import { TopicService } from "../../src/services/topic.service";
import topicHtml from "../fixtures/topic.html?raw";

const NOW_MS = 1_789_000_000_000;
const NOW_SECONDS = NOW_MS / 1_000;
const TOPIC: TopicMetadata = {
  id: 8136443,
  title: "8 eylül 2026 real madrid inter maçı",
  slug: "8-eylul-2026-real-madrid-inter-maci",
  entryCount: 229,
};
const CACHED_PAYLOAD: TopicPayload = {
  topic: { ...TOPIC, entryCount: 229 },
  entries: [{
    id: 186257381,
    contentText: "örnek",
    contentHtml: "örnek",
    author: { id: 1200425, username: "yazar", slug: "yazar", avatarUrl: null },
    dateText: "08.09.2026 19:50",
    favoriteCount: 0,
    commentCount: 0,
    likeCount: 0,
    permalink: "https://eksisozluk.com/entry/186257381",
  }],
  pagination: {
    currentPage: 1,
    pageCount: 1,
    hasPreviousPage: false,
    previousPage: null,
    hasNextPage: false,
    nextPage: null,
  },
  sort: "popular",
};

function dependencies(initialCache: CachedValue<TopicPayload> | null = null) {
  const cacheState = { value: initialCache };
  return {
    client: { fetchTopicPage: vi.fn().mockResolvedValue(topicHtml) },
    cache: {
      get: vi.fn(async (): Promise<CachedValue<TopicPayload> | null> => cacheState.value),
      put: vi.fn().mockResolvedValue(undefined),
    },
    topics: {
      findTopicById: vi.fn().mockResolvedValue(TOPIC),
      upsertResolvedTopic: vi.fn().mockResolvedValue(undefined),
    },
  };
}

describe("TopicService", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fresh cache varken upstream fetch yapmaz", async () => {
    const deps = dependencies({
      payload: CACHED_PAYLOAD,
      fetchedAt: NOW_SECONDS - 10,
      expiresAt: NOW_SECONDS + 50,
    });
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTopic(TOPIC.id, 1, "popular");

    expect(deps.client.fetchTopicPage).not.toHaveBeenCalled();
    expect(result.cache).toMatchObject({ cached: true, stale: false });
  });

  it("expired cache ardından başarılı fetch ve cache write yapar", async () => {
    const deps = dependencies({
      payload: CACHED_PAYLOAD,
      fetchedAt: NOW_SECONDS - 120,
      expiresAt: NOW_SECONDS - 60,
    });
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTopic(TOPIC.id, 1, "popular");

    expect(deps.client.fetchTopicPage).toHaveBeenCalledOnce();
    expect(deps.client.fetchTopicPage).toHaveBeenCalledWith(TOPIC.slug, TOPIC.id, 1, "popular");
    expect(deps.cache.put).toHaveBeenCalledWith(
      `topic:${TOPIC.id}:popular:1`,
      expect.objectContaining({ sort: "popular" }),
      NOW_SECONDS,
      NOW_SECONDS + 60,
    );
    expect(result).toMatchObject({
      topic: { id: TOPIC.id, entryCount: 229 },
      cache: { cached: false, stale: false },
    });
  });

  it("expired cache ve fetch hatasında stale cache döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies({
      payload: CACHED_PAYLOAD,
      fetchedAt: NOW_SECONDS - 120,
      expiresAt: NOW_SECONDS - 60,
    });
    deps.client.fetchTopicPage.mockRejectedValue(new TopicFetchError("timeout"));
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTopic(TOPIC.id, 1, "popular");

    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("cache yokken fetch hatasını kontrollü biçimde dışarı taşır", async () => {
    const deps = dependencies();
    deps.client.fetchTopicPage.mockRejectedValue(new TopicFetchError("HTTP 500"));
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    await expect(service.getTopic(TOPIC.id, 1, "popular"))
      .rejects.toMatchObject({ code: "TOPIC_FETCH_FAILED", status: 502 });
  });

  it("topic D1'de bulunamazsa 404 döndürecek hata üretir", async () => {
    const deps = dependencies();
    deps.topics.findTopicById.mockResolvedValue(null);
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    await expect(service.getTopic(TOPIC.id, 1, "popular"))
      .rejects.toMatchObject({ code: "TOPIC_NOT_FOUND", status: 404 });
    expect(deps.client.fetchTopicPage).not.toHaveBeenCalled();
  });

  it("parser hatasında expired cache'i stale olarak döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies({
      payload: CACHED_PAYLOAD,
      fetchedAt: NOW_SECONDS - 120,
      expiresAt: NOW_SECONDS - 60,
    });
    deps.client.fetchTopicPage.mockResolvedValue("<html>değişmiş yapı</html>");
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTopic(TOPIC.id, 1, "popular");

    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("entry count bilinmiyorsa response'a sahte sıfır eklemez", async () => {
    const deps = dependencies();
    deps.topics.findTopicById.mockResolvedValue({ ...TOPIC, entryCount: null });
    const service = new TopicService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTopic(TOPIC.id, 1, "popular");

    expect(result.topic).not.toHaveProperty("entryCount");
  });
});
