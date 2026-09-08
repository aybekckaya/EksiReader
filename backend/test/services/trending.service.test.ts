import { describe, expect, it, vi } from "vitest";
import { TrendingFetchError, TrendingParseError } from "../../src/errors/app-error";
import type { TrendingPayload } from "../../src/models/api";
import { TrendingService } from "../../src/services/trending.service";

const NOW_MS = 1_789_000_000_000;
const SAMPLE_PAYLOAD: TrendingPayload = {
  topics: [{ id: 42, title: "örnek konu", slug: "ornek-konu", entryCount: 7 }],
  pagination: { currentPage: 1, nextPage: 2, hasNextPage: true },
};
const SAMPLE_HTML = `
  <ul class="topic-list">
    <li><a href="/ornek-konu--42?a=popular">örnek konu <small>7</small></a></li>
  </ul>
  <a id="quick-index-continue-link" href="/basliklar/gundem?p=2">devam</a>
`;

function dependencies() {
  return {
    client: { fetchTrendingPage: vi.fn().mockResolvedValue(SAMPLE_HTML) },
    cache: {
      get: vi.fn().mockResolvedValue(null),
      put: vi.fn().mockResolvedValue(undefined),
    },
    topics: { upsertMany: vi.fn().mockResolvedValue(undefined) },
  };
}

describe("TrendingService", () => {
  it("geçerli cache varken Ekşi'ye gitmez", async () => {
    const deps = dependencies();
    deps.cache.get.mockResolvedValue({
      payload: SAMPLE_PAYLOAD,
      fetchedAt: Math.floor(NOW_MS / 1_000) - 10,
      expiresAt: Math.floor(NOW_MS / 1_000) + 50,
    });
    const service = new TrendingService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTrending(1);

    expect(deps.client.fetchTrendingPage).not.toHaveBeenCalled();
    expect(result.cache).toMatchObject({ cached: true, stale: false });
  });

  it("cache miss durumunda fetch, topic batch ve cache write yapar", async () => {
    const deps = dependencies();
    const service = new TrendingService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTrending(1);

    expect(deps.client.fetchTrendingPage).toHaveBeenCalledOnce();
    expect(deps.topics.upsertMany).toHaveBeenCalledWith(SAMPLE_PAYLOAD.topics, NOW_MS / 1_000);
    expect(deps.cache.put).toHaveBeenCalledWith(
      "trending:1",
      SAMPLE_PAYLOAD,
      NOW_MS / 1_000,
      NOW_MS / 1_000 + 60,
    );
    expect(result.cache).toMatchObject({ cached: false, stale: false });
  });

  it("fetch hatasında expired cache'i stale olarak döndürür", async () => {
    const deps = dependencies();
    deps.client.fetchTrendingPage.mockRejectedValue(new TrendingFetchError("timeout"));
    deps.cache.get.mockResolvedValue({
      payload: SAMPLE_PAYLOAD,
      fetchedAt: Math.floor(NOW_MS / 1_000) - 120,
      expiresAt: Math.floor(NOW_MS / 1_000) - 60,
    });
    const service = new TrendingService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    const result = await service.getTrending(1);

    expect(result.cache).toMatchObject({ cached: true, stale: true });
    expect(deps.cache.put).not.toHaveBeenCalled();
  });

  it("cache yokken fetch hatasını dışarı taşır", async () => {
    const deps = dependencies();
    deps.client.fetchTrendingPage.mockRejectedValue(new TrendingFetchError("HTTP 500"));
    const service = new TrendingService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    await expect(service.getTrending(1)).rejects.toBeInstanceOf(TrendingFetchError);
  });

  it("HTML yapısı bozulduğunda stale veriye sessizce düşmez", async () => {
    const deps = dependencies();
    deps.client.fetchTrendingPage.mockResolvedValue("<html></html>");
    deps.cache.get.mockResolvedValue({
      payload: SAMPLE_PAYLOAD,
      fetchedAt: Math.floor(NOW_MS / 1_000) - 120,
      expiresAt: Math.floor(NOW_MS / 1_000) - 60,
    });
    const service = new TrendingService(deps.client, deps.cache, deps.topics, () => NOW_MS);

    await expect(service.getTrending(1)).rejects.toBeInstanceOf(TrendingParseError);
  });
});
