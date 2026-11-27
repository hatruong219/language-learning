import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'grammar_tabs.dart';
import 'home_screen.dart';
import 'kanji_tabs.dart';
import 'motion.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'storage_banner.dart';

/// Năm tab dưới đáy: Trang chủ · Luyện tập · Kanji · Ngữ pháp · Cài đặt.
///
/// Cài đặt luôn nằm cuối. Chỉ số tab đổi khi chèn thêm, nên mọi nơi gọi
/// `goTo` dùng hằng số bên dưới thay vì số trần.
class RootTabs extends StatefulWidget {
  const RootTabs({super.key});

  /// Chỉ số các tab. Đặt tên để chỗ gọi không phải viết số trần — chèn tab
  /// Kanji vào giữa là chỉ sửa ở đây.
  static const int tabHome = 0;
  static const int tabPractice = 1;
  static const int tabKanji = 2;
  static const int tabGrammar = 3;
  static const int tabSettings = 4;

  /// Cho phép màn trạng thái trống nhảy thẳng sang tab Luyện tập.
  static void goTo(BuildContext context, int index) =>
      context.findAncestorStateOfType<_RootTabsState>()?._select(index);

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _index = 0;

  // Giữ nguyên trạng thái từng tab khi chuyển qua lại — đang cuộn giữa danh
  // sách mà quay lại thấy nhảy về đầu thì rất khó chịu.
  final _pages = const [
    HomeScreen(),
    QuizScreen(),
    KanjiTabs(),
    GrammarTabs(),
    SettingsScreen(),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: StorageBanner(
        persistent: AppScope.of(context).progress.persistent,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: DecoratedBox(
        // Vạch mảnh + bóng loang ngược lên: thanh tab "nổi" trên nội dung
        // thay vì bị kẻ cứng một đường.
        decoration: BoxDecoration(
          color: c.card,
          border: Border(top: BorderSide(color: c.edge)),
          boxShadow: [
            BoxShadow(
              color: c.raise.last.color,
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        // Kẹp cỡ chữ NHÃN TAB ở ×1.3, không để nó theo hệ thống.
        //
        // Năm tab thì mỗi nhãn chỉ còn một phần năm bề rộng. Ở iPhone SE
        // cỡ chữ ×2.0 nhãn "Trang chủ" bị cắt mất chữ, và bản release cắt âm
        // thầm nên nhìn như lỗi hiển thị. Kẹp ở đây chứ không kẹp cả app: phần
        // nội dung vẫn phải phóng to được cho người cần.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: _select,
            items: const [
              BottomNavigationBarItem(
                icon: _TabIcon(Icons.home_outlined),
                activeIcon: _TabIcon(Icons.home_rounded, active: true),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(Icons.school_outlined),
                activeIcon: _TabIcon(Icons.school_rounded, active: true),
                label: 'Luyện tập',
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(Icons.brush_outlined),
                activeIcon: _TabIcon(Icons.brush_rounded, active: true),
                label: 'Kanji',
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(Icons.menu_book_outlined),
                activeIcon: _TabIcon(Icons.menu_book_rounded, active: true),
                label: 'Ngữ pháp',
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(Icons.settings_outlined),
                activeIcon: _TabIcon(Icons.settings_rounded, active: true),
                label: 'Cài đặt',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon tab. Tab đang chọn có viên nền chàm nhạt phía sau — dấu chọn rõ hơn
/// chỉ đổi màu icon, nhất là với người nhìn màu kém.
///
/// Cả hai trạng thái cùng kích thước viên để đổi tab không làm nhãn nhảy.
class _TabIcon extends StatelessWidget {
  const _TabIcon(this.icon, {this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.quick),
      curve: Motion.ease,
      width: 52,
      height: 30,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: active ? c.aiWash : c.aiWash.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 22),
    );
  }
}
