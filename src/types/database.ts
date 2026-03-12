export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      decks: {
        Row: {
          id: string
          site_id: string
          language_code: string
          name: string
          description: string | null
          slug: string
          emoji: string | null
          cover_image_url: string | null
          is_public: boolean
          order_index: number
          metadata: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          site_id: string
          language_code?: string
          name: string
          description?: string | null
          slug: string
          emoji?: string | null
          cover_image_url?: string | null
          is_public?: boolean
          order_index?: number
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          site_id?: string
          language_code?: string
          name?: string
          description?: string | null
          slug?: string
          emoji?: string | null
          cover_image_url?: string | null
          is_public?: boolean
          order_index?: number
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
      }
      vocabulary: {
        Row: {
          id: string
          site_id: string
          deck_id: string
          language_code: string
          word: string
          reading: string | null
          romanization: string | null
          meaning_vi: string
          meaning_en: string | null
          part_of_speech: string | null
          jlpt_level: string | null
          audio_url: string | null
          image_url: string | null
          tags: string[]
          order_index: number
          is_active: boolean
          metadata: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          site_id: string
          deck_id: string
          language_code?: string
          word: string
          reading?: string | null
          romanization?: string | null
          meaning_vi: string
          meaning_en?: string | null
          part_of_speech?: string | null
          jlpt_level?: string | null
          audio_url?: string | null
          image_url?: string | null
          tags?: string[]
          order_index?: number
          is_active?: boolean
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          site_id?: string
          deck_id?: string
          language_code?: string
          word?: string
          reading?: string | null
          romanization?: string | null
          meaning_vi?: string
          meaning_en?: string | null
          part_of_speech?: string | null
          jlpt_level?: string | null
          audio_url?: string | null
          image_url?: string | null
          tags?: string[]
          order_index?: number
          is_active?: boolean
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
      }
      vocabulary_examples: {
        Row: {
          id: string
          vocabulary_id: string
          sentence: string
          sentence_reading: string | null
          translation_vi: string | null
          translation_en: string | null
          created_at: string
        }
        Insert: {
          id?: string
          vocabulary_id: string
          sentence: string
          sentence_reading?: string | null
          translation_vi?: string | null
          translation_en?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          vocabulary_id?: string
          sentence?: string
          sentence_reading?: string | null
          translation_vi?: string | null
          translation_en?: string | null
          created_at?: string
        }
      }
      alphabet_characters: {
        Row: {
          id: string
          site_id: string
          language_code: string
          script: string
          character: string
          romanization: string
          group_name: string | null
          stroke_order_url: string | null
          order_index: number | null
          created_at: string
        }
        Insert: {
          id?: string
          site_id: string
          language_code?: string
          script: string
          character: string
          romanization: string
          group_name?: string | null
          stroke_order_url?: string | null
          order_index?: number | null
          created_at?: string
        }
        Update: {
          id?: string
          site_id?: string
          language_code?: string
          script?: string
          character?: string
          romanization?: string
          group_name?: string | null
          stroke_order_url?: string | null
          order_index?: number | null
          created_at?: string
        }
      }
      user_progress: {
        Row: {
          id: string
          user_id: string
          vocabulary_id: string
          status: 'new' | 'learning' | 'review' | 'mastered'
          correct_count: number
          wrong_count: number
          next_review_at: string | null
          last_studied_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          vocabulary_id: string
          status?: 'new' | 'learning' | 'review' | 'mastered'
          correct_count?: number
          wrong_count?: number
          next_review_at?: string | null
          last_studied_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          vocabulary_id?: string
          status?: 'new' | 'learning' | 'review' | 'mastered'
          correct_count?: number
          wrong_count?: number
          next_review_at?: string | null
          last_studied_at?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      feedbacks: {
        Row: {
          id: string
          site_id: string
          name: string
          email: string | null
          message: string
          rating: number | null
          image: string | null
          status: 'pending' | 'reviewed' | 'archived'
          metadata: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          site_id: string
          name: string
          email?: string | null
          message: string
          rating?: number | null
          image?: string | null
          status?: 'pending' | 'reviewed' | 'archived'
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          site_id?: string
          name?: string
          email?: string | null
          message?: string
          rating?: number | null
          image?: string | null
          status?: 'pending' | 'reviewed' | 'archived'
          metadata?: Json
          created_at?: string
          updated_at?: string
        }
      }
      writing_prompts: {
        Row: {
          id: string
          site_id: string
          title: string
          prompt_vi: string
          prompt_ja: string | null
          category: 'self' | 'family' | 'hobby' | 'general'
          jlpt_level: string | null
          min_words: number
          is_active: boolean
          order_index: number
          created_at: string
        }
        Insert: {
          id?: string
          site_id: string
          title: string
          prompt_vi: string
          prompt_ja?: string | null
          category?: 'self' | 'family' | 'hobby' | 'general'
          jlpt_level?: string | null
          min_words?: number
          is_active?: boolean
          order_index?: number
          created_at?: string
        }
        Update: {
          id?: string
          site_id?: string
          title?: string
          prompt_vi?: string
          prompt_ja?: string | null
          category?: 'self' | 'family' | 'hobby' | 'general'
          jlpt_level?: string | null
          min_words?: number
          is_active?: boolean
          order_index?: number
          created_at?: string
        }
      }
      writing_submissions: {
        Row: {
          id: string
          site_id: string
          prompt_id: string
          user_id: string | null
          session_id: string | null
          response: string
          word_count: number | null
          score: number | null
          score_grammar: number | null
          score_vocab: number | null
          score_content: number | null
          feedback_vi: string | null
          errors: Json
          is_valid_lang: boolean | null
          graded_at: string | null
          created_at: string
        }
        Insert: {
          id?: string
          site_id: string
          prompt_id: string
          user_id?: string | null
          session_id?: string | null
          response: string
          score?: number | null
          score_grammar?: number | null
          score_vocab?: number | null
          score_content?: number | null
          feedback_vi?: string | null
          errors?: Json
          is_valid_lang?: boolean | null
          graded_at?: string | null
          created_at?: string
        }
        Update: {
          score?: number | null
          score_grammar?: number | null
          score_vocab?: number | null
          score_content?: number | null
          feedback_vi?: string | null
          errors?: Json
          is_valid_lang?: boolean | null
          graded_at?: string | null
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}

// Convenient row type aliases
export type Deck = Database['public']['Tables']['decks']['Row']
export type Vocabulary = Database['public']['Tables']['vocabulary']['Row']
export type VocabularyExample = Database['public']['Tables']['vocabulary_examples']['Row']
export type AlphabetCharacter = Database['public']['Tables']['alphabet_characters']['Row']
export type UserProgress = Database['public']['Tables']['user_progress']['Row']
export type Feedback = Database['public']['Tables']['feedbacks']['Row']
export type WritingPrompt = Database['public']['Tables']['writing_prompts']['Row']
export type WritingSubmission = Database['public']['Tables']['writing_submissions']['Row']

// Writing test specific
export type GradingError = {
  original: string
  corrected: string
  explanation_vi: string
}

export type GradingResult = {
  score: number
  score_grammar: number
  score_vocab: number
  score_content: number
  feedback_vi: string
  errors: GradingError[]
  is_valid_lang: boolean
}

// Character writing practice grading
export type CharacterGradingResult = {
  is_correct: boolean
  score: number           // 0-100
  feedback_vi: string
  stroke_notes: string[]  // nhận xét từng nét
}

// With relations
export type VocabularyWithDeck = Vocabulary & {
  deck: Pick<Deck, 'name' | 'slug' | 'emoji'> | null
}

export type VocabularyWithExamples = Vocabulary & {
  vocabulary_examples: VocabularyExample[]
  deck: Pick<Deck, 'name' | 'slug' | 'emoji'> | null
}

export type DeckWithCount = Deck & {
  vocabulary_count: number
}
