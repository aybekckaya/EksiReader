import { TRENDING_CACHE_TTL_SECONDS } from "../config";
import { TrendingFetchError } from "../errors/app-error";
import type { TrendingData, TrendingPayload } from "../models/api";
import { parseTrendingHtml } from "../parsers/trending.parser";
import type { CachedValue } from "../repositories/cache.repository";
import type { TopicRepository } from "../repositories/topic.repository";
import type { EksiClient } from "../clients/eksi.client";

type Clock = () => number;
type TrendingClient = Pick<EksiClient, "fetchTrendingPage">;
interface TrendingCache {
  get(key: string): Promise<CachedValue<TrendingPayload> | null>;
  put(key: string, payload: unknown, fetchedAt: number, expiresAt: number): Promise<void>;
}
type TopicStore = Pick<TopicRepository, "upsertMany">;

export class TrendingService {
  constructor(
    private readonly client: TrendingClient,
    private readonly cacheRepository: TrendingCache,
    private readonly topicRepository: TopicStore,
    private readonly clock: Clock = Date.now,
  ) {}

  async getTrending(page: number): Promise<TrendingData> {
    const cacheKey = `trending:${page}`;
    const now = Math.floor(this.clock() / 1_000);
    const cached = await this.cacheRepository.get(cacheKey);

    if (cached !== null && cached.expiresAt > now) {
      return this.toData(cached.payload, cached.fetchedAt, true, false);
    }

    let html: string;
    try {
      html = await this.client.fetchTrendingPage(page);
    } catch (error) {
      if (error instanceof TrendingFetchError && cached !== null) {
        console.error("Ekşi fetch başarısız; stale cache kullanılıyor.", error);
        return this.toData(cached.payload, cached.fetchedAt, true, true);
      }
      throw error;
    }

    const parsed = await parseTrendingHtml(html);
    const payload: TrendingPayload = {
      topics: parsed.topics,
      pagination: {
        currentPage: page,
        nextPage: parsed.pagination.nextPage,
        hasNextPage: parsed.pagination.hasNextPage,
      },
    };
    const expiresAt = now + TRENDING_CACHE_TTL_SECONDS;

    await Promise.all([
      this.topicRepository.upsertMany(parsed.topics, now),
      this.cacheRepository.put(cacheKey, payload, now, expiresAt),
    ]);

    return this.toData(payload, now, false, false);
  }

  private toData(
    payload: TrendingPayload,
    fetchedAt: number,
    cached: boolean,
    stale: boolean,
  ): TrendingData {
    return {
      ...payload,
      cache: {
        cached,
        stale,
        fetchedAt: new Date(fetchedAt * 1_000).toISOString(),
      },
    };
  }
}
