// Danh sách kanji cho /kanji/daily, mỗi ngày 1 chữ. Fix cứng (không lấy từ bảng
// jlpt_kanji) để tự quyết lộ trình — thứ tự trong mảng = thứ tự học.
// Thêm chữ mới thì copy file nét public/kanjivg/<kvgCode>.svg từ KanjiVG.
// ex: [từ, cách đọc, nghĩa]

export type DailyKanji = {
  k: string;      // chữ
  hv: string;     // Hán Việt
  on: string;     // âm On
  kun: string;    // âm Kun ('' nếu không dùng)
  mean: string;   // nghĩa
  ex: [string, string, string][];
};

export const START_DATE = '2026-11-27'; // ngày đầu tiên (giờ VN) → KANJI[0]

export const KANJI: DailyKanji[] = [
  { k: '日', hv: 'NHẬT', on: 'ニチ・ジツ', kun: 'ひ・か', mean: 'mặt trời, ngày', ex: [['日本', 'にほん', 'Nhật Bản'], ['毎日', 'まいにち', 'mỗi ngày'], ['日曜日', 'にちようび', 'chủ nhật']] },
  { k: '本', hv: 'BẢN', on: 'ホン', kun: 'もと', mean: 'sách, gốc', ex: [['本', 'ほん', 'sách'], ['日本', 'にほん', 'Nhật Bản'], ['本屋', 'ほんや', 'hiệu sách']] },
  { k: '人', hv: 'NHÂN', on: 'ジン・ニン', kun: 'ひと', mean: 'người', ex: [['日本人', 'にほんじん', 'người Nhật'], ['三人', 'さんにん', 'ba người'], ['あの人', 'あのひと', 'người kia']] },
  { k: '一', hv: 'NHẤT', on: 'イチ・イツ', kun: 'ひと（つ）', mean: 'một', ex: [['一つ', 'ひとつ', 'một cái'], ['一人', 'ひとり', 'một người'], ['一月', 'いちがつ', 'tháng một']] },
  { k: '二', hv: 'NHỊ', on: 'ニ', kun: 'ふた（つ）', mean: 'hai', ex: [['二つ', 'ふたつ', 'hai cái'], ['二人', 'ふたり', 'hai người'], ['二月', 'にがつ', 'tháng hai']] },
  { k: '三', hv: 'TAM', on: 'サン', kun: 'みっ（つ）', mean: 'ba', ex: [['三つ', 'みっつ', 'ba cái'], ['三月', 'さんがつ', 'tháng ba']] },
  { k: '四', hv: 'TỨ', on: 'シ', kun: 'よ・よん・よっ（つ）', mean: 'bốn', ex: [['四つ', 'よっつ', 'bốn cái'], ['四月', 'しがつ', 'tháng tư'], ['四時', 'よじ', '4 giờ']] },
  { k: '五', hv: 'NGŨ', on: 'ゴ', kun: 'いつ（つ）', mean: 'năm', ex: [['五つ', 'いつつ', 'năm cái'], ['五月', 'ごがつ', 'tháng năm']] },
  { k: '六', hv: 'LỤC', on: 'ロク', kun: 'むっ（つ）', mean: 'sáu', ex: [['六つ', 'むっつ', 'sáu cái'], ['六月', 'ろくがつ', 'tháng sáu']] },
  { k: '七', hv: 'THẤT', on: 'シチ', kun: 'なな（つ）', mean: 'bảy', ex: [['七つ', 'ななつ', 'bảy cái'], ['七月', 'しちがつ', 'tháng bảy']] },
  { k: '八', hv: 'BÁT', on: 'ハチ', kun: 'やっ（つ）', mean: 'tám', ex: [['八つ', 'やっつ', 'tám cái'], ['八月', 'はちがつ', 'tháng tám']] },
  { k: '九', hv: 'CỬU', on: 'キュウ・ク', kun: 'ここの（つ）', mean: 'chín', ex: [['九つ', 'ここのつ', 'chín cái'], ['九月', 'くがつ', 'tháng chín']] },
  { k: '十', hv: 'THẬP', on: 'ジュウ', kun: 'とお', mean: 'mười', ex: [['十', 'とお', 'mười cái'], ['十月', 'じゅうがつ', 'tháng mười']] },
  { k: '百', hv: 'BÁCH', on: 'ヒャク', kun: '', mean: 'trăm', ex: [['百円', 'ひゃくえん', '100 yên'], ['三百', 'さんびゃく', '300']] },
  { k: '千', hv: 'THIÊN', on: 'セン', kun: 'ち', mean: 'nghìn', ex: [['千円', 'せんえん', '1000 yên'], ['三千', 'さんぜん', '3000']] },
  { k: '万', hv: 'VẠN', on: 'マン', kun: '', mean: 'vạn (mười nghìn)', ex: [['一万円', 'いちまんえん', '10.000 yên']] },
  { k: '円', hv: 'VIÊN', on: 'エン', kun: 'まる（い）', mean: 'yên (tiền), tròn', ex: [['百円', 'ひゃくえん', '100 yên'], ['円い', 'まるい', 'tròn']] },
  { k: '月', hv: 'NGUYỆT', on: 'ゲツ・ガツ', kun: 'つき', mean: 'mặt trăng, tháng', ex: [['月曜日', 'げつようび', 'thứ hai'], ['一月', 'いちがつ', 'tháng một'], ['毎月', 'まいつき', 'mỗi tháng']] },
  { k: '火', hv: 'HỎA', on: 'カ', kun: 'ひ', mean: 'lửa', ex: [['火曜日', 'かようび', 'thứ ba'], ['火', 'ひ', 'lửa']] },
  { k: '水', hv: 'THỦY', on: 'スイ', kun: 'みず', mean: 'nước', ex: [['水曜日', 'すいようび', 'thứ tư'], ['水', 'みず', 'nước']] },
  { k: '木', hv: 'MỘC', on: 'モク・ボク', kun: 'き', mean: 'cây', ex: [['木曜日', 'もくようび', 'thứ năm'], ['木', 'き', 'cây']] },
  { k: '金', hv: 'KIM', on: 'キン・コン', kun: 'かね', mean: 'vàng, tiền', ex: [['金曜日', 'きんようび', 'thứ sáu'], ['お金', 'おかね', 'tiền']] },
  { k: '土', hv: 'THỔ', on: 'ド・ト', kun: 'つち', mean: 'đất', ex: [['土曜日', 'どようび', 'thứ bảy'], ['土', 'つち', 'đất']] },
  { k: '年', hv: 'NIÊN', on: 'ネン', kun: 'とし', mean: 'năm', ex: [['今年', 'ことし', 'năm nay'], ['来年', 'らいねん', 'năm sau'], ['毎年', 'まいとし', 'mỗi năm']] },
  { k: '時', hv: 'THỜI', on: 'ジ', kun: 'とき', mean: 'giờ, thời gian', ex: [['時間', 'じかん', 'thời gian'], ['何時', 'なんじ', 'mấy giờ'], ['時計', 'とけい', 'đồng hồ']] },
  { k: '分', hv: 'PHÂN', on: 'ブン・フン', kun: 'わ（かる）', mean: 'phút, chia, hiểu', ex: [['五分', 'ごふん', '5 phút'], ['十分', 'じゅっぷん', '10 phút'], ['分かる', 'わかる', 'hiểu']] },
  { k: '半', hv: 'BÁN', on: 'ハン', kun: 'なか（ば）', mean: 'một nửa', ex: [['半分', 'はんぶん', 'một nửa'], ['三時半', 'さんじはん', '3 giờ rưỡi']] },
  { k: '今', hv: 'KIM', on: 'コン', kun: 'いま', mean: 'bây giờ', ex: [['今', 'いま', 'bây giờ'], ['今日', 'きょう', 'hôm nay'], ['今晩', 'こんばん', 'tối nay']] },
  { k: '何', hv: 'HÀ', on: 'カ', kun: 'なに・なん', mean: 'cái gì', ex: [['何', 'なん', 'cái gì'], ['何時', 'なんじ', 'mấy giờ'], ['何人', 'なんにん', 'mấy người']] },
  { k: '先', hv: 'TIÊN', on: 'セン', kun: 'さき', mean: 'trước', ex: [['先生', 'せんせい', 'giáo viên'], ['先月', 'せんげつ', 'tháng trước'], ['先週', 'せんしゅう', 'tuần trước']] },
  { k: '生', hv: 'SINH', on: 'セイ・ショウ', kun: 'い（きる）・う（まれる）', mean: 'sống, sinh ra', ex: [['学生', 'がくせい', 'học sinh'], ['先生', 'せんせい', 'giáo viên'], ['誕生日', 'たんじょうび', 'sinh nhật']] },
  { k: '学', hv: 'HỌC', on: 'ガク', kun: 'まな（ぶ）', mean: 'học', ex: [['学生', 'がくせい', 'học sinh'], ['大学', 'だいがく', 'đại học'], ['学校', 'がっこう', 'trường học']] },
  { k: '校', hv: 'HIỆU', on: 'コウ', kun: '', mean: 'trường', ex: [['学校', 'がっこう', 'trường học'], ['高校', 'こうこう', 'trường cấp 3']] },
  { k: '大', hv: 'ĐẠI', on: 'ダイ・タイ', kun: 'おお（きい）', mean: 'to, lớn', ex: [['大学', 'だいがく', 'đại học'], ['大きい', 'おおきい', 'to'], ['大切', 'たいせつ', 'quan trọng']] },
  { k: '小', hv: 'TIỂU', on: 'ショウ', kun: 'ちい（さい）・こ', mean: 'nhỏ', ex: [['小さい', 'ちいさい', 'nhỏ'], ['小学校', 'しょうがっこう', 'trường tiểu học']] },
  { k: '中', hv: 'TRUNG', on: 'チュウ', kun: 'なか', mean: 'giữa, trong', ex: [['中', 'なか', 'bên trong'], ['中国', 'ちゅうごく', 'Trung Quốc']] },
  { k: '国', hv: 'QUỐC', on: 'コク', kun: 'くに', mean: 'đất nước', ex: [['国', 'くに', 'đất nước'], ['中国', 'ちゅうごく', 'Trung Quốc'], ['外国', 'がいこく', 'nước ngoài']] },
  { k: '外', hv: 'NGOẠI', on: 'ガイ', kun: 'そと', mean: 'ngoài', ex: [['外', 'そと', 'bên ngoài'], ['外国人', 'がいこくじん', 'người nước ngoài']] },
  { k: '行', hv: 'HÀNH', on: 'コウ・ギョウ', kun: 'い（く）', mean: 'đi', ex: [['行く', 'いく', 'đi'], ['銀行', 'ぎんこう', 'ngân hàng'], ['旅行', 'りょこう', 'du lịch']] },
  { k: '来', hv: 'LAI', on: 'ライ', kun: 'く（る）・き（ます）', mean: 'đến', ex: [['来る', 'くる', 'đến'], ['来週', 'らいしゅう', 'tuần sau'], ['来年', 'らいねん', 'năm sau']] },
  { k: '食', hv: 'THỰC', on: 'ショク', kun: 'た（べる）', mean: 'ăn', ex: [['食べる', 'たべる', 'ăn'], ['食堂', 'しょくどう', 'nhà ăn'], ['食事', 'しょくじ', 'bữa ăn']] },
  { k: '飲', hv: 'ẨM', on: 'イン', kun: 'の（む）', mean: 'uống', ex: [['飲む', 'のむ', 'uống'], ['飲み物', 'のみもの', 'đồ uống']] },
  { k: '見', hv: 'KIẾN', on: 'ケン', kun: 'み（る）', mean: 'nhìn, xem', ex: [['見る', 'みる', 'xem'], ['見物', 'けんぶつ', 'tham quan']] },
  { k: '聞', hv: 'VĂN', on: 'ブン', kun: 'き（く）', mean: 'nghe, hỏi', ex: [['聞く', 'きく', 'nghe'], ['新聞', 'しんぶん', 'báo']] },
  { k: '書', hv: 'THƯ', on: 'ショ', kun: 'か（く）', mean: 'viết', ex: [['書く', 'かく', 'viết'], ['辞書', 'じしょ', 'từ điển'], ['図書館', 'としょかん', 'thư viện']] },
  { k: '読', hv: 'ĐỘC', on: 'ドク', kun: 'よ（む）', mean: 'đọc', ex: [['読む', 'よむ', 'đọc'], ['読書', 'どくしょ', 'việc đọc sách']] },
  { k: '話', hv: 'THOẠI', on: 'ワ', kun: 'はな（す）・はなし', mean: 'nói chuyện', ex: [['話す', 'はなす', 'nói'], ['電話', 'でんわ', 'điện thoại']] },
  { k: '買', hv: 'MÃI', on: 'バイ', kun: 'か（う）', mean: 'mua', ex: [['買う', 'かう', 'mua'], ['買い物', 'かいもの', 'mua sắm']] },
  { k: '休', hv: 'HƯU', on: 'キュウ', kun: 'やす（む）', mean: 'nghỉ', ex: [['休む', 'やすむ', 'nghỉ'], ['休み', 'やすみ', 'ngày nghỉ']] },
  { k: '会', hv: 'HỘI', on: 'カイ', kun: 'あ（う）', mean: 'gặp, hội', ex: [['会う', 'あう', 'gặp'], ['会社', 'かいしゃ', 'công ty'], ['会議', 'かいぎ', 'cuộc họp']] },
  { k: '社', hv: 'XÃ', on: 'シャ', kun: '', mean: 'công ty, xã hội', ex: [['会社', 'かいしゃ', 'công ty'], ['社員', 'しゃいん', 'nhân viên']] },
  { k: '山', hv: 'SƠN', on: 'サン', kun: 'やま', mean: 'núi', ex: [['山', 'やま', 'núi'], ['富士山', 'ふじさん', 'núi Phú Sĩ']] },
  { k: '川', hv: 'XUYÊN', on: 'セン', kun: 'かわ', mean: 'sông', ex: [['川', 'かわ', 'sông']] },
  { k: '天', hv: 'THIÊN', on: 'テン', kun: '', mean: 'trời', ex: [['天気', 'てんき', 'thời tiết']] },
  { k: '気', hv: 'KHÍ', on: 'キ', kun: '', mean: 'khí, tinh thần', ex: [['天気', 'てんき', 'thời tiết'], ['元気', 'げんき', 'khỏe'], ['電気', 'でんき', 'điện, đèn']] },
  { k: '雨', hv: 'VŨ', on: 'ウ', kun: 'あめ', mean: 'mưa', ex: [['雨', 'あめ', 'mưa']] },
  { k: '電', hv: 'ĐIỆN', on: 'デン', kun: '', mean: 'điện', ex: [['電話', 'でんわ', 'điện thoại'], ['電車', 'でんしゃ', 'tàu điện'], ['電気', 'でんき', 'điện, đèn']] },
  { k: '車', hv: 'XA', on: 'シャ', kun: 'くるま', mean: 'xe', ex: [['車', 'くるま', 'xe ô tô'], ['電車', 'でんしゃ', 'tàu điện'], ['自転車', 'じてんしゃ', 'xe đạp']] },
  { k: '駅', hv: 'DỊCH', on: 'エキ', kun: '', mean: 'nhà ga', ex: [['駅', 'えき', 'nhà ga']] },
  { k: '名', hv: 'DANH', on: 'メイ', kun: 'な', mean: 'tên', ex: [['名前', 'なまえ', 'tên'], ['有名', 'ゆうめい', 'nổi tiếng']] },
  { k: '前', hv: 'TIỀN', on: 'ゼン', kun: 'まえ', mean: 'trước', ex: [['前', 'まえ', 'phía trước'], ['名前', 'なまえ', 'tên'], ['午前', 'ごぜん', 'buổi sáng (AM)']] },
  { k: '午', hv: 'NGỌ', on: 'ゴ', kun: '', mean: 'trưa', ex: [['午前', 'ごぜん', 'buổi sáng (AM)'], ['午後', 'ごご', 'buổi chiều (PM)']] },
  { k: '後', hv: 'HẬU', on: 'ゴ・コウ', kun: 'あと・うし（ろ）', mean: 'sau', ex: [['午後', 'ごご', 'buổi chiều (PM)'], ['後ろ', 'うしろ', 'phía sau']] },
  { k: '上', hv: 'THƯỢNG', on: 'ジョウ', kun: 'うえ', mean: 'trên', ex: [['上', 'うえ', 'bên trên']] },
  { k: '下', hv: 'HẠ', on: 'カ・ゲ', kun: 'した', mean: 'dưới', ex: [['下', 'した', 'bên dưới'], ['地下鉄', 'ちかてつ', 'tàu điện ngầm']] },
  { k: '左', hv: 'TẢ', on: 'サ', kun: 'ひだり', mean: 'trái', ex: [['左', 'ひだり', 'bên trái']] },
  { k: '右', hv: 'HỮU', on: 'ウ・ユウ', kun: 'みぎ', mean: 'phải', ex: [['右', 'みぎ', 'bên phải']] },
  { k: '東', hv: 'ĐÔNG', on: 'トウ', kun: 'ひがし', mean: 'phía đông', ex: [['東', 'ひがし', 'phía đông'], ['東京', 'とうきょう', 'Tokyo']] },
  { k: '西', hv: 'TÂY', on: 'セイ・サイ', kun: 'にし', mean: 'phía tây', ex: [['西', 'にし', 'phía tây']] },
  { k: '南', hv: 'NAM', on: 'ナン', kun: 'みなみ', mean: 'phía nam', ex: [['南', 'みなみ', 'phía nam']] },
  { k: '北', hv: 'BẮC', on: 'ホク', kun: 'きた', mean: 'phía bắc', ex: [['北', 'きた', 'phía bắc']] },
  { k: '男', hv: 'NAM', on: 'ダン', kun: 'おとこ', mean: 'đàn ông', ex: [['男の人', 'おとこのひと', 'người đàn ông']] },
  { k: '女', hv: 'NỮ', on: 'ジョ', kun: 'おんな', mean: 'phụ nữ', ex: [['女の人', 'おんなのひと', 'người phụ nữ'], ['女性', 'じょせい', 'nữ giới']] },
  { k: '子', hv: 'TỬ', on: 'シ', kun: 'こ', mean: 'con', ex: [['子ども', 'こども', 'trẻ con']] },
  { k: '父', hv: 'PHỤ', on: 'フ', kun: 'ちち', mean: 'bố', ex: [['父', 'ちち', 'bố (mình)'], ['お父さん', 'おとうさん', 'bố (người khác)']] },
  { k: '母', hv: 'MẪU', on: 'ボ', kun: 'はは', mean: 'mẹ', ex: [['母', 'はは', 'mẹ (mình)'], ['お母さん', 'おかあさん', 'mẹ (người khác)']] },
  { k: '友', hv: 'HỮU', on: 'ユウ', kun: 'とも', mean: 'bạn', ex: [['友達', 'ともだち', 'bạn bè']] },
  { k: '白', hv: 'BẠCH', on: 'ハク', kun: 'しろ', mean: 'trắng', ex: [['白い', 'しろい', 'trắng']] },
  { k: '高', hv: 'CAO', on: 'コウ', kun: 'たか（い）', mean: 'cao, đắt', ex: [['高い', 'たかい', 'cao, đắt'], ['高校', 'こうこう', 'trường cấp 3']] },
  { k: '安', hv: 'AN', on: 'アン', kun: 'やす（い）', mean: 'rẻ, yên', ex: [['安い', 'やすい', 'rẻ']] },
  { k: '新', hv: 'TÂN', on: 'シン', kun: 'あたら（しい）', mean: 'mới', ex: [['新しい', 'あたらしい', 'mới'], ['新聞', 'しんぶん', 'báo']] },
  { k: '古', hv: 'CỔ', on: 'コ', kun: 'ふる（い）', mean: 'cũ', ex: [['古い', 'ふるい', 'cũ']] },
  { k: '長', hv: 'TRƯỜNG', on: 'チョウ', kun: 'なが（い）', mean: 'dài, trưởng', ex: [['長い', 'ながい', 'dài'], ['社長', 'しゃちょう', 'giám đốc']] },
  { k: '毎', hv: 'MỖI', on: 'マイ', kun: '', mean: 'mỗi', ex: [['毎日', 'まいにち', 'mỗi ngày'], ['毎朝', 'まいあさ', 'mỗi sáng']] },
  { k: '週', hv: 'CHU', on: 'シュウ', kun: '', mean: 'tuần', ex: [['毎週', 'まいしゅう', 'mỗi tuần'], ['来週', 'らいしゅう', 'tuần sau']] },
  { k: '間', hv: 'GIAN', on: 'カン', kun: 'あいだ', mean: 'khoảng, giữa', ex: [['時間', 'じかん', 'thời gian'], ['間', 'あいだ', 'ở giữa']] },
  { k: '出', hv: 'XUẤT', on: 'シュツ', kun: 'で（る）・だ（す）', mean: 'ra', ex: [['出る', 'でる', 'ra'], ['出す', 'だす', 'lấy ra, nộp']] },
  { k: '入', hv: 'NHẬP', on: 'ニュウ', kun: 'はい（る）・い（れる）', mean: 'vào', ex: [['入る', 'はいる', 'vào'], ['入口', 'いりぐち', 'lối vào']] },
  { k: '口', hv: 'KHẨU', on: 'コウ', kun: 'くち', mean: 'miệng', ex: [['口', 'くち', 'miệng'], ['入口', 'いりぐち', 'lối vào']] },
  { k: '目', hv: 'MỤC', on: 'モク', kun: 'め', mean: 'mắt', ex: [['目', 'め', 'mắt']] },
  { k: '耳', hv: 'NHĨ', on: 'ジ', kun: 'みみ', mean: 'tai', ex: [['耳', 'みみ', 'tai']] },
  { k: '手', hv: 'THỦ', on: 'シュ', kun: 'て', mean: 'tay', ex: [['手', 'て', 'tay'], ['切手', 'きって', 'tem']] },
  { k: '足', hv: 'TÚC', on: 'ソク', kun: 'あし', mean: 'chân', ex: [['足', 'あし', 'chân']] },
  { k: '語', hv: 'NGỮ', on: 'ゴ', kun: 'かた（る）', mean: 'ngôn ngữ', ex: [['日本語', 'にほんご', 'tiếng Nhật'], ['英語', 'えいご', 'tiếng Anh']] },
  { k: '店', hv: 'ĐIẾM', on: 'テン', kun: 'みせ', mean: 'cửa hàng', ex: [['店', 'みせ', 'cửa hàng'], ['喫茶店', 'きっさてん', 'quán cà phê']] },
  { k: '道', hv: 'ĐẠO', on: 'ドウ', kun: 'みち', mean: 'đường', ex: [['道', 'みち', 'con đường']] },
];

const DAY = 86_400_000;

/** 'YYYY-MM-DD' theo giờ Việt Nam */
export function todayVN(): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date());
}

export function isDateStr(s?: string | null): s is string {
  return !!s && /^\d{4}-\d{2}-\d{2}$/.test(s) && !Number.isNaN(Date.parse(s));
}

export function dayIndex(date: string): number {
  const diff = Math.floor((Date.parse(date) - Date.parse(START_DATE)) / DAY);
  return ((diff % KANJI.length) + KANJI.length) % KANJI.length;
}

export function getDaily(date: string): DailyKanji {
  return KANJI[dayIndex(date)];
}

/** n ngày gần nhất trước `date` (không gồm `date`) */
export function previousDays(date: string, n: number): string[] {
  const t = Date.parse(date);
  return Array.from({ length: n }, (_, i) => new Date(t - (i + 1) * DAY).toISOString().slice(0, 10));
}

/** Tên file KanjiVG: mã Unicode hex 5 chữ số, vd 日 → 065e5 */
export function kvgCode(k: string): string {
  return (k.codePointAt(0) ?? 0).toString(16).padStart(5, '0');
}
