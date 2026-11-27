import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/kanji_words.dart';
import '../theme.dart';

/// Một dòng trong danh sách từ vựng chữ Hán.
///
/// ```
/// 家 族        かぞく              ☆
/// GIA TỘC     Gia đình
/// ```
///
/// Từng chữ Hán trong từ bấm được, mở ra trang chữ đó. Nhờ vậy bỏ được tab
/// duyệt 364 chữ riêng mà vẫn tới được mọi thứ ở đó — chữ luôn xuất hiện trong
/// một từ có nghĩa, đúng cách đề thi hỏi.
class KanjiWordRow extends StatelessWidget {
  const KanjiWordRow({super.key, required this.word, required this.onTapChar});

  final KanjiWord word;
  final ValueChanged<String> onTapChar;

  static final _kanji = RegExp(r'[一-鿿]');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final progress = AppScope.of(context).progress;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: c.cardBox(radius: Radii.row),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    _Word(word: word, onTapChar: onTapChar),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        word.kana,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: c.inkSoft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (word.hanViet.isNotEmpty)
                      Text(
                        word.hanViet,
                        style: TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w700,
                          color: c.ai,
                        ),
                      ),
                    Text(
                      word.meaning,
                      style: TextStyle(fontSize: 13, color: c.inkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nghe riêng từng dòng: bấm sao một từ chỉ dựng lại đúng dòng đó,
          // không dựng lại cả 448 dòng.
          ValueListenableBuilder<bool>(
            valueListenable: progress.starListenable(word.id),
            builder: (context, starred, _) => IconButton(
              onPressed: () => progress.toggleStar(word.id),
              tooltip: starred ? 'Bỏ đánh dấu' : 'Đánh dấu cần học lại',
              icon: Icon(
                starred ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: starred ? c.kincha : c.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dạng viết của từ, mỗi chữ Hán là một ô bấm được.
class _Word extends StatelessWidget {
  const _Word({required this.word, required this.onTapChar});

  final KanjiWord word;
  final ValueChanged<String> onTapChar;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // KHÔNG cho mặt chữ phóng theo cỡ chữ hệ thống: đây là hình, không phải
    // chữ đọc. Ở ×2.0 nó đội cả dòng lên và đẩy phần kana ra ngoài.
    return MediaQuery.withNoTextScaling(
      child: Wrap(
        children: [
          for (final ch in word.word.characters)
            if (KanjiWordRow._kanji.hasMatch(ch) &&
                !word.unknownChars.contains(ch))
              InkWell(
                onTap: () => onTapChar(ch),
                borderRadius: BorderRadius.circular(5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    ch,
                    style: TextStyle(
                      fontSize: 21,
                      height: 1.25,
                      color: c.ink,
                      // Gạch chân mờ để biết bấm được. Không dùng màu vì màu
                      // đã dành cho đúng/sai ở chỗ khác.
                      decoration: TextDecoration.underline,
                      decorationColor: c.line,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  ch,
                  style: TextStyle(fontSize: 21, height: 1.25, color: c.ink),
                ),
              ),
        ],
      ),
    );
  }
}
