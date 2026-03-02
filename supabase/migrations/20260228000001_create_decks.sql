-- Migration: Create decks table
-- 20260228000001_create_decks.sql

CREATE TABLE IF NOT EXISTS decks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  language_code VARCHAR(10) NOT NULL DEFAULT 'ja',
  name VARCHAR(255) NOT NULL,
  description TEXT,
  slug VARCHAR(255) NOT NULL,
  emoji VARCHAR(10),
  cover_image_url TEXT,
  is_public BOOLEAN NOT NULL DEFAULT true,
  order_index INT NOT NULL DEFAULT 0,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT decks_site_slug_unique UNIQUE (site_id, slug)
);

-- Indexes
CREATE INDEX idx_decks_site_id ON decks(site_id);
CREATE INDEX idx_decks_language_code ON decks(language_code);
CREATE INDEX idx_decks_order ON decks(site_id, order_index);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $func$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

CREATE TRIGGER update_decks_updated_at
  BEFORE UPDATE ON decks
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- RLS
ALTER TABLE decks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read decks"
ON decks FOR SELECT USING (is_public = true);

-- Seed: JLPT N5, Hiragana, Katakana, Chào hỏi, Số đếm
INSERT INTO decks (site_id, language_code, name, description, slug, emoji, order_index)
VALUES
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'JLPT N5 — Từ cơ bản', 'Những từ vựng thiết yếu cho kỳ thi JLPT N5', 'jlpt-n5', '📚', 1),
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'Chào hỏi & Giao tiếp', 'Các câu chào hỏi và giao tiếp hằng ngày', 'chao-hoi', '👋', 2),
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'Số đếm & Thời gian', 'Số, ngày tháng, giờ giấc', 'so-dem', '🔢', 3),
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'Màu sắc & Hình dạng', 'Các màu sắc và hình dạng cơ bản', 'mau-sac', '🎨', 4),
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'Ẩm thực', 'Tên các món ăn, đồ uống tiếng Nhật', 'am-thuc', '🍱', 5),
  ((SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1), 'ja', 'Gia đình', 'Từ xưng hô trong gia đình', 'gia-dinh', '👨‍👩‍👧‍👦', 6);
