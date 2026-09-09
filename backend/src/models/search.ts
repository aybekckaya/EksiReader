export interface SearchTopicSuggestion {
  id: number;
  title: string;
  slug: string;
  entryCount: number | null;
}

export interface SearchSuggestions {
  query: string;
  topics: SearchTopicSuggestion[];
}

export interface ResolvedTopic {
  type: "topic";
  topic: {
    id: number;
    title: string;
    slug: string;
  };
}
