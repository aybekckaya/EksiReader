import { AppError } from "./errors/app-error";
import type { Env } from "./env";
import { healthRoute } from "./routes/health.route";
import { topicRoute } from "./routes/topic.route";
import { trendingRoute } from "./routes/trending.route";
import { errorResponse, optionsResponse } from "./utils/response";

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return optionsResponse();
    }

    try {
      const url = new URL(request.url);
      if (request.method === "GET" && url.pathname === "/health") {
        return healthRoute();
      }
      if (request.method === "GET" && url.pathname === "/v1/trending") {
        return await trendingRoute(request, env);
      }
      const topicMatch = /^\/v1\/topics\/([^/]+)$/u.exec(url.pathname);
      if (request.method === "GET" && topicMatch?.[1] !== undefined) {
        return await topicRoute(request, env, topicMatch[1]);
      }
      return errorResponse("NOT_FOUND", "Endpoint bulunamadı.", 404);
    } catch (error) {
      if (error instanceof AppError) {
        console.error(`${error.code}: ${error.message}`, error.cause);
        return errorResponse(error.code, error.publicMessage, error.status);
      }

      console.error("Beklenmeyen backend hatası.", error);
      return errorResponse("INTERNAL_ERROR", "Beklenmeyen bir hata oluştu.", 500);
    }
  },
} satisfies ExportedHandler<Env>;
