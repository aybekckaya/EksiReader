ALTER TABLE topics
ADD COLUMN search_title TEXT;

CREATE INDEX IF NOT EXISTS idx_topics_search_title
ON topics(search_title);
