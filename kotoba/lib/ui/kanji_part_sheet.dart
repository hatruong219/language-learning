import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/kanji.dart';
import '../theme.dart';
import 'kanji_glyph.dart';

/// Tấm nền chi tiết một mảnh cấu tạo: tên, nghĩa, và những chữ có chứa nó.
///
/// Là một route của Navigator bên trong MaterialApp, nên tra được AppScope —
/// AppScope nằm TRÊN MaterialApp chính vì lý do này. Đặt nó dưới `home:` thì mọi
/// tấm nền không thấy AppScope và dấu `!` nổ ngay khi mở, đúng lỗi đã làm sập
/// máy thật một lần.
Future<void> showKanjiPartSheet(BuildContext context, KanjiPart part) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PartSheet(part: part),
    );

class _PartSheet extends StatelessWidget {
  const _PartSheet({required this.part});
  final KanjiPart part;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    final contains = scope.kanji.kanjiContaining(part.char);

    return SafeArea(
      // Cao tối đa 82% màn hình rồi cuộn bên trong: mảnh 一 có 66 chữ, để tấm
      // nền tự giãn theo nội dung thì nó cao quá màn và bị cắt mất phần dưới.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _head(c),
            const Divider(height: 1),
            Expanded(child: _body(c, contains)),
          ],
        ),
      ),
    );
  }

  Widget _head(Palette c) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
    child: Row(
      children: [
        KanjiGlyph(char: part.char, size: 40, box: 68, highlight: part.inSet),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                part.hanViet.isEmpty ? 'Không có tên' : part.hanVietLabel,
                style: TextStyle(
                  fontSize: 21,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: part.hanViet.isEmpty ? c.inkFaint : c.ink,
                ),
              ),
              const SizedBox(height: 5),
              _meaning(),
              if (part.radicalStrokes != null && part.radicalStrokes! > 0) ...[
                const SizedBox(height: 5),
                Text(
                  '${part.radicalStrokes} nét'
                  '${part.radicalOf == null ? '' : ' · dạng của bộ ${part.radicalOf}'}',
                  style: TextStyle(fontSize: 12, color: c.inkFaint),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  Widget _meaning() {
    if (part.meaningVi != null) {
      return MeaningText(kind: MeaningKind.present, text: part.meaningVi);
    }
    if (part.isShape) {
      return const MeaningText(
        kind: MeaningKind.stated,
        text: 'Ký hiệu hình, không phải chữ Hán',
      );
    }
    if (part.hanViet.isNotEmpty) {
      return const MeaningText(
        kind: MeaningKind.stated,
        text: 'Bộ thủ này không mang nghĩa',
      );
    }
    return const MeaningText(kind: MeaningKind.missing);
  }

  Widget _body(Palette c, List<Kanji> contains) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
    children: [
      if (part.meaningClassic != null) ...[
        _label(c, 'TỪ NGUYÊN'),
        const SizedBox(height: 5),
        // Nghĩa Hán cổ nằm ở khối RIÊNG, không trộn vào ô nghĩa: nó đúng với
        // chữ Hán cổ nhưng lệch tiếng Nhật, nên đặt vào ô "nghĩa" là dạy sai.
        Text(
          part.meaningClassic!,
          style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.45),
        ),
        const SizedBox(height: 18),
      ],
      _label(c, '${contains.length} CHỮ CÓ MẢNH NÀY'),
      const SizedBox(height: 4),
      Text(
        'Biết mảnh này chưa đủ để đọc hết chúng — mỗi chữ còn cần các mảnh khác.',
        style: TextStyle(fontSize: 12, color: c.inkFaint, height: 1.35),
      ),
      const SizedBox(height: 10),
      if (contains.isEmpty)
        Text(
          'Không có chữ nào trong bộ chứa mảnh này.',
          style: TextStyle(fontSize: 13, color: c.inkFaint),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in contains)
              KanjiGlyph(
                key: ValueKey('has-${k.char}'),
                char: k.char,
                size: 24,
                box: 44,
              ),
          ],
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
