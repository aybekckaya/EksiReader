import { EksiClient } from "../clients/eksi.client";
import { AppError } from "../errors/app-error";
import type { Env } from "../env";
import { CacheRepository } from "../repositories/cache.repository";
import { TopicRepository } from "../repositories/topic.repository";
import { TrendingService } from "../services/trending.service";
import { MAX_PAGE, MIN_PAGE } from "../config";
import { jsonResponse } from "../utils/response";

function parsePage(url: URL): number {
  const rawPage = url.searchParams.get("page");
  if (rawPage === null) {
    return 1;
  }

  if (!/^\d+$/u.test(rawPage)) {
    throw new AppError("INVALID_PAGE", 400, "page, 1 ile 20 arasında bir tam sayı olmalıdır.");
  }

  const page = Number(rawPage);
  if (!Number.isSafeInteger(page) || page < MIN_PAGE || page > MAX_PAGE) {
    throw new AppError("INVALID_PAGE", 400, "page, 1 ile 20 arasında bir tam sayı olmalıdır.");
  }
  return page;
}

export async function trendingRoute(request: Request, env: Env): Promise<Response> {
  const page = parsePage(new URL(request.url));
  const service = new TrendingService(
    new EksiClient(),
    new CacheRepository(env.DB),
    new TopicRepository(env.DB),
  );
  const data = await service.getTrending(page);
  return jsonResponse({ success: true, data });
}
