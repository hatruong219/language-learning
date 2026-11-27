import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/vocabulary.dart';
import '../theme.dart';
import 'home_screen.dart' show HomeFilter;
import 'star_feedback.dart';
import 'word_row.dart';

/// Danh sách dựng theo yêu cầu — chỉ tạo những dòng đang lọt trong màn hình.
/// Nhánh "Tất cả" có 2090 dòng, dựng hết một lượt là treo vài giây khi mở màn.
class WordList extends StatelessWidget {
  const WordList({
    super.key,
    required this.words,
    required this.revealAll,
    required this.alwaysRevealed,
    this.highlight,
  });

  final List<Word> words;
  final ValueNotifier<bool> revealAll;
  final String? highlight;
  final bool alwaysRevealed;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: words.length,
      itemExtent: rowExtent,
      itemBuilder: (context, i) {
        final w = words[i];
        return WordRow(
          // Khoá cố định theo mã từ: cuộn qua cuộn lại không bị nhầm trạng
          // thái ẩn/hiện sang dòng khác.
          key: ValueKey(w.id),
          word: w,
          revealAll: revealAll,
          starred: scope.progress.starListenable(w.id),
          alwaysRevealed: alwaysRevealed,
          highlight: highlight,
          subtitle: highlight != null ? 'Bài ${w.lesson} · ${w.posVi}' : null,
          onSpeak: () =>
              scope.speech.speak(w.reading, rate: scope.settings.speechRate),
          onToggleStar: () => toggleStarWithFeedback(context, w),
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 15, color: c.ink),
      decoration: InputDecoration(
        hintText: 'Tìm nghĩa, kana hoặc romaji',
        hintStyle: TextStyle(fontSize: 15, color: c.inkFaint),
        prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.inkFaint),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.cancel_rounded, size: 18, color: c.inkFaint),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: c.sunken,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.filter,
    required this.lessons,
    required this.count,
    required this.onSelect,
  });

  final HomeFilter filter;
  final Set<int> lessons;
  final int count;
  final ValueChanged<HomeFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lessonLabel = lessons.isEmpty
        ? 'Theo bài'
        : (lessons.length <= 2
              ? lessons.map((n) => 'Bài $n').join(' · ')
              : '${lessons.length} bài');

    // Ba nhánh chia đều bề ngang thay vì cuộn ngang. Cuộn ngang thì nhánh thứ
    // ba bị đẩy khuất mép phải trên màn 390px — có ở đó mà không bấm được.
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _chip(
                  c,
                  'Cần học lại',
                  filter == HomeFilter.starred,
                  () => onSelect(HomeFilter.starred),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _chip(
                  c,
                  lessonLabel,
                  filter == HomeFilter.byLesson,
                  () => onSelect(HomeFilter.byLesson),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _chip(
                  c,
                  'Tất cả',
                  filter == HomeFilter.all,
                  () => onSelect(HomeFilter.all),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('$count', style: TextStyle(fontSize: 12, color: c.inkFaint)),
      ],
    );
  }

  Widget _chip(Palette c, String label, bool on, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: on ? c.card : c.sunken,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: on ? c.line : Colors.transparent),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on ? c.ink : c.inkSoft,
            ),
          ),
        ),
      );
}
