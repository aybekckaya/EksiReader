import {
  EKSI_BASE_URL,
  EKSI_REQUEST_TIMEOUT_MS,
} from "../config";
import { TrendingFetchError } from "../errors/app-error";

export type FetchImplementation = typeof fetch;

export class EksiClient {
  constructor(
    private readonly fetchImplementation: FetchImplementation = (input, init) => fetch(input, init),
    private readonly timeoutMs = EKSI_REQUEST_TIMEOUT_MS,
  ) {}

  async fetchTrendingPage(page: number): Promise<string> {
    const url = new URL("/basliklar/gundem", EKSI_BASE_URL);
    if (page > 1) {
      url.searchParams.set("p", String(page));
    }

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const response = await this.fetchImplementation(url, {
        headers: {
          Accept: "text/html,application/xhtml+xml",
          "Accept-Language": "tr-TR,tr;q=0.9",
          "User-Agent": "EksiReader/1.0 (public read-only API)",
        },
        signal: controller.signal,
      });

      if (response.status !== 200) {
        throw new TrendingFetchError(`Ekşi HTTP ${response.status} döndürdü.`);
      }

      const contentType = response.headers.get("content-type") ?? "";
      if (!contentType.toLowerCase().includes("text/html")) {
        throw new TrendingFetchError(`Beklenmeyen Content-Type: ${contentType || "yok"}.`);
      }

      const html = await response.text();
      if (html.trim().length === 0) {
        throw new TrendingFetchError("Ekşi boş HTML döndürdü.");
      }

      return html;
    } catch (error) {
      if (error instanceof TrendingFetchError) {
        throw error;
      }
      const reason = error instanceof Error ? error.message : "Bilinmeyen network hatası";
      throw new TrendingFetchError(`Ekşi isteği başarısız: ${reason}.`, { cause: error });
    } finally {
      clearTimeout(timeout);
    }
  }
}
