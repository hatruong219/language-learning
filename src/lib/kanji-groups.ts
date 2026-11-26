// Nhóm tra nhanh cho /kanji/daily: gom các chữ trong KANJI theo chủ đề
// (số, thứ, tháng…) + bảng cách đọc cho những bộ đọc bất quy tắc hay gặp.
// Chữ trong `kanji` phải có trong KANJI (daily-kanji.ts) — xem assertGroups().

import { KANJI, type KanjiWord } from '@/lib/daily-kanji'

export type ReadingTable = { title: string; words: KanjiWord[] }

export type KanjiGroup = {
  id: string
  label: string
  emoji: string
  kanji: string // các chữ, mỗi ký tự là một chữ có trong KANJI ('' nếu chỉ có bảng)
  tables?: ReadingTable[]
}

const DB = 'đọc đặc biệt'
const BA = 'biến âm'

export const KANJI_GROUPS: KanjiGroup[] = [
  {
    id: 'so',
    label: 'Số đếm',
    emoji: '🔢',
    kanji: '一二三四五六七八九十百千万円',
    tables: [
      {
        title: 'Số có 2 cách đọc',
        words: [
          ['四', 'よん', 'bốn', 'cũng đọc し, nhưng よん hay dùng hơn'],
          ['七', 'なな', 'bảy', 'cũng đọc しち'],
          ['九', 'きゅう', 'chín', 'cũng đọc く'],
        ],
      },
      {
        title: 'Trăm, nghìn, vạn',
        words: [
          ['百', 'ひゃく', '100'],
          ['三百', 'さんびゃく', '300', BA],
          ['六百', 'ろっぴゃく', '600', BA],
          ['八百', 'はっぴゃく', '800', BA],
          ['何百', 'なんびゃく', 'mấy trăm', BA],
          ['千', 'せん', '1.000'],
          ['三千', 'さんぜん', '3.000', BA],
          ['八千', 'はっせん', '8.000', BA],
          ['一万', 'いちまん', '10.000', 'không đọc まん'],
          ['百万', 'ひゃくまん', '1 triệu'],
        ],
      },
    ],
  },
  {
    id: 'dem',
    label: 'Đếm người & đồ vật',
    emoji: '🧮',
    kanji: '一二三四五六七八九十人何',
    tables: [
      {
        title: 'Đếm đồ vật (〜つ)',
        words: [
          ['一つ', 'ひとつ', '1 cái'],
          ['二つ', 'ふたつ', '2 cái'],
          ['三つ', 'みっつ', '3 cái'],
          ['四つ', 'よっつ', '4 cái'],
          ['五つ', 'いつつ', '5 cái'],
          ['六つ', 'むっつ', '6 cái'],
          ['七つ', 'ななつ', '7 cái'],
          ['八つ', 'やっつ', '8 cái'],
          ['九つ', 'ここのつ', '9 cái'],
          ['十', 'とお', '10 cái', 'không có つ'],
          ['いくつ', 'いくつ', 'mấy cái?'],
        ],
      },
      {
        title: 'Đếm người (〜人)',
        words: [
          ['一人', 'ひとり', '1 người', DB],
          ['二人', 'ふたり', '2 người', DB],
          ['三人', 'さんにん', '3 người'],
          ['四人', 'よにん', '4 người', 'không đọc よんにん'],
          ['五人', 'ごにん', '5 người'],
          ['六人', 'ろくにん', '6 người'],
          ['七人', 'ななにん', '7 người', 'cũng đọc しちにん'],
          ['八人', 'はちにん', '8 người'],
          ['九人', 'きゅうにん', '9 người'],
          ['十人', 'じゅうにん', '10 người'],
          ['何人', 'なんにん', 'mấy người?'],
        ],
      },
    ],
  },
  {
    id: 'thu',
    label: 'Thứ trong tuần',
    emoji: '📅',
    kanji: '月火水木金土日何週',
    tables: [
      {
        title: 'Các thứ (〜曜日)',
        words: [
          ['月曜日', 'げつようび', 'thứ Hai'],
          ['火曜日', 'かようび', 'thứ Ba'],
          ['水曜日', 'すいようび', 'thứ Tư'],
          ['木曜日', 'もくようび', 'thứ Năm'],
          ['金曜日', 'きんようび', 'thứ Sáu'],
          ['土曜日', 'どようび', 'thứ Bảy'],
          ['日曜日', 'にちようび', 'Chủ nhật'],
          ['何曜日', 'なんようび', 'thứ mấy?'],
        ],
      },
      {
        title: 'Tuần',
        words: [
          ['先週', 'せんしゅう', 'tuần trước'],
          ['今週', 'こんしゅう', 'tuần này'],
          ['来週', 'らいしゅう', 'tuần sau'],
          ['毎週', 'まいしゅう', 'mỗi tuần'],
        ],
      },
    ],
  },
  {
    id: 'ngay',
    label: 'Ngày',
    emoji: '📆',
    kanji: '日今毎何',
    tables: [
      {
        title: 'Ngày trong tháng',
        words: [
          ['一日', 'ついたち', 'mùng 1', DB],
          ['二日', 'ふつか', 'mùng 2', DB],
          ['三日', 'みっか', 'mùng 3', DB],
          ['四日', 'よっか', 'mùng 4', DB],
          ['五日', 'いつか', 'mùng 5', DB],
          ['六日', 'むいか', 'mùng 6', DB],
          ['七日', 'なのか', 'mùng 7', DB],
          ['八日', 'ようか', 'mùng 8', DB],
          ['九日', 'ここのか', 'mùng 9', DB],
          ['十日', 'とおか', 'mùng 10', DB],
          ['十一日', 'じゅういちにち', 'ngày 11 (từ đây đọc theo số + にち)'],
          ['十四日', 'じゅうよっか', 'ngày 14', DB],
          ['二十日', 'はつか', 'ngày 20', DB],
          ['二十四日', 'にじゅうよっか', 'ngày 24', DB],
          ['何日', 'なんにち', 'ngày mấy?'],
        ],
      },
      {
        title: 'Hôm qua, hôm nay, ngày mai',
        words: [
          ['昨日', 'きのう', 'hôm qua', DB],
          ['今日', 'きょう', 'hôm nay', DB],
          ['明日', 'あした', 'ngày mai', DB],
          ['毎日', 'まいにち', 'mỗi ngày'],
        ],
      },
    ],
  },
  {
    id: 'thang',
    label: 'Tháng',
    emoji: '🗓️',
    kanji: '月先今来毎何',
    tables: [
      {
        title: 'Các tháng (〜月)',
        words: [
          ['一月', 'いちがつ', 'tháng Một'],
          ['二月', 'にがつ', 'tháng Hai'],
          ['三月', 'さんがつ', 'tháng Ba'],
          ['四月', 'しがつ', 'tháng Tư', 'không đọc よんがつ'],
          ['五月', 'ごがつ', 'tháng Năm'],
          ['六月', 'ろくがつ', 'tháng Sáu'],
          ['七月', 'しちがつ', 'tháng Bảy', 'đọc しち, không đọc なな'],
          ['八月', 'はちがつ', 'tháng Tám'],
          ['九月', 'くがつ', 'tháng Chín', 'không đọc きゅうがつ'],
          ['十月', 'じゅうがつ', 'tháng Mười'],
          ['十一月', 'じゅういちがつ', 'tháng Mười một'],
          ['十二月', 'じゅうにがつ', 'tháng Mười hai'],
          ['何月', 'なんがつ', 'tháng mấy?'],
        ],
      },
      {
        title: 'Tháng trước, tháng này…',
        words: [
          ['先月', 'せんげつ', 'tháng trước'],
          ['今月', 'こんげつ', 'tháng này'],
          ['来月', 'らいげつ', 'tháng sau'],
          ['毎月', 'まいつき', 'mỗi tháng', 'không đọc まいげつ'],
        ],
      },
    ],
  },
  {
    id: 'gio',
    label: 'Giờ & phút',
    emoji: '⏰',
    kanji: '時分半午前後間何',
    tables: [
      {
        title: 'Giờ (〜時)',
        words: [
          ['一時', 'いちじ', '1 giờ'],
          ['二時', 'にじ', '2 giờ'],
          ['三時', 'さんじ', '3 giờ'],
          ['四時', 'よじ', '4 giờ', 'không đọc よんじ'],
          ['五時', 'ごじ', '5 giờ'],
          ['六時', 'ろくじ', '6 giờ'],
          ['七時', 'しちじ', '7 giờ', 'đọc しち, không đọc なな'],
          ['八時', 'はちじ', '8 giờ'],
          ['九時', 'くじ', '9 giờ', 'không đọc きゅうじ'],
          ['十時', 'じゅうじ', '10 giờ'],
          ['十一時', 'じゅういちじ', '11 giờ'],
          ['十二時', 'じゅうにじ', '12 giờ'],
          ['何時', 'なんじ', 'mấy giờ?'],
          ['三時半', 'さんじはん', '3 giờ rưỡi'],
          ['午前', 'ごぜん', 'buổi sáng (AM)'],
          ['午後', 'ごご', 'buổi chiều (PM)'],
        ],
      },
      {
        title: 'Phút (〜分)',
        words: [
          ['一分', 'いっぷん', '1 phút', BA],
          ['二分', 'にふん', '2 phút'],
          ['三分', 'さんぷん', '3 phút', BA],
          ['四分', 'よんぷん', '4 phút', BA],
          ['五分', 'ごふん', '5 phút'],
          ['六分', 'ろっぷん', '6 phút', BA],
          ['七分', 'ななふん', '7 phút'],
          ['八分', 'はっぷん', '8 phút', 'biến âm (cũng đọc はちふん)'],
          ['九分', 'きゅうふん', '9 phút'],
          ['十分', 'じゅっぷん', '10 phút', 'biến âm (cũng đọc じっぷん)'],
          ['何分', 'なんぷん', 'mấy phút?', BA],
          ['半', 'はん', 'rưỡi (30 phút)'],
        ],
      },
    ],
  },
  {
    id: 'thoigian',
    label: 'Thời gian',
    emoji: '⏳',
    kanji: '日月年時分半週毎今午前後先来',
    tables: [
      {
        title: 'Năm',
        words: [
          ['去年', 'きょねん', 'năm ngoái'],
          ['今年', 'ことし', 'năm nay', DB],
          ['来年', 'らいねん', 'năm sau'],
          ['毎年', 'まいとし', 'mỗi năm', 'cũng đọc まいねん'],
        ],
      },
    ],
  },
  { id: 'huong', label: 'Phương hướng & vị trí', emoji: '🧭', kanji: '上下左右東西南北中外前後' },
  { id: 'nguoi', label: 'Người & gia đình', emoji: '👪', kanji: '人男女子父母友先生名' },
  { id: 'cothe', label: 'Cơ thể', emoji: '🖐️', kanji: '口目耳手足' },
  { id: 'dongtu', label: 'Động từ', emoji: '🏃', kanji: '行来食飲見聞書読話買休会出入' },
  { id: 'tinhtu', label: 'Tính từ', emoji: '🎨', kanji: '大小高安新古長白' },
  { id: 'thiennhien', label: 'Thiên nhiên & thời tiết', emoji: '⛰️', kanji: '山川天気雨水火木金土日月' },
  { id: 'noichon', label: 'Trường học & nơi chốn', emoji: '🏫', kanji: '学校国社駅店道車電語本' },
]

/** Các chữ trong nhóm không có trong KANJI (rỗng = hợp lệ). */
export function missingKanji(groups: KanjiGroup[] = KANJI_GROUPS): string[] {
  const known = new Set(KANJI.map((x) => x.k))
  return groups.flatMap((g) => [...g.kanji].filter((c) => !known.has(c)).map((c) => `${g.id}:${c}`))
}

// Kiểm tra lúc dev: sai thì vỡ ngay khi mở trang thay vì lặng lẽ thiếu chip.
if (process.env.NODE_ENV !== 'production') {
  const missing = missingKanji()
  if (missing.length > 0) throw new Error(`kanji-groups: chữ không có trong KANJI: ${missing.join(', ')}`)
}
