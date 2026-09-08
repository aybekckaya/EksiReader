CREATE TABLE topics (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    slug TEXT NOT NULL,
    entry_count INTEGER NOT NULL DEFAULT 0,
    last_seen_at INTEGER NOT NULL
);

CREATE INDEX idx_topics_slug ON topics(slug);
CREATE INDEX idx_topics_last_seen_at ON topics(last_seen_at);

CREATE TABLE response_cache (
    cache_key TEXT PRIMARY KEY,
    payload TEXT NOT NULL,
    fetched_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL
);

CREATE INDEX idx_response_cache_expires_at ON response_cache(expires_at);
