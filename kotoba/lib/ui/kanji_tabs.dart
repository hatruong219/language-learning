import 'package:flutter/material.dart';

import '../theme.dart';
import 'kanji_quiz_screen.dart';
import 'kanji_word_list.dart';

/// Tab Kanji với hai mục con: Từ vựng · Kiểm tra.
///
/// Trước đây có ba mục — Thành phần (181 mảnh cấu tạo) và Chữ Hán (364 chữ
/// đơn) đứng trước Kiểm tra. Bỏ cả hai vì chúng bày chữ ĐỨNG TRƠ, trong khi
/// đề thi luôn hỏi kanji TRONG MỘT TỪ. Học chữ rời rồi mới ghép lại là đi
/// ngược cách thi, và cũng ngược cách người ta học thật.
///
/// Không mất gì: bấm vào một chữ bất kỳ trong từ là mở đúng trang chữ đó —
/// âm on/kun, số nét, mảnh cấu tạo, các từ khác chứa nó. Bộ thủ trở thành
/// công cụ TRA CỨU khi cần phân biệt chữ nhìn giống nhau, không còn là chặng
/// bắt buộc phải qua trước.
///
/// Vẫn để `isScrollable`: ở cỡ chữ ×2.0 trên máy nhỏ hai nhãn cũng có thể
/// tràn, mà bản phát hành cắt phần tràn âm thầm — mất chữ chứ không báo lỗi.
class KanjiTabs extends StatelessWidget {
  const KanjiTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Text('Kanji'),
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
              Tab(text: 'Từ vựng'),
              Tab(text: 'Kiểm tra'),
            ],
          ),
        ),
        body: const TabBarView(children: [KanjiWordList(), KanjiQuizScreen()]),
      ),
    );
  }
}
