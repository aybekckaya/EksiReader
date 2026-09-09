import { describe, expect, it, vi } from "vitest";
import { SearchService } from "../../src/services/search.service";

const NOW_MS = 1_789_000_000_000;
const SEARCH_RESULTS = [{
  id: 42,
  title: "kadın yazarların son yaptığı yemek",
  slug: "kadin-yazarlarin-son-yaptigi-yemek",
  entryCount: 84,
}];

function dependencies() {
  return {
    client: {
      fetchSearchResolveLocation: vi.fn().mockResolvedValue(
        "/4-agustos-2021-guney-kore-turkiye-voleybol-maci--6994477",
      ),
    },
    topics: {
      searchTopics: vi.fn().mockResolvedValue(SEARCH_RESULTS),
      upsertResolvedTopic: vi.fn().mockResolvedValue(undefined),
    },
  };
}

describe("SearchService", () => {
  it("query'yi Türkçe-toleranslı normalize edip D1'de arar", async () => {
    const deps = dependencies();
    const service = new SearchService(deps.client, deps.topics, () => NOW_MS);

    const result = await service.getSuggestions("KADIN");

    expect(deps.topics.searchTopics).toHaveBeenCalledWith("kadin", 10);
    expect(result).toEqual({ query: "KADIN", topics: SEARCH_RESULTS });
  });

  it("suggestions sırasında hiçbir upstream network methodu çağırmaz", async () => {
    const deps = dependencies();

    await new SearchService(deps.client, deps.topics).getSuggestions("kad");

    expect(deps.client.fetchSearchResolveLocation).not.toHaveBeenCalled();
  });

  it("D1 boş sonucunu başarılı boş topic listesi olarak döndürür", async () => {
    const deps = dependencies();
    deps.topics.searchTopics.mockResolvedValue([]);

    const result = await new SearchService(deps.client, deps.topics).getSuggestions("zz");

    expect(result).toEqual({ query: "zz", topics: [] });
  });

  it("D1 hatasını kontrollü suggestions hatasına çevirir", async () => {
    const deps = dependencies();
    deps.topics.searchTopics.mockRejectedValue(new Error("D1 unavailable"));

    await expect(new SearchService(deps.client, deps.topics).getSuggestions("kad"))
      .rejects.toMatchObject({ code: "SEARCH_SUGGESTIONS_FAILED", status: 502 });
  });

  it("relative redirect'i resolve edip D1 metadata upsert yapar", async () => {
    const deps = dependencies();
    const service = new SearchService(deps.client, deps.topics, () => NOW_MS);

    const result = await service.resolveTopic(
      "4 ağustos 2021 güney kore türkiye voleybol maçı",
    );

    expect(result).toEqual({
      type: "topic",
      topic: {
        id: 6994477,
        title: "4 ağustos 2021 güney kore türkiye voleybol maçı",
        slug: "4-agustos-2021-guney-kore-turkiye-voleybol-maci",
      },
    });
    expect(deps.topics.upsertResolvedTopic).toHaveBeenCalledWith(
      result.topic,
      NOW_MS / 1_000,
    );
  });

  it("@author resolve'u upstream'e gitmeden reddeder", async () => {
    const deps = dependencies();
    const service = new SearchService(deps.client, deps.topics);

    await expect(service.resolveTopic("@voleybol"))
      .rejects.toMatchObject({ code: "AUTHOR_RESOLVE_NOT_SUPPORTED", status: 400 });
    expect(deps.client.fetchSearchResolveLocation).not.toHaveBeenCalled();
    expect(deps.topics.upsertResolvedTopic).not.toHaveBeenCalled();
  });
});
