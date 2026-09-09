ALTER TABLE topics
ADD COLUMN entry_count_known INTEGER NOT NULL DEFAULT 1
CHECK (entry_count_known IN (0, 1));
