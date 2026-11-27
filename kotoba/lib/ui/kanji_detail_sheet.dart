import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/kanji.dart';
import '../data/vocabulary.dart';
import '../theme.dart';
import 'kanji_glyph.dart';
import 'kanji_part_sheet.dart';
import 'star_feedback.dart';
import 'word_row.dart';

/// Tấm nền chi tiết một chữ Hán.
Future<void> showKanjiDetailSheet(BuildContext context, Kanji kanji) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _DetailSheet(kanji: kanji),
    );

/// Danh sách từ trong tấm nền luôn hiện chữ — không có gì để che ở đây.
final ValueNotifier<bool> _alwaysOn = ValueNotifier(true);

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.kanji});
  final Kanji kanji;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final words = scope.kanji.wordsFor(kanji.char);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Head(kanji: kanji),
            const Divider(height: 1),
            Expanded(
              child: _Body(kanji: kanji, words: words),
            ),
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.kanji});
  final Kanji kanji;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanjiGlyph(char: kanji.char, size: 46, box: 78),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      kanji.hanVietLabel,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    KindTag(label: kanji.level, emphasise: true),
                    // Nói thật khi cấp thi thực tế cao hơn thang học. 133/364
                    // chữ ở diện này — người học có quyền biết chữ nào chưa ra
                    // ở N4 để không lo hão.
                    if (kanji.beyondN4)
                      KindTag(label: 'đề thi: ${kanji.levelRef}'),
                  ],
                ),
                const SizedBox(height: 6),
                MeaningText(
                  kind: kanji.meaningVi == null
                      ? MeaningKind.missing
                      : MeaningKind.present,
                  text: kanji.meaningVi,
                ),
                const SizedBox(height: 6),
                Text(
                  '${kanji.strokes} nét'
                  '${kanji.kyujitai == null ? '' : ' · tự dạng cũ ${kanji.kyujitai}'}',
                  style: TextStyle(fontSize: 12, color: c.inkFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.kanji, required this.words});
  final Kanji kanji;
  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      children: [
        if (kanji.on.isNotEmpty || kanji.kun.isNotEmpty) ...[
          _readings(c),
          const SizedBox(height: 18),
        ],
        if (kanji.parts.isNotEmpty) ...[
          _label(c, 'GHÉP TỪ ${kanji.parts.length} MẢNH'),
          const SizedBox(height: 8),
          _parts(context, scope),
          const SizedBox(height: 18),
        ],
        if (kanji.meaningClassic != null) ...[
          _label(c, 'TỪ NGUYÊN'),
          const SizedBox(height: 5),
          // Khối RIÊNG, không trộn vào ô nghĩa: nghĩa Hán cổ đúng với chữ Hán
          // nhưng lệch tiếng Nhật — cụ Thiều Chửu ghi 学 "Bắt chước", 時 "Mùa".
          Text(
            kanji.meaningClassic!,
            style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.45),
          ),
          const SizedBox(height: 18),
        ],
        _label(
          c,
          words.isEmpty ? 'CHƯA CÓ TỪ NÀO' : '${words.length} TỪ CÓ CHỮ NÀY',
        ),
        const SizedBox(height: 6),
        if (words.isEmpty)
          Text(
            'Giáo trình chưa có từ nào dùng được để ra đề với chữ này, nên nó '
            'không xuất hiện trong phần Kiểm tra. Vẫn học mặt chữ bình thường.',
            style: TextStyle(fontSize: 12.5, color: c.inkFaint, height: 1.4),
          )
        else
          // Dùng lại WordRow: dấu sao ở đây là dấu sao DUY NHẤT của app, khoá
          // theo từ. Không mở thêm không gian sao cho chữ — làm thế là có hai
          // danh sách "Cần học lại" mà quyết định gộp chúng lại đã bác.
          for (final w in words)
            WordRow(
              key: ValueKey('kanji-word-${w.id}'),
              word: w,
              revealAll: _alwaysOn,
              alwaysRevealed: true,
              starred: scope.progress.starListenable(w.id),
              subtitle: 'Bài ${w.lesson}',
              onSpeak: () => scope.speech.speak(
                w.reading,
                rate: scope.settings.speechRate,
              ),
              onToggleStar: () => toggleStarWithFeedback(context, w),
            ),
      ],
    );
  }

  Widget _readings(Palette c) => Wrap(
    spacing: 18,
    runSpacing: 8,
    children: [
      if (kanji.on.isNotEmpty) _readingGroup(c, 'ÂM ON', kanji.on),
      if (kanji.kun.isNotEmpty) _readingGroup(c, 'ÂM KUN', kanji.kun),
    ],
  );

  Widget _readingGroup(Palette c, String label, List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(c, label),
      const SizedBox(height: 3),
      Text(
        items.join('、'),
        style: TextStyle(fontSize: 14, color: c.ink, height: 1.35),
      ),
    ],
  );

  Widget _parts(BuildContext context, AppScope scope) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final p in kanji.parts)
        _PartChip(
          char: p,
          part: scope.kanji.set.partByChar(p),
          onTap: () {
            final found = scope.kanji.set.partByChar(p);
            if (found != null) showKanjiPartSheet(context, found);
          },
        ),
    ],
  );

  Widget _label(Palette c, String text) => Text(
    text,
    style: TextStyle(
      fontSize: 10.5,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w700,
      color: c.inkFaint,
    ),
  );
}

/// Một mảnh trong khối "ghép từ N mảnh" — mặt mảnh kèm tên, bấm được.
///
/// Ghép nghĩa các mảnh lại chính là cách nhớ mặt chữ: 学 là 子 (con) dưới 冖
/// (trùm khăn). Việc này chỉ làm được từ khi mảnh có tên và nghĩa.
class _PartChip extends StatelessWidget {
  const _PartChip({
    required this.char,
    required this.part,
    required this.onTap,
  });

  final String char;
  final KanjiPart? part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final name = part == null || part!.hanViet.isEmpty
        ? null
        : part!.hanVietLabel;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: c.sunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediaQuery.withNoTextScaling(
              child: Text(
                char,
                style: TextStyle(fontSize: 20, height: 1.1, color: c.ink),
              ),
            ),
            if (name != null) ...[
              const SizedBox(width: 7),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: c.inkSoft,
                ),
              ),
              if (part!.meaningVi != null) ...[
                const SizedBox(width: 4),
                Text(
                  part!.meaningVi!,
                  style: TextStyle(fontSize: 11.5, color: c.inkFaint),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
