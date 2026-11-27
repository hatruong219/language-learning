import 'package:flutter/material.dart';

import '../theme.dart';
import 'glyph_badge.dart';
import 'motion.dart';
import 'home_screen.dart' show HomeFilter;

/// Trạng thái trống của Trang chủ.
///
/// Đây là màn hình đầu tiên anh thấy sau khi cài app — chưa đánh dấu từ nào thì
/// danh sách rỗng. Nên nó phải làm được việc: giải thích tính năng và có lối ra,
/// chứ không phải một trang trắng.
class HomeEmpty extends StatelessWidget {
  const HomeEmpty({
    super.key,
    required this.searching,
    required this.filter,
    required this.onStartQuiz,
    required this.onBrowseLessons,
  });

  final bool searching;
  final HomeFilter filter;
  final VoidCallback onStartQuiz;
  final VoidCallback onBrowseLessons;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    if (searching) {
      return _Frame(
        glyph: '無',
        title: 'Không tìm thấy từ nào',
        body:
            'Thử rút ngắn từ khoá, hoặc nhập bằng kana. '
            'Tìm được cả nghĩa tiếng Việt, kana và romaji.',
        c: c,
      );
    }

    if (filter == HomeFilter.byLesson) {
      return _Frame(
        glyph: '選',
        title: 'Chưa chọn bài nào',
        body: 'Chọn một hoặc nhiều bài để xem danh sách từ của bài đó.',
        c: c,
        primary: ('Chọn bài', onBrowseLessons),
      );
    }

    return _Frame(
      glyph: '空',
      title: 'Chưa có từ nào ở đây',
      body:
          'Khi luyện tập, nhấn dấu sao ở từ khó nhớ — '
          'từ đó sẽ nằm lại đây để ôn lại sau.',
      c: c,
      primary: ('Bắt đầu luyện tập', onStartQuiz),
      secondary: ('Duyệt từ vựng theo bài', onBrowseLessons),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.glyph,
    required this.title,
    required this.body,
    required this.c,
    this.primary,
    this.secondary,
  });

  final String glyph, title, body;
  final Palette c;
  final (String, VoidCallback)? primary, secondary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 56, 30, 30),
      // Khoá theo chữ minh hoạ: đổi bộ lọc sang trạng thái trống khác thì
      // khối hiện ra lại, không đứng im đổi chữ.
      child: EnterFadeSlide(
        key: ValueKey(glyph),
        child: Column(
          children: [
            // Một chữ kanji thay cho hình minh hoạ — hợp với app học tiếng Nhật
            // hơn là cái icon hộp rỗng chung chung.
            GlyphBadge(glyph),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, height: 1.5, color: c.inkFaint),
            ),
            const SizedBox(height: 22),
            if (primary != null)
              FilledButton(onPressed: primary!.$2, child: Text(primary!.$1)),
            if (secondary != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: secondary!.$2,
                child: Text(secondary!.$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
