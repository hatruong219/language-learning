// Danh sách kanji cho /kanji/daily. Fix cứng (không lấy từ bảng jlpt_kanji)
// để tự quyết lộ trình: thứ tự trong mảng = thứ tự học, mỗi ngày mở 1 chữ mới
// bắt đầu từ START_DATE. Hết danh sách thì không lặp lại — chỉ còn ôn theo
// lịch nhắc lại (xem kanji-srs.ts). Thêm chữ vào cuối mảng là học tiếp.
// Thêm chữ mới thì copy file nét public/kanjivg/<kvgCode>.svg từ KanjiVG.

/** [từ, cách đọc, nghĩa, ghi chú khi cách đọc bất thường] */
export type KanjiWord = [string, string, string, string?]

export type DailyKanji = {
  k: string // chữ
  hv: string // Hán-Việt
  mean: string // nghĩa chính
  on: string // âm On
  kun: string // âm Kun ('' nếu không dùng)
  words: KanjiWord[] // 2–3 từ thông dụng chứa chữ này
  similar?: [string, string][] // chữ dễ nhầm: [chữ, nghĩa]
}

export const START_DATE = '2026-11-27' // ngày học chữ đầu tiên (giờ VN)

const DB = 'đọc đặc biệt'
const BA = 'biến âm'

export const KANJI: DailyKanji[] = [
  { k: '日', hv: 'NHẬT', mean: 'ngày, mặt trời', on: 'ニチ・ジツ', kun: 'ひ・か', words: [['日本', 'にほん', 'Nhật Bản'], ['毎日', 'まいにち', 'mỗi ngày'], ['今日', 'きょう', 'hôm nay', DB]], similar: [['目', 'mắt'], ['白', 'trắng']] },
  { k: '本', hv: 'BẢN', mean: 'sách, gốc', on: 'ホン', kun: 'もと', words: [['本', 'ほん', 'sách'], ['日本', 'にほん', 'Nhật Bản'], ['本屋', 'ほんや', 'hiệu sách']], similar: [['木', 'cây'], ['体', 'cơ thể']] },
  { k: '人', hv: 'NHÂN', mean: 'người', on: 'ジン・ニン', kun: 'ひと', words: [['日本人', 'にほんじん', 'người Nhật'], ['一人', 'ひとり', 'một người', DB], ['大人', 'おとな', 'người lớn', DB]], similar: [['入', 'vào'], ['八', 'tám']] },
  { k: '一', hv: 'NHẤT', mean: 'một', on: 'イチ・イツ', kun: 'ひと（つ）', words: [['一つ', 'ひとつ', 'một cái'], ['一月', 'いちがつ', 'tháng Một'], ['一日', 'ついたち', 'ngày mùng 1', DB]], similar: [['ー', 'dấu trường âm katakana']] },
  { k: '二', hv: 'NHỊ', mean: 'hai', on: 'ニ', kun: 'ふた（つ）', words: [['二つ', 'ふたつ', 'hai cái'], ['二人', 'ふたり', 'hai người', DB], ['二十日', 'はつか', 'ngày 20', DB]], similar: [['ニ', 'chữ ni katakana']] },
  { k: '三', hv: 'TAM', mean: 'ba', on: 'サン', kun: 'み・みっ（つ）', words: [['三つ', 'みっつ', 'ba cái'], ['三月', 'さんがつ', 'tháng Ba'], ['三日', 'みっか', 'ngày mùng 3']] },
  { k: '四', hv: 'TỨ', mean: 'bốn', on: 'シ', kun: 'よ・よん・よっ（つ）', words: [['四つ', 'よっつ', 'bốn cái'], ['四月', 'しがつ', 'tháng Tư', 'không đọc よんがつ'], ['四時', 'よじ', '4 giờ', 'không đọc よんじ']], similar: [['西', 'phía tây']] },
  { k: '五', hv: 'NGŨ', mean: 'năm (số 5)', on: 'ゴ', kun: 'いつ（つ）', words: [['五つ', 'いつつ', 'năm cái'], ['五月', 'ごがつ', 'tháng Năm'], ['五日', 'いつか', 'ngày mùng 5']] },
  { k: '六', hv: 'LỤC', mean: 'sáu', on: 'ロク', kun: 'む・むっ（つ）', words: [['六つ', 'むっつ', 'sáu cái'], ['六月', 'ろくがつ', 'tháng Sáu'], ['六百', 'ろっぴゃく', '600', BA]] },
  { k: '七', hv: 'THẤT', mean: 'bảy', on: 'シチ', kun: 'なな（つ）・なの', words: [['七つ', 'ななつ', 'bảy cái'], ['七月', 'しちがつ', 'tháng Bảy'], ['七日', 'なのか', 'ngày mùng 7']] },
  { k: '八', hv: 'BÁT', mean: 'tám', on: 'ハチ', kun: 'や・やっ（つ）', words: [['八つ', 'やっつ', 'tám cái'], ['八月', 'はちがつ', 'tháng Tám'], ['八百屋', 'やおや', 'cửa hàng rau', DB]], similar: [['人', 'người'], ['入', 'vào']] },
  { k: '九', hv: 'CỬU', mean: 'chín', on: 'キュウ・ク', kun: 'ここの（つ）', words: [['九つ', 'ここのつ', 'chín cái'], ['九月', 'くがつ', 'tháng Chín', 'không đọc きゅうがつ'], ['九時', 'くじ', '9 giờ', 'không đọc きゅうじ']], similar: [['丸', 'tròn'], ['力', 'sức lực']] },
  { k: '十', hv: 'THẬP', mean: 'mười', on: 'ジュウ・ジッ', kun: 'とお・と', words: [['十', 'とお', 'mười cái'], ['十月', 'じゅうがつ', 'tháng Mười'], ['二十歳', 'はたち', '20 tuổi', DB]], similar: [['千', 'nghìn']] },
  { k: '百', hv: 'BÁCH', mean: 'trăm', on: 'ヒャク', kun: '', words: [['百円', 'ひゃくえん', '100 yên'], ['三百', 'さんびゃく', '300', BA], ['八百', 'はっぴゃく', '800', BA]], similar: [['白', 'trắng']] },
  { k: '千', hv: 'THIÊN', mean: 'nghìn', on: 'セン', kun: 'ち', words: [['千円', 'せんえん', '1.000 yên'], ['三千', 'さんぜん', '3.000', BA], ['八千', 'はっせん', '8.000', BA]], similar: [['十', 'mười'], ['干', 'khô']] },
  { k: '万', hv: 'VẠN', mean: 'mười nghìn', on: 'マン・バン', kun: '', words: [['一万円', 'いちまんえん', '10.000 yên'], ['百万', 'ひゃくまん', '1 triệu'], ['万年筆', 'まんねんひつ', 'bút máy']], similar: [['方', 'phương hướng']] },
  { k: '円', hv: 'VIÊN', mean: 'yên (tiền Nhật), tròn', on: 'エン', kun: 'まる（い）', words: [['百円', 'ひゃくえん', '100 yên'], ['千円', 'せんえん', '1.000 yên'], ['円い', 'まるい', 'tròn']], similar: [['内', 'bên trong']] },
  { k: '月', hv: 'NGUYỆT', mean: 'mặt trăng, tháng', on: 'ゲツ・ガツ', kun: 'つき', words: [['月曜日', 'げつようび', 'thứ Hai'], ['一月', 'いちがつ', 'tháng Một'], ['毎月', 'まいつき', 'mỗi tháng']], similar: [['目', 'mắt'], ['用', 'dùng']] },
  { k: '火', hv: 'HỎA', mean: 'lửa', on: 'カ', kun: 'ひ', words: [['火曜日', 'かようび', 'thứ Ba'], ['火', 'ひ', 'lửa'], ['花火', 'はなび', 'pháo hoa']] },
  { k: '水', hv: 'THỦY', mean: 'nước', on: 'スイ', kun: 'みず', words: [['水曜日', 'すいようび', 'thứ Tư'], ['水', 'みず', 'nước'], ['水道', 'すいどう', 'nước máy']], similar: [['氷', 'băng'], ['永', 'vĩnh viễn']] },
  { k: '木', hv: 'MỘC', mean: 'cây', on: 'モク・ボク', kun: 'き', words: [['木曜日', 'もくようび', 'thứ Năm'], ['木', 'き', 'cây']], similar: [['本', 'sách'], ['未', 'chưa']] },
  { k: '金', hv: 'KIM', mean: 'vàng, tiền', on: 'キン・コン', kun: 'かね', words: [['金曜日', 'きんようび', 'thứ Sáu'], ['お金', 'おかね', 'tiền'], ['お金持ち', 'おかねもち', 'người giàu']], similar: [['全', 'toàn bộ']] },
  { k: '土', hv: 'THỔ', mean: 'đất', on: 'ド・ト', kun: 'つち', words: [['土曜日', 'どようび', 'thứ Bảy'], ['土', 'つち', 'đất'], ['お土産', 'おみやげ', 'quà lưu niệm', DB]], similar: [['士', 'kẻ sĩ'], ['上', 'trên']] },
  { k: '年', hv: 'NIÊN', mean: 'năm', on: 'ネン', kun: 'とし', words: [['今年', 'ことし', 'năm nay', DB], ['来年', 'らいねん', 'năm sau'], ['毎年', 'まいとし', 'mỗi năm']], similar: [['午', 'trưa']] },
  { k: '時', hv: 'THỜI', mean: 'giờ, thời gian', on: 'ジ', kun: 'とき', words: [['時間', 'じかん', 'thời gian'], ['何時', 'なんじ', 'mấy giờ'], ['時計', 'とけい', 'đồng hồ', DB]], similar: [['持', 'cầm'], ['待', 'chờ']] },
  { k: '分', hv: 'PHÂN', mean: 'phút, chia, hiểu', on: 'ブン・フン・プン', kun: 'わ（かる）・わ（ける）', words: [['分かる', 'わかる', 'hiểu'], ['五分', 'ごふん', '5 phút'], ['十分', 'じゅっぷん', '10 phút', BA]] },
  { k: '半', hv: 'BÁN', mean: 'một nửa', on: 'ハン', kun: 'なか（ば）', words: [['半分', 'はんぶん', 'một nửa'], ['三時半', 'さんじはん', '3 giờ rưỡi'], ['半年', 'はんとし', 'nửa năm']], similar: [['平', 'bằng phẳng']] },
  { k: '今', hv: 'KIM', mean: 'bây giờ', on: 'コン・キン', kun: 'いま', words: [['今', 'いま', 'bây giờ'], ['今日', 'きょう', 'hôm nay', DB], ['今週', 'こんしゅう', 'tuần này']], similar: [['会', 'gặp'], ['令', 'mệnh lệnh']] },
  { k: '何', hv: 'HÀ', mean: 'cái gì', on: 'カ', kun: 'なに・なん', words: [['何', 'なに', 'cái gì'], ['何時', 'なんじ', 'mấy giờ'], ['何人', 'なんにん', 'mấy người']] },
  { k: '先', hv: 'TIÊN', mean: 'trước', on: 'セン', kun: 'さき', words: [['先生', 'せんせい', 'giáo viên'], ['先週', 'せんしゅう', 'tuần trước'], ['先月', 'せんげつ', 'tháng trước']] },
  { k: '生', hv: 'SINH', mean: 'sống, sinh ra', on: 'セイ・ショウ', kun: 'い（きる）・う（まれる）', words: [['学生', 'がくせい', 'học sinh, sinh viên'], ['生まれる', 'うまれる', 'được sinh ra'], ['誕生日', 'たんじょうび', 'sinh nhật']], similar: [['牛', 'con bò']] },
  { k: '学', hv: 'HỌC', mean: 'học', on: 'ガク', kun: 'まな（ぶ）', words: [['学生', 'がくせい', 'học sinh, sinh viên'], ['大学', 'だいがく', 'đại học'], ['学校', 'がっこう', 'trường học', BA]], similar: [['字', 'chữ']] },
  { k: '校', hv: 'HIỆU', mean: 'trường học', on: 'コウ', kun: '', words: [['学校', 'がっこう', 'trường học'], ['高校', 'こうこう', 'trường cấp 3'], ['校長', 'こうちょう', 'hiệu trưởng']], similar: [['交', 'giao']] },
  { k: '大', hv: 'ĐẠI', mean: 'to, lớn', on: 'ダイ・タイ', kun: 'おお（きい）', words: [['大きい', 'おおきい', 'to, lớn'], ['大学', 'だいがく', 'đại học'], ['大人', 'おとな', 'người lớn', DB]], similar: [['太', 'béo'], ['犬', 'con chó'], ['天', 'trời']] },
  { k: '小', hv: 'TIỂU', mean: 'nhỏ', on: 'ショウ', kun: 'ちい（さい）・こ', words: [['小さい', 'ちいさい', 'nhỏ'], ['小学校', 'しょうがっこう', 'trường tiểu học'], ['小鳥', 'ことり', 'chim nhỏ']], similar: [['少', 'ít']] },
  { k: '中', hv: 'TRUNG', mean: 'giữa, bên trong', on: 'チュウ・ジュウ', kun: 'なか', words: [['中', 'なか', 'bên trong'], ['中国', 'ちゅうごく', 'Trung Quốc'], ['一日中', 'いちにちじゅう', 'suốt cả ngày', BA]], similar: [['虫', 'côn trùng']] },
  { k: '国', hv: 'QUỐC', mean: 'đất nước', on: 'コク', kun: 'くに', words: [['国', 'くに', 'đất nước'], ['中国', 'ちゅうごく', 'Trung Quốc'], ['外国', 'がいこく', 'nước ngoài']] },
  { k: '外', hv: 'NGOẠI', mean: 'bên ngoài', on: 'ガイ・ゲ', kun: 'そと・ほか', words: [['外', 'そと', 'bên ngoài'], ['外国人', 'がいこくじん', 'người nước ngoài']] },
  { k: '行', hv: 'HÀNH', mean: 'đi', on: 'コウ・ギョウ', kun: 'い（く）・おこな（う）', words: [['行く', 'いく', 'đi'], ['銀行', 'ぎんこう', 'ngân hàng'], ['旅行', 'りょこう', 'du lịch']] },
  { k: '来', hv: 'LAI', mean: 'đến', on: 'ライ', kun: 'く（る）・き（ます）', words: [['来る', 'くる', 'đến'], ['来週', 'らいしゅう', 'tuần sau'], ['来年', 'らいねん', 'năm sau']], similar: [['米', 'gạo']] },
  { k: '食', hv: 'THỰC', mean: 'ăn', on: 'ショク', kun: 'た（べる）', words: [['食べる', 'たべる', 'ăn'], ['食べ物', 'たべもの', 'đồ ăn'], ['食堂', 'しょくどう', 'nhà ăn']], similar: [['良', 'tốt']] },
  { k: '飲', hv: 'ẨM', mean: 'uống', on: 'イン', kun: 'の（む）', words: [['飲む', 'のむ', 'uống'], ['飲み物', 'のみもの', 'đồ uống']], similar: [['飯', 'cơm']] },
  { k: '見', hv: 'KIẾN', mean: 'nhìn, xem', on: 'ケン', kun: 'み（る）', words: [['見る', 'みる', 'nhìn, xem'], ['見せる', 'みせる', 'cho xem'], ['花見', 'はなみ', 'ngắm hoa']], similar: [['貝', 'vỏ sò'], ['目', 'mắt']] },
  { k: '聞', hv: 'VĂN', mean: 'nghe, hỏi', on: 'ブン', kun: 'き（く）', words: [['聞く', 'きく', 'nghe, hỏi'], ['新聞', 'しんぶん', 'báo giấy']], similar: [['間', 'khoảng giữa'], ['門', 'cổng']] },
  { k: '書', hv: 'THƯ', mean: 'viết', on: 'ショ', kun: 'か（く）', words: [['書く', 'かく', 'viết'], ['辞書', 'じしょ', 'từ điển'], ['図書館', 'としょかん', 'thư viện']], similar: [['昼', 'buổi trưa']] },
  { k: '読', hv: 'ĐỘC', mean: 'đọc', on: 'ドク', kun: 'よ（む）', words: [['読む', 'よむ', 'đọc'], ['読書', 'どくしょ', 'việc đọc sách']], similar: [['続', 'tiếp tục']] },
  { k: '話', hv: 'THOẠI', mean: 'nói chuyện', on: 'ワ', kun: 'はな（す）・はなし', words: [['話す', 'はなす', 'nói chuyện'], ['電話', 'でんわ', 'điện thoại'], ['話', 'はなし', 'câu chuyện']], similar: [['語', 'ngôn ngữ'], ['活', 'hoạt động']] },
  { k: '買', hv: 'MÃI', mean: 'mua', on: 'バイ', kun: 'か（う）', words: [['買う', 'かう', 'mua'], ['買い物', 'かいもの', 'mua sắm']], similar: [['貝', 'vỏ sò']] },
  { k: '休', hv: 'HƯU', mean: 'nghỉ', on: 'キュウ', kun: 'やす（む）', words: [['休む', 'やすむ', 'nghỉ'], ['休み', 'やすみ', 'ngày nghỉ'], ['夏休み', 'なつやすみ', 'nghỉ hè']], similar: [['体', 'cơ thể'], ['木', 'cây']] },
  { k: '会', hv: 'HỘI', mean: 'gặp', on: 'カイ', kun: 'あ（う）', words: [['会う', 'あう', 'gặp'], ['会社', 'かいしゃ', 'công ty'], ['会議', 'かいぎ', 'cuộc họp']], similar: [['今', 'bây giờ']] },
  { k: '社', hv: 'XÃ', mean: 'công ty, xã hội', on: 'シャ', kun: 'やしろ', words: [['会社', 'かいしゃ', 'công ty'], ['会社員', 'かいしゃいん', 'nhân viên công ty'], ['社長', 'しゃちょう', 'giám đốc']] },
  { k: '山', hv: 'SƠN', mean: 'núi', on: 'サン', kun: 'やま', words: [['山', 'やま', 'núi'], ['富士山', 'ふじさん', 'núi Phú Sĩ'], ['火山', 'かざん', 'núi lửa', BA]], similar: [['出', 'ra']] },
  { k: '川', hv: 'XUYÊN', mean: 'sông', on: 'セン', kun: 'かわ', words: [['川', 'かわ', 'sông'], ['小川', 'おがわ', 'suối nhỏ', BA]] },
  { k: '天', hv: 'THIÊN', mean: 'trời', on: 'テン', kun: 'あめ・あま', words: [['天気', 'てんき', 'thời tiết'], ['天ぷら', 'てんぷら', 'món tempura']], similar: [['夫', 'chồng'], ['大', 'to']] },
  { k: '気', hv: 'KHÍ', mean: 'khí, tinh thần', on: 'キ・ケ', kun: '', words: [['天気', 'てんき', 'thời tiết'], ['元気', 'げんき', 'khoẻ'], ['電気', 'でんき', 'điện, đèn']], similar: [['汽', 'hơi nước']] },
  { k: '雨', hv: 'VŨ', mean: 'mưa', on: 'ウ', kun: 'あめ・あま', words: [['雨', 'あめ', 'mưa'], ['大雨', 'おおあめ', 'mưa to'], ['梅雨', 'つゆ', 'mùa mưa', DB]], similar: [['両', 'cả hai']] },
  { k: '電', hv: 'ĐIỆN', mean: 'điện', on: 'デン', kun: '', words: [['電気', 'でんき', 'điện, đèn'], ['電車', 'でんしゃ', 'tàu điện'], ['電話', 'でんわ', 'điện thoại']], similar: [['雷', 'sấm']] },
  { k: '車', hv: 'XA', mean: 'xe', on: 'シャ', kun: 'くるま', words: [['車', 'くるま', 'ô tô'], ['電車', 'でんしゃ', 'tàu điện'], ['自転車', 'じてんしゃ', 'xe đạp']], similar: [['東', 'phía đông']] },
  { k: '駅', hv: 'DỊCH', mean: 'nhà ga', on: 'エキ', kun: '', words: [['駅', 'えき', 'nhà ga'], ['駅員', 'えきいん', 'nhân viên nhà ga'], ['東京駅', 'とうきょうえき', 'ga Tokyo']], similar: [['馬', 'con ngựa']] },
  { k: '名', hv: 'DANH', mean: 'tên', on: 'メイ・ミョウ', kun: 'な', words: [['名前', 'なまえ', 'tên'], ['有名', 'ゆうめい', 'nổi tiếng'], ['名刺', 'めいし', 'danh thiếp']], similar: [['各', 'mỗi']] },
  { k: '前', hv: 'TIỀN', mean: 'phía trước, trước', on: 'ゼン', kun: 'まえ', words: [['前', 'まえ', 'phía trước'], ['名前', 'なまえ', 'tên'], ['午前', 'ごぜん', 'buổi sáng (AM)']] },
  { k: '午', hv: 'NGỌ', mean: 'buổi trưa', on: 'ゴ', kun: '', words: [['午前', 'ごぜん', 'buổi sáng (AM)'], ['午後', 'ごご', 'buổi chiều (PM)'], ['正午', 'しょうご', 'đúng trưa']], similar: [['牛', 'con bò'], ['年', 'năm']] },
  { k: '後', hv: 'HẬU', mean: 'sau', on: 'ゴ・コウ', kun: 'あと・うし（ろ）・のち', words: [['午後', 'ごご', 'buổi chiều (PM)'], ['後ろ', 'うしろ', 'phía sau'], ['後で', 'あとで', 'lát nữa']] },
  { k: '上', hv: 'THƯỢNG', mean: 'trên', on: 'ジョウ', kun: 'うえ・あ（がる）・のぼ（る）', words: [['上', 'うえ', 'phía trên'], ['上がる', 'あがる', 'đi lên'], ['上手', 'じょうず', 'giỏi', DB]], similar: [['止', 'dừng'], ['土', 'đất']] },
  { k: '下', hv: 'HẠ', mean: 'dưới', on: 'カ・ゲ', kun: 'した・さ（がる）・くだ（さい）', words: [['下', 'した', 'phía dưới'], ['地下鉄', 'ちかてつ', 'tàu điện ngầm'], ['下手', 'へた', 'kém', DB]], similar: [['不', 'không']] },
  { k: '左', hv: 'TẢ', mean: 'trái', on: 'サ', kun: 'ひだり', words: [['左', 'ひだり', 'bên trái'], ['左手', 'ひだりて', 'tay trái']], similar: [['右', 'phải'], ['友', 'bạn']] },
  { k: '右', hv: 'HỮU', mean: 'phải', on: 'ウ・ユウ', kun: 'みぎ', words: [['右', 'みぎ', 'bên phải'], ['右手', 'みぎて', 'tay phải'], ['左右', 'さゆう', 'trái phải']], similar: [['左', 'trái'], ['石', 'đá']] },
  { k: '東', hv: 'ĐÔNG', mean: 'phía đông', on: 'トウ', kun: 'ひがし', words: [['東', 'ひがし', 'phía đông'], ['東京', 'とうきょう', 'Tokyo']], similar: [['車', 'xe'], ['束', 'bó']] },
  { k: '西', hv: 'TÂY', mean: 'phía tây', on: 'セイ・サイ', kun: 'にし', words: [['西', 'にし', 'phía tây'], ['関西', 'かんさい', 'vùng Kansai'], ['西洋', 'せいよう', 'phương Tây']], similar: [['四', 'bốn']] },
  { k: '南', hv: 'NAM', mean: 'phía nam', on: 'ナン', kun: 'みなみ', words: [['南', 'みなみ', 'phía nam'], ['東南アジア', 'とうなんアジア', 'Đông Nam Á']] },
  { k: '北', hv: 'BẮC', mean: 'phía bắc', on: 'ホク', kun: 'きた', words: [['北', 'きた', 'phía bắc'], ['東北', 'とうほく', 'vùng Tohoku'], ['北海道', 'ほっかいどう', 'Hokkaido', BA]], similar: [['比', 'so sánh']] },
  { k: '男', hv: 'NAM', mean: 'đàn ông', on: 'ダン・ナン', kun: 'おとこ', words: [['男の人', 'おとこのひと', 'người đàn ông'], ['男の子', 'おとこのこ', 'bé trai'], ['男性', 'だんせい', 'nam giới']], similar: [['田', 'ruộng']] },
  { k: '女', hv: 'NỮ', mean: 'phụ nữ', on: 'ジョ・ニョ', kun: 'おんな', words: [['女の人', 'おんなのひと', 'người phụ nữ'], ['女の子', 'おんなのこ', 'bé gái'], ['女性', 'じょせい', 'nữ giới']], similar: [['安', 'rẻ, an toàn']] },
  { k: '子', hv: 'TỬ', mean: 'con, trẻ em', on: 'シ・ス', kun: 'こ', words: [['子ども', 'こども', 'trẻ em'], ['女の子', 'おんなのこ', 'bé gái'], ['椅子', 'いす', 'cái ghế']], similar: [['字', 'chữ']] },
  { k: '父', hv: 'PHỤ', mean: 'cha', on: 'フ', kun: 'ちち', words: [['父', 'ちち', 'bố (của mình)'], ['お父さん', 'おとうさん', 'bố (người khác / gọi bố)', DB], ['祖父', 'そふ', 'ông']], similar: [['交', 'giao'], ['文', 'văn']] },
  { k: '母', hv: 'MẪU', mean: 'mẹ', on: 'ボ', kun: 'はは', words: [['母', 'はは', 'mẹ (của mình)'], ['お母さん', 'おかあさん', 'mẹ (người khác / gọi mẹ)', DB], ['祖母', 'そぼ', 'bà']], similar: [['毎', 'mỗi']] },
  { k: '友', hv: 'HỮU', mean: 'bạn', on: 'ユウ', kun: 'とも', words: [['友達', 'ともだち', 'bạn bè'], ['友人', 'ゆうじん', 'bạn (trang trọng)']], similar: [['左', 'trái'], ['反', 'phản']] },
  { k: '白', hv: 'BẠCH', mean: 'trắng', on: 'ハク', kun: 'しろ・しろ（い）', words: [['白い', 'しろい', 'màu trắng'], ['面白い', 'おもしろい', 'thú vị']], similar: [['百', 'trăm'], ['日', 'ngày'], ['自', 'tự mình']] },
  { k: '高', hv: 'CAO', mean: 'cao, đắt', on: 'コウ', kun: 'たか（い）', words: [['高い', 'たかい', 'cao, đắt'], ['高校', 'こうこう', 'trường cấp 3']], similar: [['京', 'kinh đô']] },
  { k: '安', hv: 'AN', mean: 'rẻ, yên ổn', on: 'アン', kun: 'やす（い）', words: [['安い', 'やすい', 'rẻ'], ['安心', 'あんしん', 'yên tâm']], similar: [['女', 'phụ nữ']] },
  { k: '新', hv: 'TÂN', mean: 'mới', on: 'シン', kun: 'あたら（しい）', words: [['新しい', 'あたらしい', 'mới'], ['新聞', 'しんぶん', 'báo giấy'], ['新幹線', 'しんかんせん', 'tàu cao tốc Shinkansen']], similar: [['親', 'cha mẹ, thân']] },
  { k: '古', hv: 'CỔ', mean: 'cũ', on: 'コ', kun: 'ふる（い）', words: [['古い', 'ふるい', 'cũ'], ['中古', 'ちゅうこ', 'đồ cũ, hàng secondhand']], similar: [['右', 'phải']] },
  { k: '長', hv: 'TRƯỜNG', mean: 'dài, người đứng đầu', on: 'チョウ', kun: 'なが（い）', words: [['長い', 'ながい', 'dài'], ['社長', 'しゃちょう', 'giám đốc'], ['校長', 'こうちょう', 'hiệu trưởng']] },
  { k: '毎', hv: 'MỖI', mean: 'mỗi', on: 'マイ', kun: '', words: [['毎日', 'まいにち', 'mỗi ngày'], ['毎朝', 'まいあさ', 'mỗi sáng'], ['毎週', 'まいしゅう', 'mỗi tuần']], similar: [['母', 'mẹ'], ['海', 'biển']] },
  { k: '週', hv: 'CHU', mean: 'tuần', on: 'シュウ', kun: '', words: [['今週', 'こんしゅう', 'tuần này'], ['来週', 'らいしゅう', 'tuần sau'], ['週末', 'しゅうまつ', 'cuối tuần']] },
  { k: '間', hv: 'GIAN', mean: 'khoảng, giữa', on: 'カン・ケン', kun: 'あいだ・ま', words: [['時間', 'じかん', 'thời gian'], ['間', 'あいだ', 'ở giữa'], ['人間', 'にんげん', 'con người']], similar: [['聞', 'nghe'], ['問', 'hỏi'], ['門', 'cổng']] },
  { k: '出', hv: 'XUẤT', mean: 'ra', on: 'シュツ', kun: 'で（る）・だ（す）', words: [['出る', 'でる', 'đi ra'], ['出口', 'でぐち', 'lối ra', BA], ['出す', 'だす', 'lấy ra, nộp']], similar: [['山', 'núi']] },
  { k: '入', hv: 'NHẬP', mean: 'vào', on: 'ニュウ', kun: 'はい（る）・い（れる）', words: [['入る', 'はいる', 'đi vào'], ['入口', 'いりぐち', 'lối vào', BA], ['入れる', 'いれる', 'cho vào']], similar: [['人', 'người'], ['八', 'tám']] },
  { k: '口', hv: 'KHẨU', mean: 'miệng, cửa', on: 'コウ', kun: 'くち', words: [['口', 'くち', 'miệng'], ['入口', 'いりぐち', 'lối vào', BA], ['人口', 'じんこう', 'dân số']], similar: [['日', 'ngày'], ['回', 'lần']] },
  { k: '目', hv: 'MỤC', mean: 'mắt', on: 'モク', kun: 'め', words: [['目', 'め', 'mắt'], ['一つ目', 'ひとつめ', 'cái thứ nhất'], ['目的', 'もくてき', 'mục đích']], similar: [['日', 'ngày'], ['月', 'tháng'], ['自', 'tự mình']] },
  { k: '耳', hv: 'NHĨ', mean: 'tai', on: 'ジ', kun: 'みみ', words: [['耳', 'みみ', 'tai']], similar: [['取', 'lấy'], ['目', 'mắt']] },
  { k: '手', hv: 'THỦ', mean: 'tay', on: 'シュ', kun: 'て', words: [['手', 'て', 'tay'], ['手紙', 'てがみ', 'lá thư', BA], ['上手', 'じょうず', 'giỏi', DB]], similar: [['毛', 'lông']] },
  { k: '足', hv: 'TÚC', mean: 'chân, đủ', on: 'ソク', kun: 'あし・た（りる）', words: [['足', 'あし', 'chân'], ['足りる', 'たりる', 'đủ']], similar: [['走', 'chạy']] },
  { k: '語', hv: 'NGỮ', mean: 'ngôn ngữ, từ', on: 'ゴ', kun: 'かた（る）', words: [['日本語', 'にほんご', 'tiếng Nhật'], ['英語', 'えいご', 'tiếng Anh'], ['単語', 'たんご', 'từ vựng']], similar: [['話', 'nói chuyện']] },
  { k: '店', hv: 'ĐIẾM', mean: 'cửa hàng', on: 'テン', kun: 'みせ', words: [['店', 'みせ', 'cửa hàng'], ['喫茶店', 'きっさてん', 'quán cà phê'], ['店員', 'てんいん', 'nhân viên bán hàng']], similar: [['広', 'rộng']] },
  { k: '道', hv: 'ĐẠO', mean: 'con đường', on: 'ドウ', kun: 'みち', words: [['道', 'みち', 'con đường'], ['柔道', 'じゅうどう', 'judo'], ['北海道', 'ほっかいどう', 'Hokkaido', BA]], similar: [['首', 'cổ']] },
]

const DAY = 86_400_000

/** 'YYYY-MM-DD' theo giờ Việt Nam */
export function todayVN(): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date())
}

export function isDateStr(s?: string | null): s is string {
  return !!s && /^\d{4}-\d{2}-\d{2}$/.test(s) && !Number.isNaN(Date.parse(s))
}

/** Số ngày từ a tới b (b − a), cả hai dạng 'YYYY-MM-DD' */
export function daysBetween(a: string, b: string): number {
  return Math.round((Date.parse(b) - Date.parse(a)) / DAY)
}

export function addDays(date: string, n: number): string {
  return new Date(Date.parse(date) + n * DAY).toISOString().slice(0, 10)
}

/** Chữ được mở vào ngày `date`, hoặc null nếu trước START_DATE / đã hết danh sách */
export function kanjiOfDay(date: string): { kanji: DailyKanji; index: number } | null {
  const index = daysBetween(START_DATE, date)
  if (index < 0 || index >= KANJI.length) return null
  return { kanji: KANJI[index], index }
}

/** Ngày chữ thứ `index` được mở */
export function introDate(index: number): string {
  return addDays(START_DATE, index)
}

/** Số chữ đã mở tính tới hết ngày `today` */
export function learnedCount(today: string): number {
  return Math.max(0, Math.min(daysBetween(START_DATE, today) + 1, KANJI.length))
}

export function findKanji(k: string): { kanji: DailyKanji; index: number } | null {
  const index = KANJI.findIndex((x) => x.k === k)
  return index < 0 ? null : { kanji: KANJI[index], index }
}

/** Tên file KanjiVG: mã Unicode hex 5 chữ số, vd 日 → 065e5 */
export function kvgCode(k: string): string {
  return (k.codePointAt(0) ?? 0).toString(16).padStart(5, '0')
}

/** '2026-11-27' → '27/11' */
export function formatDate(date: string): string {
  const [, m, d] = date.split('-')
  return `${d}/${m}`
}
