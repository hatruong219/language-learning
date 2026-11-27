import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'kanji_detail_sheet.dart';
import 'kanji_word_row.dart';
import 'quiz_progress_bar.dart';

/// Danh sách 448 từ vựng chữ Hán, theo đúng thứ tự PDF.
///
/// Không chia cấp, không chia chặng. PDF xếp theo chủ đề — gia đình, công việc,
/// địa danh — và học theo cụm nghĩa liên quan nhớ tốt hơn học theo cấp độ.
/// Chia cấp thì phải bịa, vì PDF gần như không có từ N5 (xem kanji_words.dart).
class KanjiWordList extends StatefulWidget {
  const KanjiWordList({super.key});

  @override
  State<KanjiWordList> createState() => _KanjiWordListState();
}

class _KanjiWordListState extends State<KanjiWordList> {
  final _search = TextEditingController();
  String _query = '';

  /// Chỉ hiện từ ghép từ 2 chữ trở lên.
  ///
  /// Đề thi hỏi kanji TRONG TỪ, mà từ ghép mới là chỗ dễ nhầm cách đọc —
  /// 生 trong 学生 đọc せい, trong 生まれる đọc う. Lọc riêng ra để luyện.
  bool _onlyCompound = false;

  /// Cấp độ đang lọc. Rỗng = tất cả.
  ///
  /// Danh sách cấp KHÔNG viết cứng — lấy từ [KanjiWordSet.levels], vốn gom từ
  /// dữ liệu. Hiện database ghi hết là N4 nên chỉ có một nút; hôm nào phân lại
  /// cấp rồi đồng bộ thì app tự có thêm nút, không phải sửa mã.
  String _level = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final set = scope.kanjiWords;

    var rows = set.search(_query);
    if (_level.isNotEmpty) {
      rows = rows.where((w) => w.level == _level).toList();
    }
    if (_onlyCompound) {
      rows = rows.where((w) => w.isCompound).toList();
    }

    return Column(
      children: [
        _Toolbar(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          onlyCompound: _onlyCompound,
          onCompound: (v) => setState(() => _onlyCompound = v),
          levels: set.levels,
          level: _level,
          onLevel: (v) => setState(() => _level = v),
          shown: rows.length,
          total: set.words.length,
        ),
        Expanded(
          child: rows.isEmpty
              ? const _NoResult()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: rows.length,
                  itemBuilder: (context, i) => KanjiWordRow(
                    key: ValueKey(rows[i].id),
                    word: rows[i],
                    // Bấm vào một chữ trong từ thì mở trang chữ đó — âm on/kun,
                    // số nét, mảnh cấu tạo, các từ khác chứa nó. Nhờ vậy bỏ tab
                    // duyệt chữ riêng mà không mất gì.
                    onTapChar: (c) {
                      final k = scope.kanji.set.byChar(c);
                      if (k != null) showKanjiDetailSheet(context, k);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.onChanged,
    required this.onlyCompound,
    required this.onCompound,
    required this.levels,
    required this.level,
    required this.onLevel,
    required this.shown,
    required this.total,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool onlyCompound;
  final ValueChanged<bool> onCompound;

  /// Các cấp CÓ THẬT trong dữ liệu. Chỉ một cấp thì khỏi hiện hàng lọc — một
  /// nút luôn bật thì không phải lựa chọn, chỉ tổ chiếm chỗ.
  final List<String> levels;
  final String level;
  final ValueChanged<String> onLevel;

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Tìm chữ, cách đọc, âm Hán-Việt, hoặc nghĩa',
              hintStyle: TextStyle(fontSize: 13.5, color: c.inkFaint),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: c.inkFaint,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
              // Cùng kiểu ô tìm ở Trang chủ: nền trũng, không viền, viền chàm
              // khi đang gõ. Hai ô tìm hai kiểu thì nhìn như hai app ghép lại.
              filled: true,
              fillColor: c.sunken,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.control),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.control),
                borderSide: BorderSide(color: c.ai.withValues(alpha: 0.6)),
              ),
            ),
          ),
          if (levels.length > 1) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuizChip(
                    label: 'Tất cả',
                    on: level.isEmpty,
                    onTap: () => onLevel(''),
                  ),
                  for (final l in levels) ...[
                    const SizedBox(width: 8),
                    QuizChip(label: l, on: level == l, onTap: () => onLevel(l)),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  shown == total ? '$total từ' : '$shown / $total từ',
                  style: TextStyle(fontSize: 12.5, color: c.inkFaint),
                ),
              ),
              Flexible(
                child: Text(
                  'Chỉ từ ghép',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12.5, color: c.inkSoft),
                ),
              ),
              const SizedBox(width: 4),
              Switch.adaptive(value: onlyCompound, onChanged: onCompound),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Không tìm thấy từ nào',
          style: TextStyle(fontSize: 14, color: c.inkFaint),
        ),
      ),
    );
  }
}
