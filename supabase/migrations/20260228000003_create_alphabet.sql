-- Migration: Create alphabet_characters table + seed Hiragana/Katakana
-- 20260228000003_create_alphabet.sql

CREATE TABLE IF NOT EXISTS alphabet_characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  language_code VARCHAR(10) NOT NULL DEFAULT 'ja',
  script VARCHAR(20) NOT NULL, -- 'hiragana', 'katakana', 'kanji'
  character VARCHAR(10) NOT NULL,
  romanization VARCHAR(20) NOT NULL,
  group_name VARCHAR(50),      -- 'vowels', 'ka-row', etc.
  stroke_order_url TEXT,
  order_index INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_alphabet_site_id ON alphabet_characters(site_id);
CREATE INDEX idx_alphabet_script ON alphabet_characters(script);
CREATE INDEX idx_alphabet_group ON alphabet_characters(group_name);

ALTER TABLE alphabet_characters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read alphabet"
ON alphabet_characters FOR SELECT USING (true);

-- -----------------------------------------------
-- Seed: Hiragana (46 ký tự cơ bản)
-- -----------------------------------------------
WITH site AS (SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1)
INSERT INTO alphabet_characters (site_id, language_code, script, character, romanization, group_name, order_index)
SELECT site.id, 'ja', 'hiragana', char, roma, grp, idx
FROM (VALUES
  -- Nguyên âm
  ('あ', 'a',   'vowels', 1), ('い', 'i',  'vowels', 2), ('う', 'u',  'vowels', 3), ('え', 'e',  'vowels', 4), ('お', 'o',  'vowels', 5),
  -- Ka row
  ('か', 'ka',  'ka-row', 6), ('き', 'ki', 'ka-row', 7), ('く', 'ku', 'ka-row', 8), ('け', 'ke', 'ka-row', 9), ('こ', 'ko', 'ka-row', 10),
  -- Sa row
  ('さ', 'sa',  'sa-row', 11), ('し', 'shi', 'sa-row', 12), ('す', 'su', 'sa-row', 13), ('せ', 'se', 'sa-row', 14), ('そ', 'so', 'sa-row', 15),
  -- Ta row
  ('た', 'ta',  'ta-row', 16), ('ち', 'chi', 'ta-row', 17), ('つ', 'tsu', 'ta-row', 18), ('て', 'te', 'ta-row', 19), ('と', 'to', 'ta-row', 20),
  -- Na row
  ('な', 'na',  'na-row', 21), ('に', 'ni', 'na-row', 22), ('ぬ', 'nu', 'na-row', 23), ('ね', 'ne', 'na-row', 24), ('の', 'no', 'na-row', 25),
  -- Ha row
  ('は', 'ha',  'ha-row', 26), ('ひ', 'hi', 'ha-row', 27), ('ふ', 'fu', 'ha-row', 28), ('へ', 'he', 'ha-row', 29), ('ほ', 'ho', 'ha-row', 30),
  -- Ma row
  ('ま', 'ma',  'ma-row', 31), ('み', 'mi', 'ma-row', 32), ('む', 'mu', 'ma-row', 33), ('め', 'me', 'ma-row', 34), ('も', 'mo', 'ma-row', 35),
  -- Ya row
  ('や', 'ya',  'ya-row', 36), ('ゆ', 'yu', 'ya-row', 37), ('よ', 'yo', 'ya-row', 38),
  -- Ra row
  ('ら', 'ra',  'ra-row', 39), ('り', 'ri', 'ra-row', 40), ('る', 'ru', 'ra-row', 41), ('れ', 're', 'ra-row', 42), ('ろ', 'ro', 'ra-row', 43),
  -- Wa row
  ('わ', 'wa',  'wa-row', 44), ('を', 'wo', 'wa-row', 45),
  -- N
  ('ん', 'n',   'n', 46)
) AS c(char, roma, grp, idx), site;

-- -----------------------------------------------
-- Seed: Katakana (46 ký tự cơ bản)
-- -----------------------------------------------
WITH site AS (SELECT id FROM sites WHERE slug = 'language-learning' LIMIT 1)
INSERT INTO alphabet_characters (site_id, language_code, script, character, romanization, group_name, order_index)
SELECT site.id, 'ja', 'katakana', char, roma, grp, idx
FROM (VALUES
  ('ア', 'a',   'vowels', 1), ('イ', 'i',  'vowels', 2), ('ウ', 'u',  'vowels', 3), ('エ', 'e',  'vowels', 4), ('オ', 'o',  'vowels', 5),
  ('カ', 'ka',  'ka-row', 6), ('キ', 'ki', 'ka-row', 7), ('ク', 'ku', 'ka-row', 8), ('ケ', 'ke', 'ka-row', 9), ('コ', 'ko', 'ka-row', 10),
  ('サ', 'sa',  'sa-row', 11), ('シ', 'shi', 'sa-row', 12), ('ス', 'su', 'sa-row', 13), ('セ', 'se', 'sa-row', 14), ('ソ', 'so', 'sa-row', 15),
  ('タ', 'ta',  'ta-row', 16), ('チ', 'chi', 'ta-row', 17), ('ツ', 'tsu', 'ta-row', 18), ('テ', 'te', 'ta-row', 19), ('ト', 'to', 'ta-row', 20),
  ('ナ', 'na',  'na-row', 21), ('ニ', 'ni', 'na-row', 22), ('ヌ', 'nu', 'na-row', 23), ('ネ', 'ne', 'na-row', 24), ('ノ', 'no', 'na-row', 25),
  ('ハ', 'ha',  'ha-row', 26), ('ヒ', 'hi', 'ha-row', 27), ('フ', 'fu', 'ha-row', 28), ('ヘ', 'he', 'ha-row', 29), ('ホ', 'ho', 'ha-row', 30),
  ('マ', 'ma',  'ma-row', 31), ('ミ', 'mi', 'ma-row', 32), ('ム', 'mu', 'ma-row', 33), ('メ', 'me', 'ma-row', 34), ('モ', 'mo', 'ma-row', 35),
  ('ヤ', 'ya',  'ya-row', 36), ('ユ', 'yu', 'ya-row', 37), ('ヨ', 'yo', 'ya-row', 38),
  ('ラ', 'ra',  'ra-row', 39), ('リ', 'ri', 'ra-row', 40), ('ル', 'ru', 'ra-row', 41), ('レ', 're', 'ra-row', 42), ('ロ', 'ro', 'ra-row', 43),
  ('ワ', 'wa',  'wa-row', 44), ('ヲ', 'wo', 'wa-row', 45),
  ('ン', 'n',   'n', 46)
) AS c(char, roma, grp, idx), site;
