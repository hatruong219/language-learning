-- Minna no Nihongo: lesson metadata
CREATE TABLE mnn_lessons (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id        uuid NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  lesson_number  smallint NOT NULL,
  title_vi       text NOT NULL,
  situation_vi   text,
  order_index    smallint DEFAULT 0,
  created_at     timestamptz DEFAULT now(),
  UNIQUE(site_id, lesson_number)
);

-- Minna no Nihongo: vocabulary per lesson
CREATE TABLE mnn_vocabulary (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id        uuid NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  lesson_id      uuid NOT NULL REFERENCES mnn_lessons(id) ON DELETE CASCADE,
  word           text NOT NULL,
  reading        text,
  romanization   text,
  meaning_vi     text NOT NULL,
  part_of_speech text,
  order_index    smallint DEFAULT 0
);

-- Minna no Nihongo: grammar points per lesson
CREATE TABLE mnn_grammar (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id        uuid NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  lesson_id      uuid NOT NULL REFERENCES mnn_lessons(id) ON DELETE CASCADE,
  pattern        text NOT NULL,
  explanation_vi text NOT NULL,
  example_ja     text,
  example_vi     text,
  order_index    smallint DEFAULT 0
);

-- Minna no Nihongo: exercises per lesson (fill_blank | multiple_choice)
CREATE TABLE mnn_exercises (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id        uuid NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  lesson_id      uuid NOT NULL REFERENCES mnn_lessons(id) ON DELETE CASCADE,
  type           text NOT NULL CHECK (type IN ('fill_blank', 'multiple_choice')),
  question       text NOT NULL,
  options        jsonb,
  answer         text NOT NULL,
  explanation_vi text,
  order_index    smallint DEFAULT 0
);

-- RLS: public read only
ALTER TABLE mnn_lessons    ENABLE ROW LEVEL SECURITY;
ALTER TABLE mnn_vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE mnn_grammar    ENABLE ROW LEVEL SECURITY;
ALTER TABLE mnn_exercises  ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read mnn_lessons"    ON mnn_lessons    FOR SELECT USING (true);
CREATE POLICY "public read mnn_vocabulary" ON mnn_vocabulary FOR SELECT USING (true);
CREATE POLICY "public read mnn_grammar"    ON mnn_grammar    FOR SELECT USING (true);
CREATE POLICY "public read mnn_exercises"  ON mnn_exercises  FOR SELECT USING (true);
