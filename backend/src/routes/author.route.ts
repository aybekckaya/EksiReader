import { EksiClient } from "../clients/eksi.client";
import { MAX_AUTHOR_PAGE, MAX_AUTHOR_SLUG_LENGTH, MIN_PAGE } from "../config";
import { AppError } from "../errors/app-error";
import type { Env } from "../env";
import { AuthorRepository } from "../repositories/author.repository";
import { CacheRepository } from "../repositories/cache.repository";
import { TopicRepository } from "../repositories/topic.repository";
import { AuthorService } from "../services/author.service";
import { jsonResponse } from "../utils/response";

export function parseAuthorSlug(rawAuthorSlug: string): string {
  if (/%(?:2f|5c)/iu.test(rawAuthorSlug)) {
    throw new AppError("INVALID_AUTHOR_SLUG", 400, "Geçersiz yazar slug değeri.");
  }

  let authorSlug: string;
  try {
    authorSlug = decodeURIComponent(rawAuthorSlug).trim();
  } catch {
    throw new AppError("INVALID_AUTHOR_SLUG", 400, "Geçersiz yazar slug değeri.");
  }

  if (
    authorSlug === ""
    || authorSlug.length > MAX_AUTHOR_SLUG_LENGTH
    || authorSlug === "."
    || authorSlug === ".."
    || /[\\/\u0000-\u001f\u007f]/u.test(authorSlug)
  ) {
    throw new AppError("INVALID_AUTHOR_SLUG", 400, "Geçersiz yazar slug değeri.");
  }
  return authorSlug;
}

export function parseAuthorEntriesPage(request: Request): number {
  const rawPage = new URL(request.url).searchParams.get("page");
  if (rawPage === null) {
    return 1;
  }
  if (!/^\d+$/u.test(rawPage)) {
    throw new AppError(
      "INVALID_PAGE",
      400,
      `page, ${MIN_PAGE} ile ${MAX_AUTHOR_PAGE} arasında bir tam sayı olmalıdır.`,
    );
  }
  const page = Number(rawPage);
  if (!Number.isSafeInteger(page) || page < MIN_PAGE || page > MAX_AUTHOR_PAGE) {
    throw new AppError(
      "INVALID_PAGE",
      400,
      `page, ${MIN_PAGE} ile ${MAX_AUTHOR_PAGE} arasında bir tam sayı olmalıdır.`,
    );
  }
  return page;
}

function createAuthorService(env: Env): AuthorService {
  return new AuthorService(
    new EksiClient(),
    new CacheRepository(env.DB),
    new AuthorRepository(env.DB),
    new TopicRepository(env.DB),
  );
}

export async function authorProfileRoute(
  _request: Request,
  env: Env,
  rawAuthorSlug: string,
): Promise<Response> {
  const authorSlug = parseAuthorSlug(rawAuthorSlug);
  const data = await createAuthorService(env).getAuthorProfile(authorSlug);
  return jsonResponse({ success: true, data });
}

export async function authorEntriesRoute(
  request: Request,
  env: Env,
  rawAuthorSlug: string,
): Promise<Response> {
  const authorSlug = parseAuthorSlug(rawAuthorSlug);
  const page = parseAuthorEntriesPage(request);
  const data = await createAuthorService(env).getAuthorEntries(authorSlug, page);
  return jsonResponse({ success: true, data });
}
