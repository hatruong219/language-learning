-- Migration: Create user_progress + study_sessions
-- 20260228000004_create_user_progress.sql

CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocabulary_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'new'
    CHECK (status IN ('new', 'learning', 'review', 'mastered')),
  correct_count INT NOT NULL DEFAULT 0,
  wrong_count INT NOT NULL DEFAULT 0,
  next_review_at TIMESTAMPTZ,
  last_studied_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT user_progress_unique UNIQUE (user_id, vocabulary_id)
);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_review ON user_progress(user_id, next_review_at);

CREATE TRIGGER update_user_progress_updated_at
  BEFORE UPDATE ON user_progress
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User read own progress"
ON user_progress FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "User insert own progress"
ON user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User update own progress"
ON user_progress FOR UPDATE USING (auth.uid() = user_id);

-- -----------------------------------------------

CREATE TABLE IF NOT EXISTS study_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deck_id UUID REFERENCES decks(id) ON DELETE SET NULL,
  mode VARCHAR(20) NOT NULL CHECK (mode IN ('flashcard', 'quiz', 'browse')),
  cards_studied INT NOT NULL DEFAULT 0,
  cards_correct INT NOT NULL DEFAULT 0,
  duration_seconds INT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_study_sessions_user ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_deck ON study_sessions(deck_id);

ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User read own sessions"
ON study_sessions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "User insert own sessions"
ON study_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
