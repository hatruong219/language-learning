-- Seed 150 writing prompts: 30 per JLPT level (N5 → N1)
-- site_id: 1219bda2-aa1e-4288-ab7e-caff011cdf5c
-- Run in Supabase SQL editor

DO $$
DECLARE
  sid UUID := '1219bda2-aa1e-4288-ab7e-caff011cdf5c';
BEGIN

-- ============================================================
-- N5 — 30 đề — min_words: 30 — Chủ đề đơn giản, hàng ngày
-- ============================================================
INSERT INTO writing_prompts (site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, order_index) VALUES
(sid, 'Giới thiệu bản thân',
 'Hãy viết một đoạn văn giới thiệu về bản thân bạn (tên, tuổi, quê quán, công việc hoặc sở thích).',
 '自己紹介をしてください。', 'self', 'N5', 30, 1),

(sid, 'Gia đình bạn',
 'Hãy mô tả gia đình bạn. Gia đình bạn có mấy người? Họ làm gì?',
 '家族について書いてください。', 'family', 'N5', 30, 2),

(sid, 'Món ăn yêu thích',
 'Món ăn bạn yêu thích là gì? Tại sao bạn thích món đó?',
 '好きな食べ物について書いてください。', 'hobby', 'N5', 30, 3),

(sid, 'Thú cưng của bạn',
 'Bạn có thú cưng không? Nếu có, hãy mô tả. Nếu không, bạn muốn nuôi con gì?',
 'ペットについて書いてください。', 'self', 'N5', 30, 4),

(sid, 'Thời tiết hôm nay',
 'Thời tiết hôm nay ở nơi bạn sống như thế nào? Bạn thích thời tiết này không?',
 '今日の天気について書いてください。', 'general', 'N5', 30, 5),

(sid, 'Sở thích của bạn',
 'Bạn thích làm gì lúc rảnh? Hãy giới thiệu một sở thích của bạn.',
 '趣味について書いてください。', 'hobby', 'N5', 30, 6),

(sid, 'Mùa yêu thích',
 'Bạn thích mùa nào nhất? Tại sao?',
 '好きな季節について書いてください。', 'general', 'N5', 30, 7),

(sid, 'Buổi sáng của bạn',
 'Buổi sáng bạn thường làm gì? Bạn ăn sáng gì?',
 '朝のルーティンについて書いてください。', 'self', 'N5', 30, 8),

(sid, 'Ngôi nhà của bạn',
 'Hãy mô tả ngôi nhà hoặc phòng bạn đang ở. Nó có những gì?',
 '自分の部屋や家について書いてください。', 'self', 'N5', 30, 9),

(sid, 'Người bạn thân nhất',
 'Bạn thân nhất của bạn là ai? Bạn thường làm gì cùng nhau?',
 '一番仲のいい友達について書いてください。', 'family', 'N5', 30, 10),

(sid, 'Trường học hoặc nơi làm việc',
 'Trường bạn học hoặc nơi bạn làm việc như thế nào? Bạn có thích không?',
 '学校や職場について書いてください。', 'self', 'N5', 30, 11),

(sid, 'Loài vật yêu thích',
 'Con vật bạn yêu thích là gì? Hãy mô tả con vật đó.',
 '好きな動物について書いてください。', 'hobby', 'N5', 30, 12),

(sid, 'Cuối tuần của bạn',
 'Cuối tuần bạn thường làm gì? Hôm qua bạn đã làm gì?',
 '週末の過ごし方について書いてください。', 'hobby', 'N5', 30, 13),

(sid, 'Đồ vật quý giá',
 'Bạn có đồ vật nào mà bạn thích nhất không? Đó là gì? Tại sao bạn thích?',
 '大切にしているものについて書いてください。', 'self', 'N5', 30, 14),

(sid, 'Màu sắc yêu thích',
 'Màu sắc bạn yêu thích là gì? Tại sao bạn thích màu đó?',
 '好きな色について書いてください。', 'hobby', 'N5', 30, 15),

(sid, 'Sinh nhật của bạn',
 'Sinh nhật của bạn là ngày mấy? Bạn thường làm gì vào ngày sinh nhật?',
 '誕生日について書いてください。', 'self', 'N5', 30, 16),

(sid, 'Đồ ăn không thích',
 'Có món ăn nào bạn không thích không? Tại sao bạn không thích?',
 '嫌いな食べ物について書いてください。', 'general', 'N5', 30, 17),

(sid, 'Đường đến trường/công ty',
 'Bạn đi đến trường hoặc công ty bằng phương tiện gì? Mất bao lâu?',
 '学校や会社までの行き方について書いてください。', 'self', 'N5', 30, 18),

(sid, 'Môn thể thao yêu thích',
 'Bạn thích môn thể thao nào? Bạn có chơi môn đó không?',
 '好きなスポーツについて書いてください。', 'hobby', 'N5', 30, 19),

(sid, 'Bữa tối hôm qua',
 'Tối qua bạn ăn gì? Ai nấu? Bạn thấy ngon không?',
 '昨日の夜ご飯について書いてください。', 'family', 'N5', 30, 20),

(sid, 'Âm nhạc yêu thích',
 'Bạn thích nghe loại nhạc gì? Ca sĩ hoặc ban nhạc bạn thích là ai?',
 '好きな音楽について書いてください。', 'hobby', 'N5', 30, 21),

(sid, 'Phim yêu thích',
 'Bạn thích xem phim gì? Hãy giới thiệu một bộ phim bạn thích.',
 '好きな映画やドラマについて書いてください。', 'hobby', 'N5', 30, 22),

(sid, 'Lý do học tiếng Nhật',
 'Tại sao bạn học tiếng Nhật? Bạn bắt đầu học từ bao giờ?',
 '日本語を勉強している理由について書いてください。', 'self', 'N5', 30, 23),

(sid, 'Nơi bạn sống',
 'Bạn sống ở đâu? Gần nhà bạn có gì? Bạn có thích nơi đó không?',
 '住んでいる場所について書いてください。', 'self', 'N5', 30, 24),

(sid, 'Bữa sáng yêu thích',
 'Bạn thường ăn sáng gì? Bạn thích ăn sáng ở nhà hay ăn ngoài?',
 '好きな朝ごはんについて書いてください。', 'general', 'N5', 30, 25),

(sid, 'Gia đình vào cuối tuần',
 'Gia đình bạn thường làm gì vào cuối tuần? Bạn có thích không?',
 '家族と週末に何をするか書いてください。', 'family', 'N5', 30, 26),

(sid, 'Điều bạn muốn mua',
 'Có thứ gì bạn đang muốn mua không? Đó là gì? Tại sao bạn muốn mua?',
 '欲しいものについて書いてください。', 'hobby', 'N5', 30, 27),

(sid, 'Ngày hôm qua',
 'Hôm qua bạn đã làm gì? Từ sáng đến tối bạn đã đi đâu và làm gì?',
 '昨日したことについて書いてください。', 'general', 'N5', 30, 28),

(sid, 'Đồ uống yêu thích',
 'Bạn thích uống gì nhất? Một ngày bạn thường uống gì?',
 '好きな飲み物について書いてください。', 'hobby', 'N5', 30, 29),

(sid, 'Điều muốn làm trong kỳ nghỉ',
 'Nếu bạn có một ngày nghỉ tự do, bạn muốn làm gì?',
 '休みの日にしたいことについて書いてください。', 'hobby', 'N5', 30, 30);

-- ============================================================
-- N4 — 30 đề — min_words: 50
-- ============================================================
INSERT INTO writing_prompts (site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, order_index) VALUES
(sid, 'Ký ức du lịch',
 'Hãy kể về một chuyến du lịch bạn đã đi. Bạn đến đâu, làm gì và cảm thấy như thế nào?',
 '旅行の思い出について書いてください。', 'hobby', 'N4', 50, 1),

(sid, 'Thứ vừa mua gần đây',
 'Gần đây bạn đã mua thứ gì? Tại sao bạn mua? Bạn có hài lòng không?',
 '最近買ったものについて書いてください。', 'hobby', 'N4', 50, 2),

(sid, 'Ước mơ tương lai',
 'Ước mơ hoặc mục tiêu tương lai của bạn là gì? Bạn đang làm gì để đạt được điều đó?',
 '将来の夢や目標について書いてください。', 'self', 'N4', 50, 3),

(sid, 'Cuốn sách yêu thích',
 'Hãy giới thiệu một cuốn sách bạn yêu thích. Nội dung là gì? Tại sao bạn thích?',
 '好きな本について書いてください。', 'hobby', 'N4', 50, 4),

(sid, 'Thói quen giữ sức khỏe',
 'Bạn làm gì để giữ sức khỏe? Bạn có thói quen thể dục hay ăn uống lành mạnh không?',
 '健康のために何をしているか書いてください。', 'self', 'N4', 50, 5),

(sid, 'Về đất nước Nhật Bản',
 'Bạn biết gì về Nhật Bản? Điều gì của Nhật Bản khiến bạn thấy thú vị?',
 '日本について知っていることを書いてください。', 'general', 'N4', 50, 6),

(sid, 'Cách dùng điện thoại',
 'Bạn dùng điện thoại thông minh để làm gì? Ứng dụng nào bạn dùng nhiều nhất?',
 'スマートフォンの使い方について書いてください。', 'hobby', 'N4', 50, 7),

(sid, 'Kỷ niệm với bạn bè',
 'Hãy kể một kỷ niệm đáng nhớ với bạn bè. Chuyện gì đã xảy ra?',
 '友達との思い出について書いてください。', 'family', 'N4', 50, 8),

(sid, 'Khi còn nhỏ',
 'Khi còn nhỏ bạn thích làm gì? Bạn có kỷ niệm nào đặc biệt thời thơ ấu không?',
 '子供の頃について書いてください。', 'self', 'N4', 50, 9),

(sid, 'Món bạn giỏi nấu',
 'Bạn nấu giỏi món gì? Hãy mô tả cách làm món đó.',
 '得意な料理について書いてください。', 'hobby', 'N4', 50, 10),

(sid, 'Phim/Drama gần xem',
 'Gần đây bạn xem bộ phim hay drama nào? Nội dung là gì? Bạn có thích không?',
 '最近見た映画やドラマについて書いてください。', 'hobby', 'N4', 50, 11),

(sid, 'Nơi muốn đến ở Nhật',
 'Nếu đến Nhật Bản, bạn muốn đến nơi nào nhất? Tại sao?',
 '日本で行ってみたい場所について書いてください。', 'hobby', 'N4', 50, 12),

(sid, 'Kỷ niệm nhận quà',
 'Hãy kể về một món quà bạn nhận được mà bạn thấy vui hoặc ấn tượng nhất.',
 'もらったプレゼントについて書いてください。', 'family', 'N4', 50, 13),

(sid, 'Sự kiện vui gần đây',
 'Gần đây bạn có chuyện gì vui không? Hãy kể chi tiết.',
 '最近嬉しかった出来事について書いてください。', 'general', 'N4', 50, 14),

(sid, 'Về ẩm thực Nhật Bản',
 'Bạn đã thử món ăn Nhật nào? Bạn thích nhất món gì? Hãy mô tả.',
 '日本食について書いてください。', 'general', 'N4', 50, 15),

(sid, 'Sử dụng internet',
 'Bạn dùng internet để làm gì trong cuộc sống hàng ngày?',
 'インターネットの使い方について書いてください。', 'general', 'N4', 50, 16),

(sid, 'Sở thích mới',
 'Gần đây bạn có bắt đầu sở thích mới nào không? Đó là gì và bạn thích điều gì ở nó?',
 '最近始めた趣味について書いてください。', 'hobby', 'N4', 50, 17),

(sid, 'Game yêu thích',
 'Bạn có chơi game không? Bạn thích loại game nào? Tại sao?',
 '好きなゲームについて書いてください。', 'hobby', 'N4', 50, 18),

(sid, 'Điều muốn thử thách',
 'Có điều gì bạn muốn thử thách hoặc học mới không? Tại sao bạn muốn làm điều đó?',
 'チャレンジしたいことについて書いてください。', 'self', 'N4', 50, 19),

(sid, 'Phương pháp học tiếng Nhật',
 'Bạn học tiếng Nhật như thế nào? Phương pháp nào hiệu quả với bạn?',
 '日本語の勉強方法について書いてください。', 'self', 'N4', 50, 20),

(sid, 'Biết ơn gia đình',
 'Hãy viết về điều bạn biết ơn gia đình. Bố mẹ hoặc người thân đã làm gì cho bạn?',
 '家族への感謝について書いてください。', 'family', 'N4', 50, 21),

(sid, 'Điểm mạnh và điểm yếu',
 'Điểm mạnh và điểm yếu của bạn là gì? Hãy giải thích với ví dụ cụ thể.',
 '自分の長所と短所について書いてください。', 'self', 'N4', 50, 22),

(sid, 'Lễ hội hoặc sự kiện yêu thích',
 'Bạn thích lễ hội hoặc sự kiện nào nhất? Hãy mô tả và giải thích lý do.',
 '好きなお祭りやイベントについて書いてください。', 'general', 'N4', 50, 23),

(sid, 'Người nổi tiếng yêu thích',
 'Bạn thích người nổi tiếng nào? Đó là diễn viên, ca sĩ hay ai? Tại sao bạn thích?',
 '好きな有名人について書いてください。', 'hobby', 'N4', 50, 24),

(sid, 'Muốn sống ở đâu trong tương lai',
 'Trong tương lai bạn muốn sống ở đâu? Ở thành phố hay nông thôn? Trong nước hay nước ngoài?',
 '将来どこに住みたいか書いてください。', 'self', 'N4', 50, 25),

(sid, 'Buồn nhất là gì',
 'Gần đây hay trong cuộc sống bạn có điều gì khiến bạn buồn không? Hãy kể.',
 '最近悲しかったことについて書いてください。', 'general', 'N4', 50, 26),

(sid, 'Sự kiện gần đây trong cuộc sống',
 'Gần đây có chuyện gì đặc biệt xảy ra trong cuộc sống của bạn không? Hãy kể.',
 '最近の出来事について書いてください。', 'general', 'N4', 50, 27),

(sid, 'Bạn thích mùa hè hay mùa đông?',
 'Bạn thích mùa hè hay mùa đông hơn? Hãy so sánh và giải thích lý do.',
 '夏と冬、どちらが好きですか。理由も書いてください。', 'general', 'N4', 50, 28),

(sid, 'Điều khó khăn ở trường/công ty',
 'Điều gì ở trường học hoặc công việc khiến bạn thấy khó khăn nhất? Bạn xử lý như thế nào?',
 '学校や仕事で大変なことについて書いてください。', 'self', 'N4', 50, 29),

(sid, 'Nơi yêu thích gần nhà',
 'Gần nhà bạn có nơi nào bạn đặc biệt thích không? Đó là nơi gì? Tại sao bạn thích?',
 '家の近くのお気に入りの場所について書いてください。', 'hobby', 'N4', 50, 30);

-- ============================================================
-- N3 — 30 đề — min_words: 80
-- ============================================================
INSERT INTO writing_prompts (site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, order_index) VALUES
(sid, 'Mạng xã hội: lợi và hại',
 'Mạng xã hội mang lại những lợi ích và tác hại gì? Hãy nêu ý kiến của bạn với ví dụ cụ thể.',
 'SNSのメリットとデメリットについて意見を書いてください。', 'general', 'N3', 80, 1),

(sid, 'Kỳ nghỉ lý tưởng',
 'Kỳ nghỉ lý tưởng của bạn trông như thế nào? Bạn sẽ đi đâu, làm gì và với ai?',
 '理想の休日について詳しく書いてください。', 'hobby', 'N3', 80, 2),

(sid, 'Bài học từ thất bại',
 'Hãy kể về một lần bạn thất bại và bạn đã học được gì từ kinh nghiệm đó.',
 '失敗から学んだことについて書いてください。', 'self', 'N3', 80, 3),

(sid, 'Văn hóa Nhật Bản bạn quan tâm',
 'Có khía cạnh văn hóa nào của Nhật Bản mà bạn thấy thú vị hoặc muốn tìm hiểu thêm không?',
 '興味のある日本文化について書いてください。', 'general', 'N3', 80, 4),

(sid, 'Lối sống lành mạnh',
 'Theo bạn, lối sống lành mạnh là như thế nào? Bạn đang thực hiện điều gì để sống lành mạnh hơn?',
 '健康的な生活について自分の意見を書いてください。', 'self', 'N3', 80, 5),

(sid, 'Ảnh hưởng của công nghệ',
 'Công nghệ đã thay đổi cuộc sống của bạn như thế nào? Nêu ví dụ cụ thể về điểm tốt và xấu.',
 'テクノロジーが生活に与える影響について書いてください。', 'general', 'N3', 80, 6),

(sid, 'Tình bạn là gì',
 'Theo bạn, tình bạn thật sự là gì? Một người bạn tốt cần có những phẩm chất gì?',
 '友情とはどんなものだと思いますか。書いてください。', 'family', 'N3', 80, 7),

(sid, 'Thành phố và nông thôn',
 'Bạn thích sống ở thành phố hay nông thôn hơn? So sánh điểm tốt và xấu của cả hai.',
 '都市と田舎の違いについて比べながら書いてください。', 'general', 'N3', 80, 8),

(sid, 'Tầm quan trọng của việc đọc sách',
 'Bạn nghĩ đọc sách có quan trọng không? Tại sao? Hãy nêu ý kiến và ví dụ cụ thể.',
 '読書の大切さについて意見を書いてください。', 'hobby', 'N3', 80, 9),

(sid, 'Âm nhạc và con người',
 'Âm nhạc có ảnh hưởng như thế nào đến cuộc sống và cảm xúc của bạn? Hãy chia sẻ.',
 '音楽が人に与える影響について書いてください。', 'hobby', 'N3', 80, 10),

(sid, 'Mục đích du lịch',
 'Theo bạn, tại sao con người cần đi du lịch? Bạn đi du lịch để làm gì?',
 '旅行の目的について自分の意見を書いてください。', 'hobby', 'N3', 80, 11),

(sid, 'Ẩm thực và văn hóa',
 'Ẩm thực phản ánh văn hóa của một đất nước như thế nào? Hãy lấy ví dụ từ Việt Nam hoặc Nhật Bản.',
 '食文化の違いについて具体例をあげながら書いてください。', 'general', 'N3', 80, 12),

(sid, 'Tầm quan trọng của gia đình',
 'Gia đình có ý nghĩa như thế nào trong cuộc sống của bạn? Hãy viết cảm nghĩ của bạn.',
 '家族の大切さについて自分の気持ちを書いてください。', 'family', 'N3', 80, 13),

(sid, 'Có ước mơ quan trọng không',
 'Bạn có nghĩ rằng có ước mơ là quan trọng không? Tại sao? Hãy nêu ý kiến.',
 '夢を持つことの大切さについて意見を書いてください。', 'self', 'N3', 80, 14),

(sid, 'Anime và manga Nhật',
 'Bạn nghĩ gì về văn hóa anime và manga của Nhật? Bạn có thích không? Tại sao?',
 '日本のアニメや漫画文化についての意見を書いてください。', 'hobby', 'N3', 80, 15),

(sid, 'Thầy/cô giáo ấn tượng',
 'Hãy kể về một thầy/cô giáo đã để lại ấn tượng sâu sắc với bạn. Họ đã dạy bạn điều gì?',
 '印象に残っている先生について書いてください。', 'general', 'N3', 80, 16),

(sid, 'Cách quản lý thời gian',
 'Bạn quản lý thời gian của mình như thế nào? Bạn có mẹo gì để làm việc hiệu quả không?',
 '時間の使い方や管理について書いてください。', 'self', 'N3', 80, 17),

(sid, 'Cách giảm stress',
 'Khi bị stress, bạn thường làm gì để giải tỏa? Hãy chia sẻ các phương pháp của bạn.',
 'ストレス解消法について書いてください。', 'self', 'N3', 80, 18),

(sid, 'Ý nghĩa của thể thao',
 'Bạn nghĩ thể thao có ý nghĩa gì với con người? Ngoài sức khỏe thể chất, nó còn mang lại gì?',
 'スポーツの意義について自分の意見を書いてください。', 'hobby', 'N3', 80, 19),

(sid, 'Giao lưu văn hóa',
 'Giao lưu văn hóa giữa các quốc gia có lợi ích gì? Bạn đã học được gì từ văn hóa nước khác?',
 '異文化交流について思うことを書いてください。', 'general', 'N3', 80, 20),

(sid, 'Điều muốn thay đổi trong bản thân',
 'Nếu có thể thay đổi một điều về bản thân, bạn sẽ thay đổi gì? Tại sao?',
 '自分を変えたいことについて書いてください。', 'self', 'N3', 80, 21),

(sid, 'Thiên nhiên quan trọng như thế nào',
 'Thiên nhiên quan trọng với cuộc sống của con người như thế nào? Chúng ta cần làm gì để bảo vệ nó?',
 '自然の大切さについて書いてください。', 'general', 'N3', 80, 22),

(sid, 'Giáo dục theo quan điểm của bạn',
 'Theo bạn, giáo dục tốt là như thế nào? Trường học nên dạy những gì ngoài kiến thức?',
 '教育についての意見を書いてください。', 'general', 'N3', 80, 23),

(sid, 'Cuộc sống ở nước ngoài',
 'Bạn có muốn sống ở nước ngoài không? Nếu có, ở đâu và tại sao? Nếu không, lý do là gì?',
 '外国に住むことについて自分の意見を書いてください。', 'self', 'N3', 80, 24),

(sid, 'Sự thay đổi của xã hội',
 'Xã hội đã thay đổi như thế nào so với 20 năm trước? Điều gì thay đổi tích cực và tiêu cực?',
 '20年前と比べて社会はどう変わったか書いてください。', 'general', 'N3', 80, 25),

(sid, 'Nghề nghiệp mơ ước',
 'Công việc hay nghề nghiệp bạn mơ ước là gì? Tại sao bạn chọn nghề đó?',
 '将来の夢の仕事について詳しく書いてください。', 'self', 'N3', 80, 26),

(sid, 'Sự khác biệt giữa các thế hệ',
 'Bạn nghĩ thế hệ trẻ ngày nay khác thế hệ bố mẹ ở điểm nào? Điểm tốt và xấu là gì?',
 '若い世代と親の世代の違いについて書いてください。', 'family', 'N3', 80, 27),

(sid, 'Tiền và hạnh phúc',
 'Bạn nghĩ tiền bạc và hạnh phúc có liên quan với nhau không? Hãy nêu ý kiến của bạn.',
 'お金と幸福の関係についての意見を書いてください。', 'general', 'N3', 80, 28),

(sid, 'Sự cần thiết của ngoại ngữ',
 'Tại sao việc học ngoại ngữ lại quan trọng trong thế giới ngày nay? Hãy lập luận với ví dụ.',
 '外国語を学ぶことの必要性について書いてください。', 'general', 'N3', 80, 29),

(sid, 'Kỷ niệm thời thơ ấu đáng nhớ',
 'Hãy kể một kỷ niệm thời thơ ấu mà bạn nhớ mãi. Chuyện gì đã xảy ra và tại sao nó quan trọng với bạn?',
 '子供の頃の忘れられない思い出について書いてください。', 'self', 'N3', 80, 30);

-- ============================================================
-- N2 — 30 đề — min_words: 120
-- ============================================================
INSERT INTO writing_prompts (site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, order_index) VALUES
(sid, 'AI và tương lai xã hội',
 'Trí tuệ nhân tạo (AI) đang thay đổi xã hội như thế nào? Hãy phân tích những cơ hội và thách thức mà AI mang lại.',
 'AIが社会に与える影響について、メリットとデメリットを踏まえながら論じてください。', 'general', 'N2', 120, 1),

(sid, 'Vấn đề già hóa dân số',
 'Nhật Bản và nhiều nước đang đối mặt với tình trạng già hóa dân số. Hãy phân tích vấn đề này và đề xuất giải pháp.',
 '少子高齢化問題について原因と解決策を考えて書いてください。', 'general', 'N2', 120, 2),

(sid, 'Cải cách cách làm việc',
 'Cách làm việc của con người đang thay đổi như thế nào? Work from home, làm việc linh hoạt — lợi và hại là gì?',
 '働き方の変化について自分の考えを書いてください。', 'general', 'N2', 120, 3),

(sid, 'Bảo tồn văn hóa truyền thống',
 'Làm thế nào để bảo tồn văn hóa truyền thống trong thời đại toàn cầu hóa? Hãy nêu quan điểm của bạn.',
 '伝統文化をどのように守るべきか、自分の意見を述べてください。', 'general', 'N2', 120, 4),

(sid, 'Bảo vệ môi trường vs phát triển kinh tế',
 'Giữa bảo vệ môi trường và phát triển kinh tế, bạn nghĩ chúng ta nên ưu tiên điều gì? Hãy lập luận có dẫn chứng.',
 '環境保護と経済発展のどちらを優先すべきか、論拠を示しながら論じてください。', 'general', 'N2', 120, 5),

(sid, 'Mặt trái của toàn cầu hóa',
 'Toàn cầu hóa mang lại nhiều lợi ích nhưng cũng gây ra nhiều vấn đề. Hãy phân tích cả hai mặt.',
 'グローバル化のメリットとデメリットについて論じてください。', 'general', 'N2', 120, 6),

(sid, 'Vấn đề với hệ thống giáo dục',
 'Theo bạn, hệ thống giáo dục hiện nay có những vấn đề gì? Cần cải thiện điều gì?',
 '現在の教育制度の問題点と改善策について論じてください。', 'general', 'N2', 120, 7),

(sid, 'SNS và quan hệ con người',
 'Mạng xã hội đang ảnh hưởng như thế nào đến mối quan hệ giữa người với người? Hãy phân tích sâu.',
 'SNSが人間関係に与える影響について詳しく論じてください。', 'general', 'N2', 120, 8),

(sid, 'Bình đẳng giới',
 'Bình đẳng giới trong xã hội hiện đại — những tiến bộ đã đạt được và những thách thức còn tồn tại là gì?',
 'ジェンダー平等について、現状と課題を分析して書いてください。', 'general', 'N2', 120, 9),

(sid, 'Khoảng cách nông thôn và thành thị',
 'Khoảng cách kinh tế và cơ hội giữa khu vực thành thị và nông thôn — nguyên nhân và cách thu hẹp là gì?',
 '都市と地方の格差問題について原因と解決策を考えて書いてください。', 'general', 'N2', 120, 10),

(sid, 'Làm việc từ xa',
 'Làm việc từ xa (remote work) đã thay đổi cuộc sống của bạn hoặc xã hội như thế nào? Nêu phân tích cụ thể.',
 'リモートワークについて自分の考えや経験を踏まえて論じてください。', 'general', 'N2', 120, 11),

(sid, 'Xã hội tiêu dùng',
 'Chúng ta đang sống trong xã hội tiêu dùng. Hãy phân tích mặt tốt và xấu của lối sống này.',
 '消費社会について問題点と良い面を分析して書いてください。', 'general', 'N2', 120, 12),

(sid, 'Internet và thông tin cá nhân',
 'Internet đang đe dọa thông tin cá nhân của chúng ta như thế nào? Chúng ta nên làm gì để bảo vệ bản thân?',
 'インターネットと個人情報の保護について論じてください。', 'general', 'N2', 120, 13),

(sid, 'Mối quan hệ ngôn ngữ và văn hóa',
 'Ngôn ngữ và văn hóa có mối liên hệ như thế nào? Học ngôn ngữ giúp chúng ta hiểu văn hóa ra sao?',
 '言語と文化の関係について具体例を挙げながら論じてください。', 'general', 'N2', 120, 14),

(sid, 'Du lịch: phát triển và thách thức',
 'Du lịch mang lại lợi ích kinh tế nhưng cũng gây ra nhiều vấn đề. Hãy phân tích cả hai mặt.',
 '観光業の発展と課題について論じてください。', 'general', 'N2', 120, 15),

(sid, 'Cô đơn trong xã hội hiện đại',
 'Dù sống trong xã hội kết nối cao, nhiều người vẫn cảm thấy cô đơn. Nguyên nhân và giải pháp là gì?',
 '現代社会における孤独の問題について原因と解決策を論じてください。', 'general', 'N2', 120, 16),

(sid, 'Ưu tiên trong cuộc sống',
 'Trong cuộc sống, bạn ưu tiên điều gì nhất — sự nghiệp, gia đình, sức khỏe hay điều khác? Hãy lập luận.',
 '人生で何を最も大切にすべきか、自分の価値観を述べてください。', 'self', 'N2', 120, 17),

(sid, 'Người trẻ và chính trị',
 'Người trẻ tuổi có nên quan tâm và tham gia chính trị không? Hãy nêu quan điểm có lập luận.',
 '若者の政治参加についての意見を論じてください。', 'general', 'N2', 120, 18),

(sid, 'Khoa học và đạo đức',
 'Sự tiến bộ của khoa học đặt ra những câu hỏi đạo đức nào? Hãy lấy một ví dụ cụ thể để phân tích.',
 '科学技術の進歩と倫理問題について、具体例を挙げながら論じてください。', 'general', 'N2', 120, 19),

(sid, 'Bất bình đẳng kinh tế',
 'Khoảng cách giàu nghèo ngày càng tăng là vấn đề của nhiều quốc gia. Nguyên nhân và hướng giải quyết là gì?',
 '経済格差の問題について原因と解決策を考えながら書いてください。', 'general', 'N2', 120, 20),

(sid, 'Robot và tương lai công việc',
 'Robot và tự động hóa đang thay thế nhiều công việc. Điều này có phải là mối đe dọa không? Hãy phân tích.',
 'ロボットと自動化が雇用に与える影響について論じてください。', 'general', 'N2', 120, 21),

(sid, 'Vấn đề an toàn thực phẩm',
 'An toàn thực phẩm là vấn đề quan trọng. Người tiêu dùng và nhà nước cần làm gì để đảm bảo điều này?',
 '食の安全性についての問題点と対策を論じてください。', 'general', 'N2', 120, 22),

(sid, 'Thiên tai và sự chuẩn bị',
 'Thiên tai ngày càng nhiều. Cá nhân và cộng đồng cần chuẩn bị như thế nào để đối phó?',
 '自然災害への備えについて個人と社会の役割を論じてください。', 'general', 'N2', 120, 23),

(sid, 'Hiểu biết thông tin (information literacy)',
 'Trong thời đại tin tức giả (fake news), kỹ năng đọc và đánh giá thông tin quan trọng như thế nào?',
 '情報リテラシーの重要性について具体例を挙げながら論じてください。', 'general', 'N2', 120, 24),

(sid, 'Xã hội bền vững',
 'Xã hội bền vững (sustainable society) có nghĩa là gì? Chúng ta cần thay đổi điều gì trong cuộc sống hàng ngày?',
 '持続可能な社会のために私たちができることを論じてください。', 'general', 'N2', 120, 25),

(sid, 'Di dân và xã hội đa văn hóa',
 'Di dân và người nhập cư đang định hình lại nhiều xã hội. Làm thế nào để xây dựng xã hội đa văn hóa hòa thuận?',
 '多文化共生社会の構築について課題と可能性を論じてください。', 'general', 'N2', 120, 26),

(sid, 'Trách nhiệm xã hội của doanh nghiệp',
 'Doanh nghiệp có trách nhiệm gì với xã hội ngoài việc tạo ra lợi nhuận? Hãy phân tích.',
 '企業の社会的責任（CSR）についての意見を述べてください。', 'general', 'N2', 120, 27),

(sid, 'Áp lực của mạng xã hội',
 'Mạng xã hội tạo ra áp lực về ngoại hình, thành công và lối sống. Điều này ảnh hưởng đến sức khỏe tâm thần thế nào?',
 'SNSが精神的健康に与える影響について論じてください。', 'general', 'N2', 120, 28),

(sid, 'Tiếng Nhật trong thế giới hiện đại',
 'Tiếng Nhật có vai trò gì trong thế giới hiện đại? Học tiếng Nhật mang lại lợi thế gì?',
 '現代世界における日本語の役割と魅力について論じてください。', 'general', 'N2', 120, 29),

(sid, 'Định nghĩa thành công',
 'Thành công có nghĩa là gì với bạn? Xã hội định nghĩa thành công như thế nào và bạn có đồng ý không?',
 '「成功」の意味について、社会的定義と自分の考えを比較しながら論じてください。', 'self', 'N2', 120, 30);

-- ============================================================
-- N1 — 30 đề — min_words: 200
-- ============================================================
INSERT INTO writing_prompts (site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, order_index) VALUES
(sid, 'Bản chất của dân chủ',
 'Dân chủ đang đối mặt với những thách thức gì trong thế giới hiện đại? Hãy phân tích bản chất và những mối đe dọa đối với nó.',
 '民主主義の本質と現代における課題について深く論じてください。', 'general', 'N1', 200, 1),

(sid, 'Văn học và bản chất con người',
 'Văn học có thể giúp chúng ta hiểu bản chất con người như thế nào? Hãy lập luận với ví dụ từ tác phẩm bạn đã đọc.',
 '文学が人間の本質を描く意義について、具体的な作品に触れながら論じてください。', 'hobby', 'N1', 200, 2),

(sid, 'Vẻ đẹp và chiều sâu của tiếng Nhật',
 'Tiếng Nhật có những nét đẹp và chiều sâu biểu đạt nào mà ngôn ngữ khác khó có được? Hãy phân tích với ví dụ cụ thể.',
 '日本語の美しさと表現の深みについて、具体例を挙げながら論じてください。', 'general', 'N1', 200, 3),

(sid, 'Hạnh phúc là gì',
 'Hạnh phúc thực sự là gì? Hãy phân tích từ nhiều góc độ triết học, tâm lý học và trải nghiệm cá nhân.',
 '「幸福」とは何か、哲学的・心理学的観点から、また個人的な経験を踏まえて論じてください。', 'self', 'N1', 200, 4),

(sid, 'Bản sắc cá nhân trong xã hội toàn cầu',
 'Toàn cầu hóa khiến ranh giới văn hóa mờ đi. Cá nhân giữ gìn bản sắc của mình như thế nào trong bối cảnh đó?',
 'グローバル社会において個人のアイデンティティをいかに保つか、深く論じてください。', 'self', 'N1', 200, 5),

(sid, 'Công nghệ có cứu được nhân loại không',
 'Liệu công nghệ có thể giải quyết các vấn đề lớn của nhân loại như biến đổi khí hậu, đói nghèo không? Hãy phân tích phê phán.',
 'テクノロジーは人類の問題を解決できるのか、批判的観点から論じてください。', 'general', 'N1', 200, 6),

(sid, 'Đạo đức trong xã hội hiện đại',
 'Các chuẩn mực đạo đức đang thay đổi như thế nào trong xã hội hiện đại? Điều gì là nền tảng bất biến của đạo đức?',
 '現代社会における倫理観の変容と普遍的な道徳の基盤について論じてください。', 'general', 'N1', 200, 7),

(sid, 'Ý nghĩa của nghệ thuật',
 'Nghệ thuật có vai trò gì trong xã hội? Trong thời đại AI có thể tạo ra nghệ thuật, ý nghĩa của sáng tạo nghệ thuật là gì?',
 'AIが芸術を生み出せる時代における芸術の意義と人間の創造性について論じてください。', 'hobby', 'N1', 200, 8),

(sid, 'Ngôn ngữ định hình tư duy',
 'Ngôn ngữ ta nói có ảnh hưởng đến cách ta suy nghĩ và nhận thức thế giới không? Hãy lập luận dựa trên lý thuyết ngôn ngữ học.',
 '言語が思考や世界認識に与える影響について、言語学的知見を踏まえながら論じてください。', 'general', 'N1', 200, 9),

(sid, 'Tăng trưởng kinh tế và hạnh phúc',
 'Liệu tăng trưởng kinh tế có đồng nghĩa với hạnh phúc của xã hội không? Hãy phân tích mối quan hệ phức tạp này.',
 '経済成長と社会の幸福感の関係について多角的に論じてください。', 'general', 'N1', 200, 10),

(sid, 'Xã hội hậu COVID',
 'Đại dịch COVID-19 đã thay đổi xã hội theo những cách căn bản nào? Những thay đổi nào sẽ tồn tại lâu dài?',
 'コロナ禍が社会にもたらした本質的変化と今後への影響について論じてください。', 'general', 'N1', 200, 11),

(sid, 'Gia đình hạt nhân và sự cô lập xã hội',
 'Sự thu nhỏ của gia đình trong xã hội hiện đại có liên quan đến sự cô lập xã hội như thế nào? Hãy phân tích.',
 '核家族化と社会的孤立の関連について構造的に論じてください。', 'family', 'N1', 200, 12),

(sid, 'Năng lực phán đoán trong xã hội thông tin',
 'Trong thế giới tràn ngập thông tin, làm thế nào để phát triển năng lực phán đoán và tư duy phê phán?',
 '情報過多社会において批判的思考力を培うことの意義と方法を論じてください。', 'general', 'N1', 200, 13),

(sid, 'Đồng nhất hóa văn hóa và đa dạng',
 'Toàn cầu hóa đang dẫn đến sự đồng nhất hóa văn hóa. Đây là mối đe dọa hay cơ hội? Hãy phân tích phức tạp.',
 '文化の均質化と多様性の保持という矛盾をどう考えるか、深く論じてください。', 'general', 'N1', 200, 14),

(sid, 'AI và sáng tạo của con người',
 'Khi AI có thể làm thơ, vẽ tranh, soạn nhạc — bản chất sáng tạo của con người là gì? Điều gì phân biệt con người với AI?',
 'AIが創造的行為を行える時代に、人間の創造性の本質と固有性を論じてください。', 'general', 'N1', 200, 15),

(sid, 'Ý nghĩa của "đạo đức" ngày nay',
 '"Đạo đức" trong xã hội hiện đại có ý nghĩa gì? Ai quyết định điều gì là đúng hay sai? Hãy phân tích.',
 '現代における「道徳」の意味と、その権威の根拠について哲学的に論じてください。', 'general', 'N1', 200, 16),

(sid, 'Đạo đức môi trường',
 'Con người có nghĩa vụ đạo đức gì đối với thiên nhiên và các thế hệ tương lai? Hãy phân tích từ góc độ triết học.',
 '環境倫理と人間の自然に対する責任について哲学的観点から論じてください。', 'general', 'N1', 200, 17),

(sid, 'Ý nghĩa của việc học lịch sử',
 'Tại sao học lịch sử lại quan trọng? Lịch sử dạy chúng ta điều gì về hiện tại và tương lai?',
 '歴史から学ぶことの意義と現代・未来への示唆について深く論じてください。', 'general', 'N1', 200, 18),

(sid, 'Ngôn ngữ biến mất và di sản văn hóa',
 'Khi một ngôn ngữ biến mất, điều gì bị mất theo? Tại sao việc bảo tồn ngôn ngữ lại quan trọng?',
 '言語の消滅が文化遺産に与える損失と言語保護の意義について論じてください。', 'general', 'N1', 200, 19),

(sid, 'Khoa học và tôn giáo',
 'Khoa học và tôn giáo có thể đồng tồn không? Họ đặt ra những câu hỏi khác nhau về sự tồn tại như thế nào?',
 '科学と宗教の対話可能性と、両者が問う存在の意味の違いについて論じてください。', 'general', 'N1', 200, 20),

(sid, 'Ý nghĩa thực sự của lao động',
 '"Làm việc" có ý nghĩa gì ngoài việc kiếm tiền? Trong thế giới AI thay thế lao động, con người làm việc để làm gì?',
 '「働くこと」の本質的意味を、AI時代における労働の変容を踏まえながら論じてください。', 'self', 'N1', 200, 21),

(sid, 'Triết học về sự cô đơn',
 'Sự cô đơn và sự ở một mình (solitude) khác nhau như thế nào? Tại sao sự cô đơn có thể là điều cần thiết?',
 '「孤独」と「孤立」の哲学的な違いと、現代における孤独の意義について論じてください。', 'self', 'N1', 200, 22),

(sid, 'Chủ nghĩa dân túy và khủng hoảng dân chủ',
 'Sự trỗi dậy của chủ nghĩa dân túy đang đe dọa các nền dân chủ như thế nào? Nguyên nhân sâu xa là gì?',
 'ポピュリズムの台頭が民主主義に与える脅威と、その根本原因について論じてください。', 'general', 'N1', 200, 23),

(sid, 'Phẩm giá con người và đạo đức',
 'Phẩm giá con người (human dignity) là gì và nó là nền tảng cho đạo đức như thế nào? Phân tích triết học.',
 '人間の尊厳とは何か、そしてそれが倫理の基盤となる根拠について哲学的に論じてください。', 'general', 'N1', 200, 24),

(sid, 'Bất bình đẳng và bình đẳng cơ hội',
 'Xã hội có nghĩa vụ đảm bảo bình đẳng cơ hội không? Sự công bằng thực sự có thể đạt được không?',
 '機会の平等と結果の平等について、正義の観点から深く論じてください。', 'general', 'N1', 200, 25),

(sid, 'Ngôn ngữ và quyền lực',
 'Ngôn ngữ được sử dụng như công cụ quyền lực như thế nào? Ai kiểm soát ngôn ngữ là kiểm soát điều gì?',
 '言語と権力の関係について、政治的・社会的観点から批判的に論じてください。', 'general', 'N1', 200, 26),

(sid, 'Tác phẩm văn học và xã hội',
 'Một tác phẩm văn học vĩ đại có thể thay đổi xã hội như thế nào? Hãy phân tích với ví dụ cụ thể.',
 '偉大な文学作品が社会に与えた影響について、具体的な作品を挙げながら論じてください。', 'hobby', 'N1', 200, 27),

(sid, 'Tương lai của tiếng Nhật',
 'Tiếng Nhật sẽ phát triển hoặc thay đổi như thế nào trong 50 năm tới? Những yếu tố nào sẽ tác động?',
 '日本語の将来について、社会変化や技術進化の観点から多角的に論じてください。', 'general', 'N1', 200, 28),

(sid, 'Tự do ý chí và thuyết tất định',
 'Con người có thực sự có tự do ý chí không, hay tất cả đều được quyết định bởi gen, môi trường và lịch sử? Hãy phân tích.',
 '自由意志と決定論の問題について、科学的・哲学的観点から論じてください。', 'self', 'N1', 200, 29),

(sid, 'Ký ức, bản sắc và sự thật',
 'Ký ức tạo nên bản sắc của chúng ta như thế nào? Khi ký ức sai lệch, bản sắc của chúng ta có thay đổi không?',
 '記憶とアイデンティティの関係について、記憶の信頼性の問題を踏まえながら論じてください。', 'self', 'N1', 200, 30);

END $$;
