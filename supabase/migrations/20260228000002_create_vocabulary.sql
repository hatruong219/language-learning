-- Migration: Create vocabulary + vocabulary_examples tables
-- 20260228000002_create_vocabulary.sql

CREATE TABLE IF NOT EXISTS vocabulary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  deck_id UUID NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
  language_code VARCHAR(10) NOT NULL DEFAULT 'ja',
  word VARCHAR(255) NOT NULL,
  reading VARCHAR(255),
  romanization VARCHAR(255),
  meaning_vi TEXT NOT NULL,
  meaning_en TEXT,
  part_of_speech VARCHAR(50),
  jlpt_level VARCHAR(5),
  audio_url TEXT,
  image_url TEXT,
  tags TEXT[] NOT NULL DEFAULT '{}',
  order_index INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_vocabulary_deck_id ON vocabulary(deck_id);
CREATE INDEX idx_vocabulary_site_id ON vocabulary(site_id);
CREATE INDEX idx_vocabulary_language ON vocabulary(language_code);
CREATE INDEX idx_vocabulary_jlpt ON vocabulary(jlpt_level);
CREATE INDEX idx_vocabulary_is_active ON vocabulary(is_active);

-- Full text search index
CREATE INDEX idx_vocabulary_fts ON vocabulary
  USING GIN (to_tsvector('simple', word || ' ' || meaning_vi));

-- Updated_at trigger
CREATE TRIGGER update_vocabulary_updated_at
  BEFORE UPDATE ON vocabulary
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- RLS
ALTER TABLE vocabulary ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read vocabulary"
ON vocabulary FOR SELECT USING (is_active = true);

-- -----------------------------------------------
-- vocabulary_examples
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS vocabulary_examples (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vocabulary_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  sentence TEXT NOT NULL,
  sentence_reading TEXT,
  translation_vi TEXT,
  translation_en TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_vocab_examples_vocab_id ON vocabulary_examples(vocabulary_id);

ALTER TABLE vocabulary_examples ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read vocabulary_examples"
ON vocabulary_examples FOR SELECT USING (true);

-- -----------------------------------------------
-- Seed: Chào hỏi & Giao tiếp deck
-- -----------------------------------------------
WITH deck AS (
  SELECT id FROM decks WHERE slug = 'chao-hoi' LIMIT 1
),
site AS (
  SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1
)
INSERT INTO vocabulary (site_id, deck_id, word, reading, romanization, meaning_vi, meaning_en, part_of_speech, jlpt_level, order_index)
SELECT site.id, deck.id, word, reading, romanization, meaning_vi, meaning_en, pos, lvl, idx
FROM (VALUES
  ('こんにちは', 'こんにちは', 'konnichiwa', 'Xin chào (ban ngày)', 'Hello (daytime)', '感動詞', 'N5', 1),
  ('おはようございます', 'おはようございます', 'ohayou gozaimasu', 'Chào buổi sáng', 'Good morning', '感動詞', 'N5', 2),
  ('こんばんは', 'こんばんは', 'konbanwa', 'Chào buổi tối', 'Good evening', '感動詞', 'N5', 3),
  ('さようなら', 'さようなら', 'sayounara', 'Tạm biệt', 'Goodbye', '感動詞', 'N5', 4),
  ('ありがとうございます', 'ありがとうございます', 'arigatou gozaimasu', 'Cảm ơn rất nhiều', 'Thank you very much', '感動詞', 'N5', 5),
  ('すみません', 'すみません', 'sumimasen', 'Xin lỗi / Cho tôi hỏi', 'Excuse me / I''m sorry', '感動詞', 'N5', 6),
  ('はじめまして', 'はじめまして', 'hajimemashite', 'Rất vui được gặp bạn', 'Nice to meet you', '感動詞', 'N5', 7),
  ('よろしくおねがいします', 'よろしくおねがいします', 'yoroshiku onegaishimasu', 'Mong bạn quan tâm giúp đỡ', 'Please treat me well', '感動詞', 'N5', 8),
  ('はい', 'はい', 'hai', 'Vâng / Có', 'Yes', '感動詞', 'N5', 9),
  ('いいえ', 'いいえ', 'iie', 'Không', 'No', '感動詞', 'N5', 10),
  ('おなまえは？', 'おなまえは？', 'onamae wa?', 'Tên bạn là gì?', 'What is your name?', '名詞', 'N5', 11),
  ('わかりました', 'わかりました', 'wakarimashita', 'Tôi hiểu rồi', 'I understand', '動詞', 'N5', 12)
) AS v(word, reading, romanization, meaning_vi, meaning_en, pos, lvl, idx),
deck, site;
