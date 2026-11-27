import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/vocabulary.dart';
import '../theme.dart';

/// Kết quả chọn: hoặc một tập bài, hoặc "những từ cần học lại".
///
/// "Cần học lại" là MỘT LỰA CHỌN trong cùng bộ chọn này chứ không phải nút
/// riêng ở đâu khác: với người học nó cũng chỉ là một phạm vi để luyện, ngang
/// hàng với "Bài 4". Tách ra thành cửa vào thứ hai là bắt nhớ thêm một chỗ.
sealed class LessonPick {
  const LessonPick();
}

class PickLessons extends LessonPick {
  const PickLessons(this.lessons);
  final Set<int> lessons;
}

class PickStarred extends LessonPick {
  const PickStarred();
}

/// Bộ chọn bài. Chọn nhiều là mặc định, không có chế độ "custom" riêng —
/// chọn một bài chỉ là trường hợp đặc biệt của chọn nhiều, bớt được một khái
/// niệm phải nhớ.
///
/// Trả về `null` nếu anh đóng mà không chọn gì.
/// [allowStarred] bật hàng "Cần học lại". Chỉ bật ở chỗ luyện TỪ VỰNG — phần
/// ngữ pháp và luyện dịch chạy trên câu ví dụ, không có khái niệm đánh dấu từ,
/// bày ra đó là một lựa chọn bấm vào chẳng có gì.
Future<LessonPick?> showLessonPicker(
  BuildContext context, {
  required Set<int> initial,
  bool allowStarred = false,
}) {
  return showModalBottomSheet<LessonPick>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LessonPicker(initial: initial, allowStarred: allowStarred),
  );
}

class _LessonPicker extends StatefulWidget {
  const _LessonPicker({required this.initial, required this.allowStarred});
  final Set<int> initial;
  final bool allowStarred;

  @override
  State<_LessonPicker> createState() => _LessonPickerState();
}

class _LessonPickerState extends State<_LessonPicker> {
  late final Set<int> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lessons = AppScope.of(context).vocabulary.lessons;
    final total = lessons
        .where((l) => _selected.contains(l.number))
        .fold(0, (sum, l) => sum + l.count);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: c.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'CHỌN BÀI ĐỂ LUYỆN TẬP',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: c.inkFaint,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              // +1 cho hàng "Cần học lại" đứng đầu. Nó là một phạm vi luyện
              // tập như mọi bài khác, chỉ khác là do anh tự gom.
              itemCount: lessons.length + (widget.allowStarred ? 1 : 0),
              itemExtent: 64,
              itemBuilder: (context, i) {
                if (!widget.allowStarred) return _row(c, lessons[i]);
                return i == 0 ? _starredRow(c) : _row(c, lessons[i - 1]);
              },
            ),
          ),
          _footer(c, total),
        ],
      ),
    );
  }

  /// Hàng "Cần học lại" — chọn nó là đi luôn, không cộng dồn với các bài.
  ///
  /// Không cho trộn với bài khác: gộp vào thì không còn biết mình đang ôn từ
  /// đã đánh dấu hay đang học bài mới, mà hai việc đó khác hẳn nhau.
  Widget _starredRow(Palette c) {
    final n = AppScope.of(context).progress.starredCount;
    final enabled = n > 0;
    return GestureDetector(
      onTap: enabled ? () => Navigator.pop(context, const PickStarred()) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: c.kinchaWash,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, size: 19, color: c.kincha),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cần học lại',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.kincha,
                      ),
                    ),
                    Text(
                      enabled ? 'Từ đã đánh dấu' : 'Chưa đánh dấu từ nào',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: c.inkFaint),
                    ),
                  ],
                ),
              ),
              Text(
                '$n từ',
                style: TextStyle(fontSize: 11.5, color: c.inkFaint),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right_rounded, size: 20, color: c.kincha),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(Palette c, Lesson lesson) {
    final on = _selected.contains(lesson.number);
    return GestureDetector(
      onTap: () => setState(() {
        on ? _selected.remove(lesson.number) : _selected.add(lesson.number);
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: on ? c.aiWash : c.paper,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lesson.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.ink,
                    ),
                  ),
                  if (lesson.title.isNotEmpty)
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: c.inkFaint),
                    ),
                ],
              ),
            ),
            Text(
              '${lesson.count} từ',
              style: TextStyle(fontSize: 11.5, color: c.inkFaint),
            ),
            const SizedBox(width: 12),
            _check(c, on),
          ],
        ),
      ),
    );
  }

  Widget _check(Palette c, bool on) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: on ? c.ai : Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: on ? c.ai : c.line, width: 1.5),
    ),
    child: on
        ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
        : null,
  );

  Widget _footer(Palette c, int total) {
    final lessons = AppScope.of(context).vocabulary.lessons;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        children: [
          FilledButton(
            // Đếm sẵn tổng số từ: anh biết mình sắp gánh bao nhiêu trước khi
            // bấm, không bị bất ngờ giữa chừng.
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.pop(context, PickLessons(_selected)),
            child: Text(
              _selected.isEmpty
                  ? 'Chưa chọn bài nào'
                  : 'Luyện tập ${_selected.length} bài · $total từ',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              if (_selected.length == lessons.length) {
                _selected.clear();
              } else {
                _selected
                  ..clear()
                  ..addAll(lessons.map((l) => l.number));
              }
            }),
            style: TextButton.styleFrom(foregroundColor: c.inkSoft),
            child: Text(
              _selected.length == lessons.length
                  ? 'Bỏ chọn tất cả'
                  : 'Chọn tất cả ${lessons.length} bài',
            ),
          ),
        ],
      ),
    );
  }
}
