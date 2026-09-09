import { afterEach, describe, expect, it, vi } from "vitest";
import {
  AuthorEntriesFetchError,
  AuthorFetchError,
  AuthorSourceChallengeError,
} from "../../src/errors/app-error";
import type { AuthorMetadata, AuthorProfile } from "../../src/models/author";
import type { AuthorEntriesPayload, AuthorProfilePayload } from "../../src/models/api";
import type { AuthorIdUpdateResult } from "../../src/repositories/author.repository";
import type { CachedValue } from "../../src/repositories/cache.repository";
import { AuthorService } from "../../src/services/author.service";
import authorEntriesHtml from "../fixtures/author-entries.html?raw";
import authorProfileHtml from "../fixtures/author-profile.html?raw";

const NOW_MS = 1_789_000_000_000;
const NOW_SECONDS = NOW_MS / 1_000;
const PROFILE: AuthorProfile = {
  id: null,
  username: "sakarninja",
  slug: "sakarninja",
  avatarUrl: "https://ekstat.com/img/default-profile-picture-light.svg",
  rankText: "hippi (428)",
  registrationDateText: "mayıs 2001",
  stats: { entryCount: 2720, followerCount: 19, followingCount: 0 },
  badges: [{
    name: "azimli",
    description: "en az 1000 entry girmiş",
    imageUrl: "https://cdn.eksisozluk.com/badges/azimli.png",
  }],
};
const METADATA: AuthorMetadata = {
  id: null,
  username: PROFILE.username,
  slug: PROFILE.slug,
  avatarUrl: PROFILE.avatarUrl,
  rankText: PROFILE.rankText,
  registrationDateText: PROFILE.registrationDateText,
  stats: PROFILE.stats,
};
const PROFILE_PAYLOAD: AuthorProfilePayload = { author: PROFILE };
const ENTRIES_PAYLOAD: AuthorEntriesPayload = {
  author: { id: 9200, username: "sakarninja", slug: "sakarninja" },
  items: [{
    topic: { id: 38998, title: "ibanez", slug: "ibanez" },
    entry: {
      id: 9396215,
      contentText: "örnek",
      contentHtml: "örnek",
      author: { id: 9200, username: "sakarninja", slug: "sakarninja", avatarUrl: null },
      dateText: "12.04.2006 05:13",
      favoriteCount: 2,
      commentCount: 0,
      likeCount: 0,
      permalink: "https://eksisozluk.com/entry/9396215",
    },
  }],
  pagination: {
    currentPage: 1,
    hasPreviousPage: false,
    previousPage: null,
    hasNextPage: true,
    nextPage: 2,
  },
};

function cached<T>(payload: T, fresh: boolean): CachedValue<T> {
  return {
    payload,
    fetchedAt: NOW_SECONDS - (fresh ? 10 : 120),
    expiresAt: NOW_SECONDS + (fresh ? 50 : -60),
  };
}

function dependencies(
  initialMetadata: AuthorMetadata | null = METADATA,
  initialCache: Record<string, CachedValue<AuthorProfilePayload | AuthorEntriesPayload>> = {},
) {
  const cacheState = new Map(Object.entries(initialCache));
  const authorState: { value: AuthorMetadata | null } = { value: initialMetadata };
  const cache = {
    get: vi.fn(async (key: string): Promise<
      CachedValue<AuthorProfilePayload | AuthorEntriesPayload> | null
    > => cacheState.get(key) ?? null),
    put: vi.fn(async (
      key: string,
      payload: unknown,
      fetchedAt: number,
      expiresAt: number,
    ): Promise<void> => {
      cacheState.set(key, {
        payload: payload as AuthorProfilePayload | AuthorEntriesPayload,
        fetchedAt,
        expiresAt,
      });
    }),
  };
  const authors = {
    findBySlug: vi.fn(async (): Promise<AuthorMetadata | null> => authorState.value),
    upsertProfile: vi.fn(async (profile: AuthorProfile): Promise<void> => {
      authorState.value = {
        id: profile.id,
        username: profile.username,
        slug: profile.slug,
        avatarUrl: profile.avatarUrl,
        rankText: profile.rankText,
        registrationDateText: profile.registrationDateText,
        stats: profile.stats,
      };
    }),
    updateAuthorId: vi.fn(async (
      _slug: string,
      authorId: number,
    ): Promise<AuthorIdUpdateResult> => {
      if (authorState.value === null) {
        return "missing";
      }
      if (authorState.value.id !== null && authorState.value.id !== authorId) {
        return "conflict";
      }
      const result = authorState.value.id === authorId ? "unchanged" : "updated";
      authorState.value = { ...authorState.value, id: authorId };
      return result;
    }),
  };
  return {
    client: {
      fetchAuthorProfile: vi.fn().mockResolvedValue(authorProfileHtml),
      fetchAuthorEntries: vi.fn().mockResolvedValue(authorEntriesHtml),
    },
    cache,
    authors,
    topics: { upsertManyResolvedTopics: vi.fn().mockResolvedValue(undefined) },
  };
}

function service(deps: ReturnType<typeof dependencies>): AuthorService {
  return new AuthorService(deps.client, deps.cache, deps.authors, deps.topics, () => NOW_MS);
}

describe("AuthorService profile cache", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fresh profile cache varken source fetch yapmaz", async () => {
    const deps = dependencies(METADATA, { "author:sakarninja": cached(PROFILE_PAYLOAD, true) });
    const result = await service(deps).getAuthorProfile("sakarninja");

    expect(deps.client.fetchAuthorProfile).not.toHaveBeenCalled();
    expect(result.cache).toMatchObject({ cached: true, stale: false });
  });

  it("expired cache ardından source fetch, repository upsert ve 300 saniyelik cache write yapar", async () => {
    const deps = dependencies(METADATA, { "author:sakarninja": cached(PROFILE_PAYLOAD, false) });
    const result = await service(deps).getAuthorProfile("sakarninja");

    expect(deps.client.fetchAuthorProfile).toHaveBeenCalledOnce();
    expect(deps.authors.upsertProfile).toHaveBeenCalledOnce();
    expect(deps.cache.put).toHaveBeenCalledWith(
      "author:sakarninja",
      expect.objectContaining({ author: expect.objectContaining({ username: "sakarninja" }) }),
      NOW_SECONDS,
      NOW_SECONDS + 300,
    );
    expect(result.cache).toMatchObject({ cached: false, stale: false });
  });

  it("expired cache ve profile fetch hatasında stale cache döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, { "author:sakarninja": cached(PROFILE_PAYLOAD, false) });
    deps.client.fetchAuthorProfile.mockRejectedValue(new AuthorFetchError("timeout"));

    const result = await service(deps).getAuthorProfile("sakarninja");
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("cache yokken profile fetch hatasını dışarı taşır", async () => {
    const deps = dependencies();
    deps.client.fetchAuthorProfile.mockRejectedValue(new AuthorFetchError("HTTP 500"));

    await expect(service(deps).getAuthorProfile("sakarninja"))
      .rejects.toMatchObject({ code: "AUTHOR_FETCH_FAILED", status: 502 });
  });

  it("challenge ve stale cache olduğunda stale response döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, { "author:sakarninja": cached(PROFILE_PAYLOAD, false) });
    deps.client.fetchAuthorProfile.mockRejectedValue(new AuthorSourceChallengeError("challenge"));

    const result = await service(deps).getAuthorProfile("sakarninja");
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("challenge ve cache yoksa kontrollü challenge error verir", async () => {
    const deps = dependencies();
    deps.client.fetchAuthorProfile.mockRejectedValue(new AuthorSourceChallengeError("challenge"));

    await expect(service(deps).getAuthorProfile("sakarninja"))
      .rejects.toMatchObject({ code: "AUTHOR_SOURCE_CHALLENGE", status: 502 });
  });

  it("source parse hatasında expired cache'i stale kullanır", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, { "author:sakarninja": cached(PROFILE_PAYLOAD, false) });
    deps.client.fetchAuthorProfile.mockResolvedValue("<html>değişmiş yapı</html>");

    const result = await service(deps).getAuthorProfile("sakarninja");
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("entry'den öğrenilmiş repository authorId'sini cached profile response'una merge eder", async () => {
    const deps = dependencies(
      { ...METADATA, id: 9200 },
      { "author:sakarninja": cached(PROFILE_PAYLOAD, true) },
    );

    const result = await service(deps).getAuthorProfile("sakarninja");
    expect(result.author.id).toBe(9200);
  });
});

describe("AuthorService entries cache", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fresh entries cache varken source fetch yapmaz", async () => {
    const deps = dependencies(METADATA, {
      "author-entries:sakarninja:1": cached(ENTRIES_PAYLOAD, true),
    });
    const result = await service(deps).getAuthorEntries("sakarninja", 1);

    expect(deps.client.fetchAuthorEntries).not.toHaveBeenCalled();
    expect(result.cache).toMatchObject({ cached: true, stale: false });
  });

  it("author metadata biliniyorsa tek entries source request yapar", async () => {
    const deps = dependencies();
    await service(deps).getAuthorEntries("sakarninja", 1);

    expect(deps.client.fetchAuthorProfile).not.toHaveBeenCalled();
    expect(deps.client.fetchAuthorEntries).toHaveBeenCalledOnce();
    expect(deps.client.fetchAuthorEntries).toHaveBeenCalledWith("sakarninja", 1);
  });

  it("başarılı entries parse sonrası authorId, topic discovery ve 60 saniyelik cache yazar", async () => {
    const deps = dependencies();
    const result = await service(deps).getAuthorEntries("sakarninja", 1);

    expect(deps.authors.updateAuthorId).toHaveBeenCalledWith("sakarninja", 9200);
    expect(deps.topics.upsertManyResolvedTopics).toHaveBeenCalledWith([
      { id: 38998, title: "ibanez", slug: "ibanez" },
      { id: 12345, title: "elektro gitar", slug: "elektro-gitar" },
      { id: 67890, title: "rock müzik", slug: "rock-muzik" },
    ], NOW_SECONDS);
    expect(deps.cache.put).toHaveBeenCalledWith(
      "author-entries:sakarninja:1",
      expect.objectContaining({ items: expect.any(Array) }),
      NOW_SECONDS,
      NOW_SECONDS + 60,
    );
    expect(result).toMatchObject({
      author: { id: 9200, username: "sakarninja", slug: "sakarninja" },
      cache: { cached: false, stale: false },
    });
  });

  it("metadata yoksa profile'ı bir kez resolve edip sonra entries çağırır", async () => {
    const deps = dependencies(null);
    await service(deps).getAuthorEntries("sakarninja", 1);

    expect(deps.client.fetchAuthorProfile).toHaveBeenCalledOnce();
    expect(deps.client.fetchAuthorEntries).toHaveBeenCalledOnce();
    expect(deps.authors.upsertProfile).toHaveBeenCalledOnce();
  });

  it("expired entries cache ve fetch hatasında stale cache döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, {
      "author-entries:sakarninja:1": cached(ENTRIES_PAYLOAD, false),
    });
    deps.client.fetchAuthorEntries.mockRejectedValue(new AuthorEntriesFetchError("timeout"));

    const result = await service(deps).getAuthorEntries("sakarninja", 1);
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("cache yokken entries fetch hatasını dışarı taşır", async () => {
    const deps = dependencies();
    deps.client.fetchAuthorEntries.mockRejectedValue(new AuthorEntriesFetchError("HTTP 500"));

    await expect(service(deps).getAuthorEntries("sakarninja", 1))
      .rejects.toMatchObject({ code: "AUTHOR_ENTRIES_FETCH_FAILED", status: 502 });
  });

  it("entries challenge ve stale cache olduğunda stale response döndürür", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, {
      "author-entries:sakarninja:1": cached(ENTRIES_PAYLOAD, false),
    });
    deps.client.fetchAuthorEntries.mockRejectedValue(new AuthorSourceChallengeError("challenge"));

    const result = await service(deps).getAuthorEntries("sakarninja", 1);
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("entries challenge ve cache yoksa controlled error verir", async () => {
    const deps = dependencies();
    deps.client.fetchAuthorEntries.mockRejectedValue(new AuthorSourceChallengeError("challenge"));

    await expect(service(deps).getAuthorEntries("sakarninja", 1))
      .rejects.toMatchObject({ code: "AUTHOR_SOURCE_CHALLENGE", status: 502 });
  });

  it("entries parse hatasında expired cache'i stale kullanır", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies(METADATA, {
      "author-entries:sakarninja:1": cached(ENTRIES_PAYLOAD, false),
    });
    deps.client.fetchAuthorEntries.mockResolvedValue("<html>değişmiş yapı</html>");

    const result = await service(deps).getAuthorEntries("sakarninja", 1);
    expect(result.cache).toMatchObject({ cached: true, stale: true });
  });

  it("tutarsız entry authorId değerlerinde repository'yi overwrite etmez", async () => {
    vi.spyOn(console, "error").mockImplementation(() => undefined);
    const deps = dependencies();
    deps.client.fetchAuthorEntries.mockResolvedValue(
      authorEntriesHtml.replace('data-author-id="9200"', 'data-author-id="9999"'),
    );

    const result = await service(deps).getAuthorEntries("sakarninja", 1);
    expect(deps.authors.updateAuthorId).not.toHaveBeenCalled();
    expect(result.author.id).toBeNull();
  });
});
