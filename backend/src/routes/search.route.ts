import { EksiClient } from "../clients/eksi.client";
import { AppError } from "../errors/app-error";
import type { Env } from "../env";
import { TopicRepository } from "../repositories/topic.repository";
import { SearchService } from "../services/search.service";
import { jsonResponse } from "../utils/response";

const MIN_SEARCH_QUERY_LENGTH = 2;
const MAX_SEARCH_QUERY_LENGTH = 100;

export function parseSearchQuery(request: Request): string {
  const query = new URL(request.url).searchParams.get("q")?.trim() ?? "";
  const length = Array.from(query).length;
  if (length < MIN_SEARCH_QUERY_LENGTH || length > MAX_SEARCH_QUERY_LENGTH) {
    throw new AppError(
      "INVALID_SEARCH_QUERY",
      400,
      "Arama sorgusu geçersiz.",
    );
  }
  return query;
}

function createService(env: Env): SearchService {
  return new SearchService(new EksiClient(), new TopicRepository(env.DB));
}

export async function searchSuggestionsRoute(request: Request, env: Env): Promise<Response> {
  const query = parseSearchQuery(request);
  const data = await createService(env).getSuggestions(query);
  return jsonResponse({ success: true, data });
}

export async function searchResolveRoute(request: Request, env: Env): Promise<Response> {
  const query = parseSearchQuery(request);
  const data = await createService(env).resolveTopic(query);
  return jsonResponse({ success: true, data });
}
