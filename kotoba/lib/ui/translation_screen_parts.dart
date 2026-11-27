import 'package:flutter/material.dart';

import '../data/grammar.dart';
import '../quiz/translation_check.dart';
import '../theme.dart';
import 'quiz_progress_bar.dart';
import 'translation_parts.dart';

class TranslationIntro extends StatelessWidget {
  const TranslationIntro({
    super.key,
    required this.lessons,
    required this.onPick,
    required this.onStart,
  });
  final Set<int> lessons;
  final VoidCallback onPick;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Text(
          'Luyện dịch Việt → Nhật',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Gõ kanji hay gõ toàn kana đều được tính đúng — 私は学生です và '
          'わたしはがくせいです là cùng một câu. Sai thì hiện đối chiếu từng đoạn: '
          'thiếu gì, thừa gì.',
          style: TextStyle(fontSize: 13, color: c.inkSoft, height: 1.45),
        ),
        const SizedBox(height: 22),
        const QuizFieldLabel('PHẠM VI'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(
            lessons.isEmpty ? 'Tất cả các bài' : '${lessons.length} bài',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: BorderSide(color: c.line),
            foregroundColor: c.ink,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onStart, child: const Text('Bắt đầu · 10 câu')),
      ],
    );
  }
}

class TranslationRunner extends StatelessWidget {
  const TranslationRunner({
    super.key,
    required this.sentence,
    required this.controller,
    required this.result,
    required this.done,
    required this.total,
    required this.onCheck,
    required this.onNext,
    required this.onQuit,
  });

  final Sentence sentence;
  final TextEditingController controller;
  final TranslationResult? result;
  final int done;
  final int total;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = result;

    return Column(
      children: [
        QuizProgressBar(done: done, total: total, onQuit: onQuit),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DỊCH SANG TIẾNG NHẬT',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: c.inkFaint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sentence.vi,
                      style: TextStyle(fontSize: 16, height: 1.5, color: c.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                enabled: r == null,
                autofocus: true,
                maxLines: 2,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => r == null ? onCheck() : onNext(),
                style: const TextStyle(fontSize: 17, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Gõ câu tiếng Nhật…',
                  filled: true,
                  fillColor: c.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.line),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (r == null)
                FilledButton(onPressed: onCheck, child: const Text('Kiểm tra'))
              else ...[
                _Verdict(result: r),
                const SizedBox(height: 10),
                if (!r.correct) ...[
                  DiffView(result: r),
                  const SizedBox(height: 10),
                ],
                TranslationAnswer(
                  kanji: sentence.jaKanji,
                  kana: sentence.jaKana,
                  showKana: sentence.hasFurigana,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onNext,
                  child: Text(
                    done + 1 >= total ? 'Xem kết quả' : 'Câu tiếp theo →',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.result});
  final TranslationResult result;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (text, color) = result.correct
        ? ('Đúng rồi', c.matcha)
        // "Gần đúng" không phải lời an ủi: sai một trợ từ khác hẳn sai cả câu,
        // và người học cần biết mình đang ở đâu giữa hai thứ đó.
        : result.close
        ? ('Gần đúng — còn sót vài chỗ', c.kincha)
        : ('Chưa khớp', c.shu);
    return Row(
      children: [
        Icon(
          result.correct ? Icons.check_circle_rounded : Icons.info_rounded,
          size: 19,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class TranslationDone extends StatelessWidget {
  const TranslationDone({
    super.key,
    required this.correct,
    required this.total,
    required this.onAgain,
    required this.onDone,
  });

  final int correct;
  final int total;
  final VoidCallback onAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
      children: [
        Text(
          'Đúng $correct / $total câu',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(onPressed: onAgain, child: const Text('Làm phiên mới')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onDone,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: BorderSide(color: c.line),
            foregroundColor: c.inkSoft,
          ),
          child: const Text('Xong'),
        ),
      ],
    );
  }
}
