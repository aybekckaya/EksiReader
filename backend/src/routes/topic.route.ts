import { EksiClient } from "../clients/eksi.client";
import { MAX_TOPIC_PAGE, MIN_PAGE } from "../config";
import { AppError } from "../errors/app-error";
import type { Env } from "../env";
import type { TopicSort } from "../models/entry";
import { CacheRepository } from "../repositories/cache.repository";
import { TopicRepository } from "../repositories/topic.repository";
import { TopicService } from "../services/topic.service";
import { jsonResponse } from "../utils/response";

function parseTopicId(rawTopicId: string): number {
  if (!/^\d+$/u.test(rawTopicId)) {
    throw new AppError("INVALID_TOPIC_ID", 400, "topicId pozitif bir tam sayı olmalıdır.");
  }
  const topicId = Number(rawTopicId);
  if (!Number.isSafeInteger(topicId) || topicId <= 0) {
    throw new AppError("INVALID_TOPIC_ID", 400, "topicId pozitif bir tam sayı olmalıdır.");
  }
  return topicId;
}

function parsePage(url: URL): number {
  const rawPage = url.searchParams.get("page");
  if (rawPage === null) {
    return 1;
  }
  if (!/^\d+$/u.test(rawPage)) {
    throw new AppError(
      "INVALID_PAGE",
      400,
      `page, ${MIN_PAGE} ile ${MAX_TOPIC_PAGE} arasında bir tam sayı olmalıdır.`,
    );
  }
  const page = Number(rawPage);
  if (!Number.isSafeInteger(page) || page < MIN_PAGE || page > MAX_TOPIC_PAGE) {
    throw new AppError(
      "INVALID_PAGE",
      400,
      `page, ${MIN_PAGE} ile ${MAX_TOPIC_PAGE} arasında bir tam sayı olmalıdır.`,
    );
  }
  return page;
}

function parseSort(url: URL): TopicSort {
  const sort = url.searchParams.get("sort") ?? "popular";
  if (sort !== "popular") {
    throw new AppError("INVALID_SORT", 400, "Yalnızca popular sıralaması destekleniyor.");
  }
  return sort;
}

export async function topicRoute(
  request: Request,
  env: Env,
  rawTopicId: string,
): Promise<Response> {
  const url = new URL(request.url);
  const topicId = parseTopicId(rawTopicId);
  const page = parsePage(url);
  const sort = parseSort(url);
  const service = new TopicService(
    new EksiClient(),
    new CacheRepository(env.DB),
    new TopicRepository(env.DB),
  );
  const data = await service.getTopic(topicId, page, sort);
  return jsonResponse({ success: true, data });
}
