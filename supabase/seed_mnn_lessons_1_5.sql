-- Seed: Minna no Nihongo I — Bài 1-5
-- site_id: 1219bda2-aa1e-4288-ab7e-caff011cdf5c

DO $$
DECLARE
  sid  uuid := '1219bda2-aa1e-4288-ab7e-caff011cdf5c';
  l1   uuid;
  l2   uuid;
  l3   uuid;
  l4   uuid;
  l5   uuid;
BEGIN

-- ════════════════════════════════════════
-- LESSONS
-- ════════════════════════════════════════
INSERT INTO mnn_lessons (site_id, lesson_number, title_vi, situation_vi, order_index) VALUES
  (sid, 1, 'はじめまして', 'Tự giới thiệu bản thân, gặp gỡ lần đầu', 1),
  (sid, 2, 'これは なんですか', 'Hỏi về đồ vật xung quanh', 2),
  (sid, 3, 'あそこです', 'Hỏi địa điểm trong cửa hàng/văn phòng', 3),
  (sid, 4, 'なんじですか', 'Hỏi giờ giấc, thời gian làm việc', 4),
  (sid, 5, '行きます・来ます・帰ります', 'Di chuyển bằng phương tiện, hẹn gặp', 5);

SELECT id INTO l1 FROM mnn_lessons WHERE site_id = sid AND lesson_number = 1;
SELECT id INTO l2 FROM mnn_lessons WHERE site_id = sid AND lesson_number = 2;
SELECT id INTO l3 FROM mnn_lessons WHERE site_id = sid AND lesson_number = 3;
SELECT id INTO l4 FROM mnn_lessons WHERE site_id = sid AND lesson_number = 4;
SELECT id INTO l5 FROM mnn_lessons WHERE site_id = sid AND lesson_number = 5;


-- ════════════════════════════════════════
-- BÀI 1 VOCABULARY
-- ════════════════════════════════════════
INSERT INTO mnn_vocabulary (site_id, lesson_id, word, reading, romanization, meaning_vi, part_of_speech, order_index) VALUES
  (sid, l1, 'わたし',     'わたし',     'watashi',        'Tôi',                            '代名詞', 1),
  (sid, l1, 'あなた',     'あなた',     'anata',          'Bạn / Anh / Chị',                '代名詞', 2),
  (sid, l1, 'あのかた',   'あのかた',   'ano kata',       'Người đó (kính trọng)',           '代名詞', 3),
  (sid, l1, 'みなさん',   'みなさん',   'mina san',       'Mọi người',                      '名詞',   4),
  (sid, l1, 'せんせい',   'せんせい',   'sensei',         'Giáo viên / Thầy cô',            '名詞',   5),
  (sid, l1, 'がくせい',   'がくせい',   'gakusei',        'Học sinh / Sinh viên',           '名詞',   6),
  (sid, l1, 'かいしゃいん','かいしゃいん','kaishain',      'Nhân viên công ty',              '名詞',   7),
  (sid, l1, 'いしゃ',     'いしゃ',     'isha',           'Bác sĩ',                         '名詞',   8),
  (sid, l1, 'けんきゅうしゃ','けんきゅうしゃ','kenkyuusha','Nhà nghiên cứu',              '名詞',   9),
  (sid, l1, 'エンジニア', 'エンジニア', 'enjinia',        'Kỹ sư',                          '名詞',   10),
  (sid, l1, 'にほん',     'にほん',     'nihon',          'Nhật Bản',                       '名詞',   11),
  (sid, l1, 'にほんご',   'にほんご',   'nihongo',        'Tiếng Nhật',                     '名詞',   12),
  (sid, l1, 'はじめまして','はじめまして','hajimemashite', 'Xin chào (gặp lần đầu)',         '挨拶',   13),
  (sid, l1, 'どうぞよろしく','どうぞよろしく','douzo yoroshiku','Rất vui được làm quen',   '挨拶',   14),
  (sid, l1, 'こちらこそ', 'こちらこそ', 'kochira koso',   'Tôi cũng vậy',                   '挨拶',   15),
  (sid, l1, 'さん',       'さん',       'san',            'Ông / Bà / Anh / Chị (hậu tố)', '接尾辞', 16),
  (sid, l1, 'ちがいます', 'ちがいます', 'chigaimasu',     'Không phải vậy',                 '動詞',   17);


-- ════════════════════════════════════════
-- BÀI 1 GRAMMAR
-- ════════════════════════════════════════
INSERT INTO mnn_grammar (site_id, lesson_id, pattern, explanation_vi, example_ja, example_vi, order_index) VALUES
  (sid, l1,
   '〜は〜です',
   'Câu khẳng định cơ bản: "A là B". Trợ từ は (wa) đánh dấu chủ thể.',
   'わたしはがくせいです。',
   'Tôi là học sinh.',
   1),
  (sid, l1,
   '〜は〜じゃありません',
   'Câu phủ định: "A không phải là B". Dùng trong văn nói (じゃ = では).',
   'わたしはせんせいじゃありません。',
   'Tôi không phải là giáo viên.',
   2),
  (sid, l1,
   '〜は〜ですか',
   'Câu hỏi Yes/No: "A có phải là B không?" Thêm か vào cuối câu khẳng định.',
   'あなたはがくせいですか。',
   'Bạn có phải là học sinh không?',
   3),
  (sid, l1,
   '〜も〜です',
   'Trợ từ も (mo) thay thế は, nghĩa là "cũng": "A cũng là B".',
   'わたしもがくせいです。',
   'Tôi cũng là học sinh.',
   4);


-- ════════════════════════════════════════
-- BÀI 1 EXERCISES
-- ════════════════════════════════════════
INSERT INTO mnn_exercises (site_id, lesson_id, type, question, options, answer, explanation_vi, order_index) VALUES
  (sid, l1, 'multiple_choice',
   'わたし___がくせいです。',
   '["は", "が", "を", "に"]',
   'は',
   'Trợ từ は (wa) dùng để đánh dấu chủ thể trong câu khẳng định.',
   1),
  (sid, l1, 'multiple_choice',
   '「がくせい」の意味は？',
   '["Học sinh / Sinh viên", "Giáo viên", "Bác sĩ", "Kỹ sư"]',
   'Học sinh / Sinh viên',
   'がくせい (学生) = học sinh hoặc sinh viên.',
   2),
  (sid, l1, 'fill_blank',
   'わたしはせんせい___ありません。(phủ định)',
   NULL,
   'じゃ',
   'じゃありません = không phải là... (dạng phủ định).',
   3),
  (sid, l1, 'multiple_choice',
   'あなたはにほんじん___か。',
   '["ですか", "じゃないですか", "もです", "はです"]',
   'ですか',
   'Thêm ですか vào cuối câu để tạo câu hỏi Yes/No.',
   4),
  (sid, l1, 'fill_blank',
   'はじめまして、どうぞ___。',
   NULL,
   'よろしく',
   'どうぞよろしく là câu chào hỏi khi gặp lần đầu.',
   5),
  (sid, l1, 'multiple_choice',
   'マリアさん___かいしゃいんです。(cũng là)',
   '["も", "は", "が", "を"]',
   'も',
   'Trợ từ も (mo) = cũng, thay thế は.',
   6),
  (sid, l1, 'multiple_choice',
   '「いしゃ」の意味は？',
   '["Bác sĩ", "Kỹ sư", "Nhà nghiên cứu", "Nhân viên công ty"]',
   'Bác sĩ',
   'いしゃ (医者) = bác sĩ.',
   7),
  (sid, l1, 'fill_blank',
   'あなたはエンジニア___。(khẳng định)',
   NULL,
   'です',
   'Câu khẳng định kết thúc bằng です.',
   8);


-- ════════════════════════════════════════
-- BÀI 2 VOCABULARY
-- ════════════════════════════════════════
INSERT INTO mnn_vocabulary (site_id, lesson_id, word, reading, romanization, meaning_vi, part_of_speech, order_index) VALUES
  (sid, l2, 'これ',     'これ',     'kore',       'Cái này (gần người nói)',          '指示語', 1),
  (sid, l2, 'それ',     'それ',     'sore',       'Cái đó (gần người nghe)',          '指示語', 2),
  (sid, l2, 'あれ',     'あれ',     'are',        'Cái kia (xa cả hai)',              '指示語', 3),
  (sid, l2, 'どれ',     'どれ',     'dore',       'Cái nào',                          '指示語', 4),
  (sid, l2, 'なん/なに','なん/なに', 'nan/nani',   'Cái gì',                           '疑問詞', 5),
  (sid, l2, 'ほん',     'ほん',     'hon',        'Sách',                             '名詞',   6),
  (sid, l2, 'ざっし',   'ざっし',   'zasshi',     'Tạp chí',                          '名詞',   7),
  (sid, l2, 'しんぶん', 'しんぶん', 'shinbun',    'Báo (tờ báo)',                     '名詞',   8),
  (sid, l2, 'ノート',   'ノート',   'nooto',      'Vở / Sổ tay',                      '名詞',   9),
  (sid, l2, 'えんぴつ', 'えんぴつ', 'enpitsu',    'Bút chì',                          '名詞',   10),
  (sid, l2, 'ボールペン','ボールペン','boorupen',  'Bút bi',                           '名詞',   11),
  (sid, l2, 'かさ',     'かさ',     'kasa',       'Ô / Dù',                           '名詞',   12),
  (sid, l2, 'かばん',   'かばん',   'kaban',      'Túi xách / Cặp',                   '名詞',   13),
  (sid, l2, 'とけい',   'とけい',   'tokei',      'Đồng hồ',                          '名詞',   14),
  (sid, l2, 'の',       'の',       'no',         'Của (trợ từ sở hữu)',              '助詞',   15),
  (sid, l2, 'だれ',     'だれ',     'dare',       'Ai',                               '疑問詞', 16),
  (sid, l2, 'そう',     'そう',     'soo',        'Đúng vậy',                         '副詞',   17),
  (sid, l2, 'ちがいます','ちがいます','chigaimasu', 'Không phải',                      '動詞',   18);


-- ════════════════════════════════════════
-- BÀI 2 GRAMMAR
-- ════════════════════════════════════════
INSERT INTO mnn_grammar (site_id, lesson_id, pattern, explanation_vi, example_ja, example_vi, order_index) VALUES
  (sid, l2,
   'これ/それ/あれは〜です',
   'Chỉ thị vật: これ (cái này), それ (cái đó), あれ (cái kia). Dùng khi vật ở vị trí khác nhau so với người nói và người nghe.',
   'これはほんです。',
   'Đây là quyển sách.',
   1),
  (sid, l2,
   '〜はなんですか',
   'Hỏi tên/loại của đồ vật: "... là cái gì?" Dùng なん trước です, なに trước trợ từ.',
   'それはなんですか。',
   'Đó là cái gì?',
   2),
  (sid, l2,
   '〜の〜',
   'Trợ từ の kết nối hai danh từ: N1のN2 = "N2 của N1". Dùng để chỉ sở hữu hoặc phân loại.',
   'これはわたしのほんです。',
   'Đây là sách của tôi.',
   3),
  (sid, l2,
   '〜はだれのですか',
   'Hỏi chủ sở hữu: "... là của ai?" だれ = ai.',
   'このかばんはだれのですか。',
   'Cái túi này là của ai?',
   4);


-- ════════════════════════════════════════
-- BÀI 2 EXERCISES
-- ════════════════════════════════════════
INSERT INTO mnn_exercises (site_id, lesson_id, type, question, options, answer, explanation_vi, order_index) VALUES
  (sid, l2, 'multiple_choice',
   'これは___ですか。(hỏi về đồ vật)',
   '["なん", "だれ", "どこ", "いくら"]',
   'なん',
   'なんですか = là cái gì? Dùng なん trước です.',
   1),
  (sid, l2, 'fill_blank',
   'これはわたし___ほんです。',
   NULL,
   'の',
   'Trợ từ の dùng để chỉ sở hữu: わたしのほん = sách của tôi.',
   2),
  (sid, l2, 'multiple_choice',
   '「ざっし」の意味は？',
   '["Tạp chí", "Báo", "Sách", "Vở"]',
   'Tạp chí',
   'ざっし (雑誌) = tạp chí.',
   3),
  (sid, l2, 'multiple_choice',
   'このかばんはだれ___ですか。',
   '["の", "は", "が", "を"]',
   'の',
   'だれの = của ai. Trợ từ の dùng sau đại từ nghi vấn.',
   4),
  (sid, l2, 'fill_blank',
   'それはボールペン___。(khẳng định)',
   NULL,
   'です',
   'Câu khẳng định kết thúc bằng です.',
   5),
  (sid, l2, 'multiple_choice',
   '「とけい」の意味は？',
   '["Đồng hồ", "Ô / Dù", "Túi xách", "Bút chì"]',
   'Đồng hồ',
   'とけい (時計) = đồng hồ.',
   6),
  (sid, l2, 'multiple_choice',
   'あれはだれのかさですか。— ___のです。(của tôi)',
   '["わたし", "あなた", "あのかた", "みなさん"]',
   'わたし',
   'わたしのです = của tôi.',
   7),
  (sid, l2, 'fill_blank',
   'あのかたは___のせんせいですか。(hỏi giáo viên tiếng gì)',
   NULL,
   'なにご',
   'なにご (何語) = tiếng gì. Hỏi về ngôn ngữ.',
   8);


-- ════════════════════════════════════════
-- BÀI 3 VOCABULARY
-- ════════════════════════════════════════
INSERT INTO mnn_vocabulary (site_id, lesson_id, word, reading, romanization, meaning_vi, part_of_speech, order_index) VALUES
  (sid, l3, 'ここ',       'ここ',       'koko',       'Đây / Chỗ này',                    '指示語', 1),
  (sid, l3, 'そこ',       'そこ',       'soko',       'Đó / Chỗ đó',                      '指示語', 2),
  (sid, l3, 'あそこ',     'あそこ',     'asoko',      'Kia / Chỗ kia',                    '指示語', 3),
  (sid, l3, 'どこ',       'どこ',       'doko',       'Đâu / Chỗ nào',                    '指示語', 4),
  (sid, l3, 'こちら',     'こちら',     'kochira',    'Phía này (lịch sự)',               '指示語', 5),
  (sid, l3, 'そちら',     'そちら',     'sochira',    'Phía đó (lịch sự)',                '指示語', 6),
  (sid, l3, 'あちら',     'あちら',     'achira',     'Phía kia (lịch sự)',               '指示語', 7),
  (sid, l3, 'どちら',     'どちら',     'dochira',    'Phía nào (lịch sự)',               '指示語', 8),
  (sid, l3, 'うえ',       'うえ',       'ue',         'Trên',                             '名詞',   9),
  (sid, l3, 'した',       'した',       'shita',      'Dưới',                             '名詞',   10),
  (sid, l3, 'まえ',       'まえ',       'mae',        'Trước',                            '名詞',   11),
  (sid, l3, 'うしろ',     'うしろ',     'ushiro',     'Sau / Phía sau',                   '名詞',   12),
  (sid, l3, 'みぎ',       'みぎ',       'migi',       'Bên phải',                         '名詞',   13),
  (sid, l3, 'ひだり',     'ひだり',     'hidari',     'Bên trái',                         '名詞',   14),
  (sid, l3, 'となり',     'となり',     'tonari',     'Bên cạnh',                         '名詞',   15),
  (sid, l3, 'ちかく',     'ちかく',     'chikaku',    'Gần / Gần đây',                    '名詞',   16),
  (sid, l3, 'あいだ',     'あいだ',     'aida',       'Giữa / Ở giữa',                    '名詞',   17),
  (sid, l3, 'デパート',   'デパート',   'depaato',    'Cửa hàng bách hóa',               '名詞',   18),
  (sid, l3, 'スーパー',   'スーパー',   'suupaa',     'Siêu thị',                         '名詞',   19),
  (sid, l3, 'コンビニ',   'コンビニ',   'konbini',    'Cửa hàng tiện lợi',               '名詞',   20),
  (sid, l3, 'うけつけ',   'うけつけ',   'uketsuke',   'Quầy lễ tân / Quầy tiếp đón',     '名詞',   21),
  (sid, l3, 'エレベーター','エレベーター','erebeetaa',  'Thang máy',                       '名詞',   22);


-- ════════════════════════════════════════
-- BÀI 3 GRAMMAR
-- ════════════════════════════════════════
INSERT INTO mnn_grammar (site_id, lesson_id, pattern, explanation_vi, example_ja, example_vi, order_index) VALUES
  (sid, l3,
   'ここ/そこ/あそこは〜です',
   'Chỉ thị nơi chốn: ここ (đây), そこ (đó), あそこ (kia). Dùng để chỉ vị trí một nơi nào đó.',
   'ここはうけつけです。',
   'Đây là quầy lễ tân.',
   1),
  (sid, l3,
   '〜はどこですか',
   'Hỏi vị trí: "... ở đâu?" どこ = ở đâu.',
   'トイレはどこですか。',
   'Nhà vệ sinh ở đâu?',
   2),
  (sid, l3,
   '〜に〜があります/います',
   'Diễn đạt sự tồn tại: あります cho vật vô sinh, います cho người/động vật. "Ở... có..."',
   'つくえのうえにほんがあります。',
   'Trên bàn có quyển sách.',
   3),
  (sid, l3,
   '〜は〜にあります/います',
   'Chỉ vị trí của một vật/người cụ thể: "... ở ..."',
   'ほんはつくえのうえにあります。',
   'Quyển sách ở trên bàn.',
   4);


-- ════════════════════════════════════════
-- BÀI 3 EXERCISES
-- ════════════════════════════════════════
INSERT INTO mnn_exercises (site_id, lesson_id, type, question, options, answer, explanation_vi, order_index) VALUES
  (sid, l3, 'multiple_choice',
   'トイレはどこ___か。',
   '["ですか", "がですか", "にですか", "はですか"]',
   'ですか',
   'どこですか = ở đâu vậy? Câu hỏi về vị trí.',
   1),
  (sid, l3, 'fill_blank',
   'つくえのうえにほん___あります。',
   NULL,
   'が',
   'が là trợ từ chủ ngữ trong câu ~があります.',
   2),
  (sid, l3, 'multiple_choice',
   '「みぎ」の反対は？',
   '["ひだり", "うえ", "した", "うしろ"]',
   'ひだり',
   'みぎ = bên phải ↔ ひだり = bên trái.',
   3),
  (sid, l3, 'multiple_choice',
   '「デパート」の意味は？',
   '["Cửa hàng bách hóa", "Siêu thị", "Cửa hàng tiện lợi", "Nhà hàng"]',
   'Cửa hàng bách hóa',
   'デパート = department store = cửa hàng bách hóa.',
   4),
  (sid, l3, 'fill_blank',
   'ほんはつくえの___にあります。(trên)',
   NULL,
   'うえ',
   'うえ = trên. つくえのうえ = trên bàn.',
   5),
  (sid, l3, 'multiple_choice',
   'エレベーターはどちら___すか。(lịch sự)',
   '["で", "が", "は", "に"]',
   'で',
   'どちらですか → nói tắt: どちらですか là dạng lịch sự của どこですか.',
   6),
  (sid, l3, 'multiple_choice',
   '「となり」の意味は？',
   '["Bên cạnh", "Ở giữa", "Gần đây", "Xa"]',
   'Bên cạnh',
   'となり = bên cạnh (ngay kề nhau).',
   7),
  (sid, l3, 'fill_blank',
   'スーパーはコンビニの___にあります。(bên cạnh)',
   NULL,
   'となり',
   'となり = bên cạnh. Chỉ vị trí kề nhau.',
   8);


-- ════════════════════════════════════════
-- BÀI 4 VOCABULARY
-- ════════════════════════════════════════
INSERT INTO mnn_vocabulary (site_id, lesson_id, word, reading, romanization, meaning_vi, part_of_speech, order_index) VALUES
  (sid, l4, 'いま',       'いま',       'ima',            'Bây giờ',                    '副詞',   1),
  (sid, l4, '〜じ',       '〜じ',       '~ ji',           '... giờ (số giờ)',           '接尾辞', 2),
  (sid, l4, '〜ふん/ぷん','〜ふん/ぷん','~ fun/pun',       '... phút',                   '接尾辞', 3),
  (sid, l4, 'はん',       'はん',       'han',            'Rưỡi (30 phút)',             '名詞',   4),
  (sid, l4, 'ごぜん',     'ごぜん',     'gozen',          'Buổi sáng (AM)',             '名詞',   5),
  (sid, l4, 'ごご',       'ごご',       'gogo',           'Buổi chiều (PM)',            '名詞',   6),
  (sid, l4, 'なんじ',     'なんじ',     'nanji',          'Mấy giờ',                    '疑問詞', 7),
  (sid, l4, 'なんぷん',   'なんぷん',   'nanpun',         'Bao nhiêu phút',             '疑問詞', 8),
  (sid, l4, 'から',       'から',       'kara',           'Từ (thời điểm bắt đầu)',     '助詞',   9),
  (sid, l4, 'まで',       'まで',       'made',           'Đến (thời điểm kết thúc)',   '助詞',   10),
  (sid, l4, 'やすみ',     'やすみ',     'yasumi',         'Ngày nghỉ / Giờ nghỉ',       '名詞',   11),
  (sid, l4, 'ひるやすみ', 'ひるやすみ', 'hiru yasumi',    'Giờ nghỉ trưa',              '名詞',   12),
  (sid, l4, 'しごと',     'しごと',     'shigoto',        'Công việc',                  '名詞',   13),
  (sid, l4, 'べんきょう', 'べんきょう', 'benkyou',        'Việc học / Học bài',         '名詞',   14),
  (sid, l4, 'まいにち',   'まいにち',   'mainichi',       'Mỗi ngày / Hàng ngày',      '副詞',   15),
  (sid, l4, 'げつようび', 'げつようび', 'getsuyoobi',     'Thứ Hai',                    '名詞',   16),
  (sid, l4, 'どようび',   'どようび',   'doyoobi',        'Thứ Bảy',                    '名詞',   17),
  (sid, l4, 'にちようび', 'にちようび', 'nichiyoobi',     'Chủ Nhật',                   '名詞',   18);


-- ════════════════════════════════════════
-- BÀI 4 GRAMMAR
-- ════════════════════════════════════════
INSERT INTO mnn_grammar (site_id, lesson_id, pattern, explanation_vi, example_ja, example_vi, order_index) VALUES
  (sid, l4,
   'いま〜じ〜ふんです',
   'Nói giờ hiện tại: いま (bây giờ) + số giờ + じ + số phút + ふん/ぷん + です.',
   'いまくじはんです。',
   'Bây giờ là 9 giờ rưỡi.',
   1),
  (sid, l4,
   '〜はなんじですか',
   'Hỏi giờ: "... là mấy giờ?" なんじ = mấy giờ.',
   'いまなんじですか。',
   'Bây giờ là mấy giờ?',
   2),
  (sid, l4,
   '〜から〜まで',
   'Chỉ khoảng thời gian: から = từ, まで = đến. Dùng với giờ, ngày, địa điểm.',
   'しごとはくじからごじまでです。',
   'Công việc từ 9 giờ đến 5 giờ.',
   3),
  (sid, l4,
   '〜から〜まで〜です (với ngày)',
   'Áp dụng から/まで với ngày trong tuần để chỉ lịch làm việc/nghỉ.',
   'やすみはどようびとにちようびです。',
   'Ngày nghỉ là thứ Bảy và Chủ Nhật.',
   4);


-- ════════════════════════════════════════
-- BÀI 4 EXERCISES
-- ════════════════════════════════════════
INSERT INTO mnn_exercises (site_id, lesson_id, type, question, options, answer, explanation_vi, order_index) VALUES
  (sid, l4, 'multiple_choice',
   'いまなんじ___か。',
   '["ですか", "がですか", "はですか", "でですか"]',
   'ですか',
   'なんじですか = mấy giờ rồi?',
   1),
  (sid, l4, 'fill_blank',
   'しごとはくじ___ごじまでです。',
   NULL,
   'から',
   'から = từ (thời điểm bắt đầu). くじから = từ 9 giờ.',
   2),
  (sid, l4, 'multiple_choice',
   '「ごぜん」の意味は？',
   '["Buổi sáng (AM)", "Buổi chiều (PM)", "Buổi tối", "Buổi trưa"]',
   'Buổi sáng (AM)',
   'ごぜん (午前) = AM (trước 12 giờ trưa). ↔ ごご (午後) = PM.',
   3),
  (sid, l4, 'multiple_choice',
   '「はん」の意味は？',
   '["30 phút (rưỡi)", "15 phút", "45 phút", "1 giờ"]',
   '30 phút (rưỡi)',
   'はん (半) = rưỡi = 30 phút. くじはん = 9 giờ rưỡi.',
   4),
  (sid, l4, 'fill_blank',
   'しごとはくじからごじ___です。',
   NULL,
   'まで',
   'まで = đến (thời điểm kết thúc).',
   5),
  (sid, l4, 'multiple_choice',
   'いまごぜんくじはんです。= いまなんじですか。',
   '["9:30 AM", "9:15 AM", "9:45 PM", "9:00 AM"]',
   '9:30 AM',
   'ごぜんくじはん = 9 giờ rưỡi sáng = 9:30 AM.',
   6),
  (sid, l4, 'multiple_choice',
   '「やすみ」の意味は？',
   '["Ngày nghỉ / Giờ nghỉ", "Công việc", "Học bài", "Giờ ăn trưa"]',
   'Ngày nghỉ / Giờ nghỉ',
   'やすみ (休み) = ngày nghỉ hoặc giờ nghỉ.',
   7),
  (sid, l4, 'fill_blank',
   'ひるやすみはじゅうにじから___じまでです。(1 giờ)',
   NULL,
   'いち',
   'いちじ = 1 giờ. Số đếm: いち(1) に(2) さん(3) よ/し(4) ご(5)...',
   8);


-- ════════════════════════════════════════
-- BÀI 5 VOCABULARY  (source: langoal.com/vocbs/lesson-5.html)
-- ════════════════════════════════════════
INSERT INTO mnn_vocabulary (site_id, lesson_id, word, reading, romanization, meaning_vi, part_of_speech, order_index) VALUES
  (sid, l5, '行きます',   'いきます',   'ikimasu',    'Đi (đến nơi nào đó)',        '動詞',   1),
  (sid, l5, '来ます',     'きます',     'kimasu',     'Đến / Lai',                  '動詞',   2),
  (sid, l5, '帰ります',   'かえります', 'kaerimasu',  'Về (nhà / nơi xuất phát)',   '動詞',   3),
  (sid, l5, '学校',       'がっこう',   'gakkou',     'Trường học',                 '名詞',   4),
  (sid, l5, 'スーパー',   'スーパー',   'suupaa',     'Siêu thị',                   '名詞',   5),
  (sid, l5, '駅',         'えき',       'eki',        'Ga tàu / Nhà ga',            '名詞',   6),
  (sid, l5, '飛行機',     'ひこうき',   'hikouki',    'Máy bay',                    '名詞',   7),
  (sid, l5, '船',         'ふね',       'fune',       'Tàu thuyền',                 '名詞',   8),
  (sid, l5, '電車',       'でんしゃ',   'densha',     'Tàu điện / Tàu hỏa',         '名詞',   9),
  (sid, l5, '地下鉄',     'ちかてつ',   'chikatetsu', 'Tàu điện ngầm',              '名詞',   10),
  (sid, l5, '新幹線',     'しんかんせん','shinkansen', 'Tàu cao tốc Shinkansen',     '名詞',   11),
  (sid, l5, 'バス',       'バス',       'basu',       'Xe buýt',                    '名詞',   12),
  (sid, l5, 'タクシー',   'タクシー',   'takushii',   'Taxi',                       '名詞',   13),
  (sid, l5, '自転車',     'じてんしゃ', 'jitensha',   'Xe đạp',                     '名詞',   14),
  (sid, l5, '歩いて',     'あるいて',   'aruite',     'Đi bộ',                      '副詞',   15),
  (sid, l5, '友達',       'ともだち',   'tomodachi',  'Bạn bè',                     '名詞',   16),
  (sid, l5, '彼',         'かれ',       'kare',       'Anh ấy / Bạn trai',          '名詞',   17),
  (sid, l5, '彼女',       'かのじょ',   'kanojo',     'Cô ấy / Bạn gái',            '名詞',   18),
  (sid, l5, '家族',       'かぞく',     'kazoku',     'Gia đình',                   '名詞',   19),
  (sid, l5, '一人で',     'ひとりで',   'hitori de',  'Một mình',                   '副詞',   20),
  (sid, l5, 'いつ',       'いつ',       'itsu',       'Khi nào / Bao giờ',          '疑問詞', 21),
  (sid, l5, '先週',       'せんしゅう', 'senshuu',    'Tuần trước',                 '名詞',   22),
  (sid, l5, '今週',       'こんしゅう', 'konshuu',    'Tuần này',                   '名詞',   23),
  (sid, l5, '来週',       'らいしゅう', 'raishuu',    'Tuần sau',                   '名詞',   24);


-- ════════════════════════════════════════
-- BÀI 5 GRAMMAR
-- ════════════════════════════════════════
INSERT INTO mnn_grammar (site_id, lesson_id, pattern, explanation_vi, example_ja, example_vi, order_index) VALUES
  (sid, l5,
   'N へ 行きます/来ます/帰ります',
   'Chỉ hướng di chuyển: trợ từ へ (đọc là え) đánh dấu đích đến. Dùng với 3 động từ di chuyển cơ bản.',
   'わたしはがっこうへ行きます。',
   'Tôi đi đến trường.',
   1),
  (sid, l5,
   'N で 行きます (phương tiện)',
   'Trợ từ で chỉ phương tiện di chuyển: "đi bằng...". Nếu đi bộ dùng あるいて (không dùng で).',
   'バスで来ます。',
   'Đến bằng xe buýt.',
   2),
  (sid, l5,
   'N と 行きます (cùng với)',
   'Trợ từ と chỉ người đi cùng: "đi với...". Khi đi một mình dùng ひとりで.',
   'ともだちと帰ります。',
   'Về cùng bạn bè.',
   3),
  (sid, l5,
   'いつ〜ますか',
   'Hỏi thời điểm: "Khi nào...?" いつ = khi nào, bao giờ.',
   'いつ日本へ来ますか。',
   'Bạn đến Nhật khi nào?',
   4);


-- ════════════════════════════════════════
-- BÀI 5 EXERCISES
-- ════════════════════════════════════════
INSERT INTO mnn_exercises (site_id, lesson_id, type, question, options, answer, explanation_vi, order_index) VALUES
  (sid, l5, 'multiple_choice',
   'わたしはがっこう___行きます。(đến trường)',
   '["へ", "で", "に", "を"]',
   'へ',
   'Trợ từ へ chỉ đích đến của di chuyển. がっこうへ行きます = đi đến trường.',
   1),
  (sid, l5, 'multiple_choice',
   'バス___来ます。(bằng xe buýt)',
   '["で", "へ", "と", "に"]',
   'で',
   'Trợ từ で chỉ phương tiện. バスで = bằng xe buýt.',
   2),
  (sid, l5, 'multiple_choice',
   '「帰ります」の意味は？',
   '["Về (nhà/nơi xuất phát)", "Đi (đến nơi mới)", "Đến / Lai", "Đi bộ"]',
   'Về (nhà/nơi xuất phát)',
   'かえります = trở về nơi xuất phát (nhà, công ty...).',
   3),
  (sid, l5, 'fill_blank',
   'ともだち___帰ります。(về cùng bạn)',
   NULL,
   'と',
   'Trợ từ と = cùng với. ともだちと = cùng với bạn bè.',
   4),
  (sid, l5, 'multiple_choice',
   '「でんしゃ」の意味は？',
   '["Tàu điện / Tàu hỏa", "Xe buýt", "Taxi", "Xe đạp"]',
   'Tàu điện / Tàu hỏa',
   'でんしゃ (電車) = tàu điện chạy trên mặt đất.',
   5),
  (sid, l5, 'fill_blank',
   'いつ日本___来ますか。(đến Nhật khi nào?)',
   NULL,
   'へ',
   'へ đánh dấu đích đến. 日本へ来ます = đến Nhật.',
   6),
  (sid, l5, 'multiple_choice',
   '___で行きます。(đi bộ — không dùng phương tiện)',
   '["あるいて", "ひとりで", "ともだちと", "バスで"]',
   'あるいて',
   'あるいて = đi bộ. Không dùng で vì đây là trạng từ, không phải danh từ phương tiện.',
   7),
  (sid, l5, 'multiple_choice',
   '「先週」の意味は？',
   '["Tuần trước", "Tuần này", "Tuần sau", "Hôm qua"]',
   'Tuần trước',
   'せんしゅう (先週) = tuần trước. こんしゅう = tuần này, らいしゅう = tuần sau.',
   8);

END $$;
