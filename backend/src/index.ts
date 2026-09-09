import { AppError } from "./errors/app-error";
import type { Env } from "./env";
import { healthRoute } from "./routes/health.route";
import { authorEntriesRoute, authorProfileRoute } from "./routes/author.route";
import { searchResolveRoute, searchSuggestionsRoute } from "./routes/search.route";
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
      if (request.method === "GET" && url.pathname === "/v1/search/suggestions") {
        return await searchSuggestionsRoute(request, env);
      }
      if (request.method === "GET" && url.pathname === "/v1/search/resolve") {
        return await searchResolveRoute(request, env);
      }
      const authorEntriesMatch = /^\/v1\/authors\/([^/]+)\/entries$/u.exec(url.pathname);
      if (request.method === "GET" && authorEntriesMatch?.[1] !== undefined) {
        return await authorEntriesRoute(request, env, authorEntriesMatch[1]);
      }
      const authorProfileMatch = /^\/v1\/authors\/([^/]+)$/u.exec(url.pathname);
      if (request.method === "GET" && authorProfileMatch?.[1] !== undefined) {
        return await authorProfileRoute(request, env, authorProfileMatch[1]);
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
