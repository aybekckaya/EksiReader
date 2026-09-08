import type { EksiClient } from "../clients/eksi.client";
import { TOPIC_CACHE_TTL_SECONDS } from "../config";
import {
  AppError,
  TopicFetchError,
  TopicParseError,
} from "../errors/app-error";
import type { TopicData, TopicPayload } from "../models/api";
import type { TopicSort } from "../models/entry";
import type { Topic } from "../models/topic";
import { parseTopicHtml } from "../parsers/topic.parser";
import type { CachedValue } from "../repositories/cache.repository";

type Clock = () => number;

interface TopicClient {
  fetchTopicPage(slug: string, topicId: number, page: number, sort: TopicSort): Promise<string>;
}

interface TopicCache {
  get(key: string): Promise<CachedValue<TopicPayload> | null>;
  put(key: string, payload: unknown, fetchedAt: number, expiresAt: number): Promise<void>;
}

interface TopicStore {
  findTopicById(id: number): Promise<Topic | null>;
}

export class TopicService {
  constructor(
    private readonly client: TopicClient | Pick<EksiClient, "fetchTopicPage">,
    private readonly cacheRepository: TopicCache,
    private readonly topicRepository: TopicStore,
    private readonly clock: Clock = Date.now,
  ) {}

  async getTopic(topicId: number, page: number, sort: TopicSort): Promise<TopicData> {
    const metadata = await this.topicRepository.findTopicById(topicId);
    if (metadata === null) {
      throw new AppError("TOPIC_NOT_FOUND", 404, "Başlık bulunamadı.");
    }

    const cacheKey = `topic:${topicId}:${sort}:${page}`;
    const now = Math.floor(this.clock() / 1_000);
    const cached = await this.cacheRepository.get(cacheKey);
    if (cached !== null && cached.expiresAt > now) {
      return this.toData(cached, true, false);
    }

    let payload: TopicPayload;
    try {
      const html = await this.client.fetchTopicPage(metadata.slug, topicId, page, sort);
      const parsed = await parseTopicHtml(html, page);
      if (parsed.topic.id !== topicId) {
        throw new TopicParseError(
          `Topic kimliği eşleşmedi: beklenen ${topicId}, gelen ${parsed.topic.id}.`,
        );
      }
      payload = {
        topic: {
          ...parsed.topic,
          entryCount: metadata.entryCount,
        },
        entries: parsed.entries,
        pagination: parsed.pagination,
        sort,
      };
    } catch (error) {
      if (
        cached !== null
        && (error instanceof TopicFetchError || error instanceof TopicParseError)
      ) {
        console.error("Topic yenilenemedi; stale cache kullanılıyor.", error);
        return this.toData(cached, true, true);
      }
      throw error;
    }

    await this.cacheRepository.put(
      cacheKey,
      payload,
      now,
      now + TOPIC_CACHE_TTL_SECONDS,
    );
    return this.toData({ payload, fetchedAt: now, expiresAt: now + TOPIC_CACHE_TTL_SECONDS }, false, false);
  }

  private toData(
    cached: CachedValue<TopicPayload>,
    isCached: boolean,
    stale: boolean,
  ): TopicData {
    return {
      ...cached.payload,
      cache: {
        cached: isCached,
        stale,
        fetchedAt: new Date(cached.fetchedAt * 1_000).toISOString(),
      },
    };
  }
}
