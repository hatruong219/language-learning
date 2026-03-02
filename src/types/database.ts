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
