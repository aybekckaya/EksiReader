interface CacheRow {
  payload: string;
  fetched_at: number;
  expires_at: number;
}

export interface CachedValue<TPayload> {
  payload: TPayload;
  fetchedAt: number;
  expiresAt: number;
}

export class CacheRepository {
  constructor(private readonly db: D1Database) {}

  async get<TPayload>(key: string): Promise<CachedValue<TPayload> | null> {
    const row = await this.db
      .prepare(
        "SELECT payload, fetched_at, expires_at FROM response_cache WHERE cache_key = ?1",
      )
      .bind(key)
      .first<CacheRow>();

    if (row === null) {
      return null;
    }

    try {
      return {
        payload: JSON.parse(row.payload) as TPayload,
        fetchedAt: row.fetched_at,
        expiresAt: row.expires_at,
      };
    } catch (error) {
      console.error("Geçersiz cache payload'u yok sayıldı.", error);
      return null;
    }
  }

  async put(
    key: string,
    payload: unknown,
    fetchedAt: number,
    expiresAt: number,
  ): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO response_cache (cache_key, payload, fetched_at, expires_at)
         VALUES (?1, ?2, ?3, ?4)
         ON CONFLICT(cache_key) DO UPDATE SET
           payload = excluded.payload,
           fetched_at = excluded.fetched_at,
           expires_at = excluded.expires_at`,
      )
      .bind(key, JSON.stringify(payload), fetchedAt, expiresAt)
      .run();
  }
}
