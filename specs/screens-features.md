# Screens & Features — Language Learning

> Priority: 🔴 P0 (MVP) → 🟡 P1 (Phase 2) → 🟢 P2 (Future)

---

## Sitemap

```
/ (Home)
├── /vocabulary                    ← Danh sách tất cả từ
│   ├── /vocabulary?deck=xxx       ← Lọc theo deck
│   └── /vocabulary/[word-id]      ← Chi tiết từ
├── /decks                         ← Danh sách deck/topic
│   └── /decks/[deck-slug]         ← Từ trong deck đó
├── /flashcard                     ← Học flashcard (random toàn bộ)
│   └── /flashcard/[deck-slug]     ← Flashcard theo deck
├── /alphabet                      ← Bảng chữ cái
│   ├── /alphabet/hiragana         ← Bảng hiragana
│   └── /alphabet/katakana         ← Bảng katakana
├── /quiz                          ← Quiz mode (Phase 2)
└── /profile                       ← Tiến trình cá nhân (Phase 2)
```

---

## Chi tiết từng màn hình

---

### 🔴 [S01] Home Page — `/`

**Mục đích:** Landing page, điểm vào chính

**Layout:**
```
[Header: Logo + Nav]
[Hero: "Học Tiếng Nhật Mỗi Ngày" + CTA buttons]
[Section: Quick Stats — X từ vựng, Y deck]
[Section: Decks nổi bật — Grid cards (4-6 deck)]
[Section: Từ ngẫu nhiên hôm nay (3 từ)]
[Footer]
```

**Components:**
- `HeroSection` — tagline, 2 button: "Bắt đầu học" → /flashcard, "Xem từ vựng" → /vocabulary
- `DeckCard` — hiển thị deck với emoji, tên, số từ, progress bar (nếu login)
- `WordOfTheDay` — 3 từ ngẫu nhiên, có nút nghe

**Actions:**
- Click deck → /decks/[slug]
- Click "Bắt đầu học" → /flashcard (random từ deck đầu tiên)

---

### 🔴 [S02] Vocabulary List — `/vocabulary`

**Mục đích:** Danh sách từ vựng, có thể lọc/tìm kiếm

**Layout:**
```
[FilterBar: Deck selector | JLPT filter | Search input]
[VocabGrid hoặc VocabTable — toggle view]
[Pagination hoặc Infinite scroll]
```

**VocabCard hiển thị:**
- Từ gốc (chữ Nhật, to, rõ) — font Noto Sans JP
- Furigana (bên trên / bên dưới từ gốc)
- Romaji
- Nghĩa tiếng Việt
- Tags (JLPT level badge)
- 🔊 Nút nghe TTS
- (Optional) Nút "Đã thuộc" / bookmark

**Filter options:**
- Deck / Topic
- JLPT Level (N5, N4, N3, N2, N1)
- Search: tìm theo từ hoặc nghĩa

**Data:** Server Component — fetch từ Supabase, paginated (20/page)

---

### 🔴 [S03] Vocabulary Detail — `/vocabulary/[id]`

**Layout:**
```
[Breadcrumb: Vocabulary > Từ này]
[Card chính]
  - Từ gốc (rất to)
  - Furigana + Romaji
  - Nút nghe 🔊 (TTS)
  - Part of speech badge
  - JLPT badge
  - Nghĩa VI / EN
[Section: Câu ví dụ (1-3 câu)]
  - Câu tiếng Nhật
  - Furigana của câu
  - Dịch tiếng Việt
[Section: Từ cùng deck]
[Actions: ← Từ trước | Từ sau →]
```

---

### 🔴 [S04] Deck List — `/decks`

**Layout:**
```
[Page title: "Chủ đề học tập"]
[Filter: language selector (hiện tại chỉ 🇯🇵 Nhật)]
[Grid: DeckCard x N]
```

**DeckCard:**
- Emoji icon + Cover image
- Tên deck
- Số từ trong deck
- Mô tả ngắn
- Button: "Học ngay" → /flashcard/[slug] | "Xem từ" → /decks/[slug]

---

### 🔴 [S05] Deck Detail — `/decks/[slug]`

**Tương tự S02 (Vocabulary List) nhưng:**
- Header lớn: tên deck, mô tả, số từ
- Đã lọc sẵn theo deck đó
- Button "Học Flashcard" → /flashcard/[slug]

---

### 🔴 [S06] Flashcard Study — `/flashcard` và `/flashcard/[deck-slug]`

**Đây là màn hình quan trọng nhất.**

**Layout:**
```
[Header: Deck name | Progress: X/Y | Nút Exit]
[Flashcard chính — center, full height]
  [Mặt trước]
    - Từ gốc (chữ Nhật, cực to)
    - Furigana
    - (Từ chưa lật)
  [Mặt sau — sau khi tap/click]
    - Từ gốc + Furigana
    - Romaji
    - Nghĩa tiếng Việt
    - Câu ví dụ
    - 🔊 Auto-play TTS khi lật
[Controls (sau khi lật)]
  [❌ Chưa thuộc] [⭐ Xem lại] [✅ Đã thuộc]
[Bottom: Progress bar]
```

**Logic:**
- Shuffle ngẫu nhiên toàn bộ từ trong deck (hoặc tất cả nếu không chọn deck)
- Tap/click card → flip animation (framer-motion)
- Auto-play TTS khi flip sang mặt sau
- 3 nút feedback: Chưa thuộc / Xem lại / Đã thuộc → lưu vào `user_progress` (nếu login), nếu không login thì chỉ local state
- Khi hết deck → màn hình tổng kết (correct/review/wrong count)
- Phím tắt: Space = flip, ← = wrong, → = correct

**Variants:**
- **Random mode** (default): random toàn bộ
- **Review mode** (Phase 2): chỉ từ `status = 'learning'` hoặc `next_review_at <= now()`

---

### 🔴 [S07] Alphabet Chart — `/alphabet`

**Layout:**
```
[Tab: Hiragana | Katakana]
[Grid bảng chữ cái theo nhóm hàng]
  Hàng A: あ(a) い(i) う(u) え(e) お(o)
  Hàng Ka: か(ka) き(ki) く(ku) け(ke) こ(ko)
  ...
[Ghi chú: Dakuten (゛), Handakuten (゜)]
```

**CharacterCell:**
- Ký tự lớn (to, rõ)
- Romaji bên dưới
- Click/tap → popup chi tiết:
  - Ký tự to hơn
  - Cách đọc
  - Nút TTS nghe phát âm
  - Gif stroke order (nếu có)
  - Katakana tương ứng (nếu đang xem Hiragana)

---

### 🟡 [S08] Quiz Mode — `/quiz`

**Phase 2**

**Layout:**
```
[Câu hỏi: Chữ/Từ tiếng Nhật]
[4 đáp án (multiple choice)]
[Timer bar (optional)]
[Kết quả: ✅ Đúng / ❌ Sai + giải thích]
[Next question →]
```

**Modes:**
- Nhật → Việt (xem chữ, chọn nghĩa)
- Việt → Nhật (xem nghĩa, chọn chữ đúng)
- Nghe → Chữ (TTS phát, gõ/chọn chữ đúng)

---

### 🟡 [S09] Profile & Progress — `/profile`

**Phase 2 — cần auth**

**Layout:**
```
[User info]
[Stats: Tổng từ đã học | Streak | Số phiên học]
[Chart: Biểu đồ học tập theo ngày/tuần]
[Deck progress: từng deck bao nhiêu % mastered]
[Lịch sử phiên học]
```

---

## Shared Components

| Component | Mô tả |
|-----------|-------|
| `WordCard` | Card từ vựng (dùng ở list, home) |
| `FlashCard` | Card học flashcard (flip animation) |
| `TTSButton` | Nút loa dùng Web Speech API |
| `FuriganaText` | Hiển thị chữ Nhật kèm furigana (ruby tag) |
| `JLPTBadge` | Badge N5/N4/N3/N2/N1 |
| `DeckCard` | Card deck/topic |
| `CharacterCell` | Ô bảng chữ cái |
| `ProgressBar` | Thanh tiến trình flashcard |
| `StudyStats` | Thống kê học tập |

---

## Navigation

**Header:**
- Logo / Tên app
- Links: Từ vựng | Deck | Flashcard | Bảng chữ cái
- (Phase 2) Avatar / Login button

**Mobile:** Bottom navigation bar với icon

---

## TTS Implementation

```ts
// lib/tts.ts
export function speak(text: string, lang = 'ja-JP') {
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.8  // chậm hơn bình thường để dễ nghe
  window.speechSynthesis.speak(utterance)
}
```

> Fallback: nếu browser không support → ẩn nút TTS, không báo lỗi
