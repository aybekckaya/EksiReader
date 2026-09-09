import type { EksiClient } from "../clients/eksi.client";
import { AppError, SearchSuggestionsError } from "../errors/app-error";
import type {
  ResolvedTopic,
  SearchSuggestions,
  SearchTopicSuggestion,
} from "../models/search";
import { parseTopicLocation } from "../parsers/search.parser";
import type { TopicRepository } from "../repositories/topic.repository";
import { normalizeSearchText } from "../utils/search";

type Clock = () => number;

interface SearchClient {
  fetchSearchResolveLocation(query: string): Promise<string>;
}

interface SearchTopicStore {
  searchTopics(normalizedQuery: string, limit: number): Promise<SearchTopicSuggestion[]>;
  upsertResolvedTopic(
    topic: { id: number; title: string; slug: string },
    lastSeenAt: number,
  ): Promise<void>;
}

export class SearchService {
  constructor(
    private readonly client: SearchClient | Pick<
      EksiClient,
      "fetchSearchResolveLocation"
    >,
    private readonly topicRepository: SearchTopicStore | Pick<
      TopicRepository,
      "searchTopics" | "upsertResolvedTopic"
    >,
    private readonly clock: Clock = Date.now,
  ) {}

  async getSuggestions(query: string): Promise<SearchSuggestions> {
    try {
      const topics = await this.topicRepository.searchTopics(normalizeSearchText(query), 10);
      return { query, topics };
    } catch (error) {
      throw new SearchSuggestionsError("D1 topic araması başarısız.", { cause: error });
    }
  }

  async resolveTopic(query: string): Promise<ResolvedTopic> {
    if (query.startsWith("@")) {
      throw new AppError(
        "AUTHOR_RESOLVE_NOT_SUPPORTED",
        400,
        "Yazar çözümleme henüz desteklenmiyor.",
      );
    }

    const location = await this.client.fetchSearchResolveLocation(query);
    const resolved = parseTopicLocation(location);
    const topic = { id: resolved.id, title: query, slug: resolved.slug };
    await this.topicRepository.upsertResolvedTopic(
      topic,
      Math.floor(this.clock() / 1_000),
    );
    return { type: "topic", topic };
  }
}
