import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/vocabulary.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';

/// Màn chấm điểm.
///
/// Không có nút "tôi đọc đúng mà": ở chế độ đọc, anh đã xem và xác nhận chữ ở
/// bước trước rồi, nên sai ở đây là sai thật — không còn chuyện oan để mà kêu.
class QuizVerdictPanel extends StatelessWidget {
  const QuizVerdictPanel({
    super.key,
    required this.item,
    required this.onNext,
    required this.onClose,
  });

  final QuizItem item;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    final ok = item.state == AnswerState.correct;
    final word = item.word;
    final alsoRead = scope.vocabulary.homophonesOf(word);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ok ? c.matchaWash : c.shuWash,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                // "Chưa khớp" chứ không phải "Sai" — nhẹ hơn, và đúng hơn về
                // mặt sự việc: đó chỉ là hai chuỗi không trùng nhau.
                ok ? 'ĐÚNG' : 'CHƯA KHỚP',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: ok ? c.matcha : c.shu,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.reading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                word.romaji,
                style: TextStyle(fontSize: 14, color: c.inkSoft),
              ),
              if (!ok && item.submitted.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(color: c.line, height: 1),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Đã nhập: ',
                        style: TextStyle(fontSize: 13, color: c.inkSoft),
                      ),
                      TextSpan(
                        text: item.submitted,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.shu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (alsoRead.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AlsoRead(words: alsoRead),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StarButton(wordId: word.id)),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => scope.speech.speak(
                  word.reading,
                  rate: scope.settings.speechRate,
                ),
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                label: Text(ok ? 'Nghe lại' : 'Nghe mẫu'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: BorderSide(color: c.line),
                  foregroundColor: c.inkSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: onNext, child: const Text('Từ tiếp theo →')),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onClose,
          style: TextButton.styleFrom(foregroundColor: c.inkFaint),
          child: const Text('Dừng phiên, xem tổng kết'),
        ),
      ],
    );
  }
}

/// Vì app không hiện kanji nên あつい (nóng thời tiết) và あつい (nóng đồ vật)
/// nhìn y hệt nhau. Nói rõ ra, kẻo anh tưởng app hỏi lặp.
class _AlsoRead extends StatelessWidget {
  const _AlsoRead({required this.words});
  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(
      'Cũng đọc là: ${words.map((w) => w.meaning).join(' · ')}',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12.5, height: 1.4, color: c.inkFaint),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.wordId});
  final String wordId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    return ValueListenableBuilder<bool>(
      valueListenable: scope.progress.starListenable(wordId),
      builder: (context, starred, _) => FilledButton.icon(
        onPressed: () => scope.progress.toggleStar(wordId),
        icon: Icon(
          starred ? Icons.star_rounded : Icons.star_border_rounded,
          size: 19,
        ),
        label: Text(starred ? 'Đã đánh dấu' : 'Cần học lại'),
        style: FilledButton.styleFrom(
          backgroundColor: starred ? c.kincha : c.kinchaWash,
          foregroundColor: starred ? Colors.white : c.kincha,
          minimumSize: const Size.fromHeight(46),
          textStyle: const TextStyle(
            fontFamily: bundledFontFamily,
            fontFamilyFallback: bundledFontFallback,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
