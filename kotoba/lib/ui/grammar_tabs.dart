import 'package:flutter/material.dart';

import '../theme.dart';
import 'grammar_lesson_list.dart';
import 'grammar_quiz_screen.dart';
import 'translation_screen.dart';

/// Tab Ngữ pháp với ba mục con: Bài học · Bài tập · Luyện dịch.
///
/// Ba tab con cuộn ngang được, cùng lý do như tab Kanji: ở iPhone SE cỡ chữ
/// ×2.0 ba nhãn này tràn nếu chia đều chiều rộng, mà bản phát hành cắt phần
/// tràn âm thầm — không vạch vàng, không lỗi, chỉ mất chữ.
class GrammarTabs extends StatelessWidget {
  const GrammarTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Text('Ngữ pháp'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: c.ai,
            unselectedLabelColor: c.inkFaint,
            indicatorColor: c.ai,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: c.line,
            labelStyle: const TextStyle(
              fontFamily: bundledFontFamily,
              fontFamilyFallback: bundledFontFallback,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: bundledFontFamily,
              fontFamilyFallback: bundledFontFallback,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Bài học'),
              Tab(text: 'Bài tập'),
              Tab(text: 'Luyện dịch'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GrammarLessonList(),
            GrammarQuizScreen(),
            TranslationScreen(),
          ],
        ),
      ),
    );
  }
}
