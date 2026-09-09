CREATE TABLE IF NOT EXISTS authors (
    slug TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    author_id INTEGER,
    avatar_url TEXT,
    rank_text TEXT,
    registration_date_text TEXT,
    entry_count INTEGER,
    follower_count INTEGER,
    following_count INTEGER,
    last_seen_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_authors_author_id
ON authors(author_id);

CREATE INDEX IF NOT EXISTS idx_authors_username
ON authors(username);
