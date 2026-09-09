import type { EksiClient } from "../clients/eksi.client";
import {
  AUTHOR_ENTRIES_CACHE_TTL_SECONDS,
  AUTHOR_PROFILE_CACHE_TTL_SECONDS,
} from "../config";
import {
  AuthorEntriesFetchError,
  AuthorEntriesParseError,
  AuthorFetchError,
  AuthorParseError,
  AuthorSourceChallengeError,
} from "../errors/app-error";
import type { AuthorMetadata, AuthorProfile } from "../models/author";
import type {
  AuthorEntriesData,
  AuthorEntriesPayload,
  AuthorProfileData,
  AuthorProfilePayload,
} from "../models/api";
import { parseAuthorEntries } from "../parsers/author-entries.parser";
import { parseAuthorProfile } from "../parsers/author-profile.parser";
import type { AuthorIdUpdateResult } from "../repositories/author.repository";
import type { CachedValue } from "../repositories/cache.repository";

type Clock = () => number;

interface AuthorClient {
  fetchAuthorProfile(authorSlug: string): Promise<string>;
  fetchAuthorEntries(username: string, page: number): Promise<string>;
}

interface AuthorCache {
  get(key: string): Promise<CachedValue<AuthorProfilePayload | AuthorEntriesPayload> | null>;
  put(key: string, payload: unknown, fetchedAt: number, expiresAt: number): Promise<void>;
}

interface AuthorStore {
  findBySlug(slug: string): Promise<AuthorMetadata | null>;
  upsertProfile(profile: AuthorProfile, lastSeenAt: number): Promise<void>;
  updateAuthorId(slug: string, authorId: number): Promise<AuthorIdUpdateResult>;
}

interface TopicDiscoveryStore {
  upsertManyResolvedTopics(
    topics: { id: number; title: string; slug: string }[],
    lastSeenAt: number,
  ): Promise<void>;
}

function mergeProfile(profile: AuthorProfile, metadata: AuthorMetadata | null): AuthorProfile {
  if (metadata === null) {
    return profile;
  }
  return {
    ...profile,
    id: profile.id ?? metadata.id,
    avatarUrl: profile.avatarUrl ?? metadata.avatarUrl,
    rankText: profile.rankText ?? metadata.rankText,
    registrationDateText: profile.registrationDateText ?? metadata.registrationDateText,
    stats: {
      entryCount: profile.stats.entryCount ?? metadata.stats.entryCount,
      followerCount: profile.stats.followerCount ?? metadata.stats.followerCount,
      followingCount: profile.stats.followingCount ?? metadata.stats.followingCount,
    },
  };
}

function isProfileRefreshError(error: unknown): boolean {
  return error instanceof AuthorFetchError
    || error instanceof AuthorParseError
    || error instanceof AuthorSourceChallengeError;
}

function isEntriesRefreshError(error: unknown): boolean {
  return isProfileRefreshError(error)
    || error instanceof AuthorEntriesFetchError
    || error instanceof AuthorEntriesParseError;
}

export class AuthorService {
  constructor(
    private readonly client: AuthorClient | Pick<
      EksiClient,
      "fetchAuthorProfile" | "fetchAuthorEntries"
    >,
    private readonly cacheRepository: AuthorCache,
    private readonly authorRepository: AuthorStore,
    private readonly topicRepository: TopicDiscoveryStore,
    private readonly clock: Clock = Date.now,
  ) {}

  async getAuthorProfile(authorSlug: string): Promise<AuthorProfileData> {
    const cacheKey = `author:${authorSlug}`;
    const now = Math.floor(this.clock() / 1_000);
    const cached = await this.cacheRepository.get(cacheKey) as CachedValue<AuthorProfilePayload> | null;
    const metadata = await this.authorRepository.findBySlug(authorSlug);
    if (cached !== null && cached.expiresAt > now) {
      if (metadata === null) {
        await this.authorRepository.upsertProfile(cached.payload.author, cached.fetchedAt);
      }
      return this.toProfileData(cached, metadata, true, false);
    }

    let payload: AuthorProfilePayload;
    try {
      const html = await this.client.fetchAuthorProfile(authorSlug);
      const parsed = await parseAuthorProfile(html, authorSlug);
      payload = { author: mergeProfile(parsed, metadata) };
    } catch (error) {
      if (cached !== null && isProfileRefreshError(error)) {
        console.error("Yazar profili yenilenemedi; stale cache kullanılıyor.", error);
        return this.toProfileData(cached, metadata, true, true);
      }
      throw error;
    }

    await Promise.all([
      this.authorRepository.upsertProfile(payload.author, now),
      this.cacheRepository.put(
        cacheKey,
        payload,
        now,
        now + AUTHOR_PROFILE_CACHE_TTL_SECONDS,
      ),
    ]);
    return this.toProfileData(
      { payload, fetchedAt: now, expiresAt: now + AUTHOR_PROFILE_CACHE_TTL_SECONDS },
      null,
      false,
      false,
    );
  }

  async getAuthorEntries(authorSlug: string, page: number): Promise<AuthorEntriesData> {
    const cacheKey = `author-entries:${authorSlug}:${page}`;
    const now = Math.floor(this.clock() / 1_000);
    const cached = await this.cacheRepository.get(cacheKey) as CachedValue<AuthorEntriesPayload> | null;
    let metadata = await this.authorRepository.findBySlug(authorSlug);
    if (cached !== null && cached.expiresAt > now) {
      return this.toEntriesData(cached, metadata, true, false);
    }

    let payload: AuthorEntriesPayload;
    try {
      if (metadata === null) {
        const profileData = await this.getAuthorProfile(authorSlug);
        metadata = {
          id: profileData.author.id,
          username: profileData.author.username,
          slug: profileData.author.slug,
          avatarUrl: profileData.author.avatarUrl,
          rankText: profileData.author.rankText,
          registrationDateText: profileData.author.registrationDateText,
          stats: profileData.author.stats,
        };
      }

      const html = await this.client.fetchAuthorEntries(metadata.username, page);
      const parsed = await parseAuthorEntries(html, {
        requestedPage: page,
        authorSlug,
        expectedUsername: metadata.username,
      });

      const matchingAuthorIds = new Set(parsed.items.map(({ entry }) => entry.author.id));
      let authorId = metadata.id;
      if (matchingAuthorIds.size === 1) {
        const discoveredAuthorId = matchingAuthorIds.values().next().value;
        if (discoveredAuthorId !== undefined) {
          const updateResult = await this.authorRepository.updateAuthorId(
            authorSlug,
            discoveredAuthorId,
          );
          authorId = this.authorIdAfterUpdate(
            authorSlug,
            metadata.id,
            discoveredAuthorId,
            updateResult,
          );
        }
      } else if (matchingAuthorIds.size > 1) {
        console.error("Yazar entry'lerinde tutarsız authorId değerleri görüldü.", {
          authorSlug,
          authorIds: [...matchingAuthorIds],
        });
      }

      payload = {
        author: { id: authorId, username: metadata.username, slug: metadata.slug },
        items: parsed.items,
        pagination: parsed.pagination,
      };
    } catch (error) {
      if (cached !== null && isEntriesRefreshError(error)) {
        console.error("Yazar entry'leri yenilenemedi; stale cache kullanılıyor.", error);
        return this.toEntriesData(cached, metadata, true, true);
      }
      throw error;
    }

    const uniqueTopics = [...new Map(
      payload.items.map(({ topic }) => [topic.id, topic] as const),
    ).values()];
    await Promise.all([
      this.topicRepository.upsertManyResolvedTopics(uniqueTopics, now),
      this.cacheRepository.put(
        cacheKey,
        payload,
        now,
        now + AUTHOR_ENTRIES_CACHE_TTL_SECONDS,
      ),
    ]);
    return this.toEntriesData(
      { payload, fetchedAt: now, expiresAt: now + AUTHOR_ENTRIES_CACHE_TTL_SECONDS },
      metadata,
      false,
      false,
    );
  }

  private authorIdAfterUpdate(
    authorSlug: string,
    currentAuthorId: number | null,
    discoveredAuthorId: number,
    result: AuthorIdUpdateResult,
  ): number | null {
    if (result === "updated" || result === "unchanged") {
      return discoveredAuthorId;
    }
    console.error("Keşfedilen authorId güvenli biçimde kaydedilemedi.", {
      authorSlug,
      currentAuthorId,
      discoveredAuthorId,
      reason: result,
    });
    return currentAuthorId;
  }

  private toProfileData(
    cached: CachedValue<AuthorProfilePayload>,
    metadata: AuthorMetadata | null,
    isCached: boolean,
    stale: boolean,
  ): AuthorProfileData {
    return {
      author: mergeProfile(cached.payload.author, metadata),
      cache: {
        cached: isCached,
        stale,
        fetchedAt: new Date(cached.fetchedAt * 1_000).toISOString(),
      },
    };
  }

  private toEntriesData(
    cached: CachedValue<AuthorEntriesPayload>,
    metadata: AuthorMetadata | null,
    isCached: boolean,
    stale: boolean,
  ): AuthorEntriesData {
    return {
      ...cached.payload,
      author: {
        ...cached.payload.author,
        id: cached.payload.author.id ?? metadata?.id ?? null,
      },
      cache: {
        cached: isCached,
        stale,
        fetchedAt: new Date(cached.fetchedAt * 1_000).toISOString(),
      },
    };
  }
}
