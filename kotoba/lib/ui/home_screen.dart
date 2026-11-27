import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/progress_store.dart';
import '../data/vocabulary.dart';
import '../theme.dart';
import 'home_empty.dart';
import 'home_widgets.dart';
import 'lesson_picker.dart';
import 'root_tabs.dart';

enum HomeFilter { starred, byLesson, all }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _revealAll = ValueNotifier(false);
  final _searchController = TextEditingController();

  HomeFilter _filter = HomeFilter.starred;
  Set<int> _lessons = {};
  String _query = '';
  Timer? _debounce;

  /// Giữ tham chiếu để gỡ listener trong dispose — lúc đó không tra
  /// InheritedWidget được nữa, Flutter cấm.
  ProgressStore? _progress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Danh sách "cần học lại" đổi khi anh bấm sao ở nơi khác — nghe ở cấp màn
    // hình là đúng, vì lúc đó danh sách thật sự đổi nội dung.
    // Phải ở đây chứ không phải initState: initState chạy trước khi widget
    // gắn vào cây nên chưa tra được AppScope.
    final next = AppScope.of(context).progress;
    if (identical(next, _progress)) return;
    _progress?.removeListener(_onProgressChanged);
    _progress = next..addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    if (mounted && _filter == HomeFilter.starred) setState(() {});
  }

  @override
  void dispose() {
    _progress?.removeListener(_onProgressChanged);
    _debounce?.cancel();
    _revealAll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Chờ 200ms sau phím cuối rồi mới lọc — gõ nhanh không kích hoạt lọc sau
  /// mỗi chữ cái.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = value);
    });
  }

  Future<void> _pickLessons() async {
    final picked = await showLessonPicker(context, initial: _lessons);
    if (picked is PickLessons && mounted) {
      setState(() {
        _lessons = picked.lessons;
        _filter = HomeFilter.byLesson;
      });
    }
  }

  List<Word> _visibleWords(AppScope scope) {
    // Đang tìm thì bỏ qua bộ lọc và quét cả 2090 từ — tìm mà chỉ tìm trong 14
    // từ đã đánh dấu thì vô nghĩa.
    if (_query.trim().isNotEmpty) return scope.vocabulary.search(_query);

    switch (_filter) {
      case HomeFilter.starred:
        return scope.vocabulary.byIds(scope.progress.starredIds);
      case HomeFilter.byLesson:
        return _lessons.isEmpty
            ? const []
            : scope.vocabulary.byLessons(_lessons);
      case HomeFilter.all:
        return scope.vocabulary.words;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    final searching = _query.trim().isNotEmpty;
    final words = _visibleWords(scope);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(searching ? 'Tìm từ' : _titleFor(_filter)),
        actions: [
          if (!searching && words.isNotEmpty)
            ValueListenableBuilder<bool>(
              valueListenable: _revealAll,
              builder: (context, all, _) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: () => _revealAll.value = !all,
                  style: TextButton.styleFrom(
                    backgroundColor: all ? c.ai : c.aiWash,
                    foregroundColor: all ? Colors.white : c.ai,
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(all ? 'Ẩn tất cả' : 'Hiện tất cả'),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
          if (!searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: FilterBar(
                filter: _filter,
                lessons: _lessons,
                count: words.length,
                onSelect: (f) async {
                  if (f == HomeFilter.byLesson) return _pickLessons();
                  setState(() => _filter = f);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${words.length} kết quả',
                    style: TextStyle(fontSize: 12, color: c.inkFaint),
                  ),
                  // Co lại thay vì tràn khi màn hẹp — dòng phụ, không đáng
                  // để phá bố cục.
                  Flexible(
                    child: Text(
                      'tìm trong cả ${scope.vocabulary.words.length} từ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: c.inkFaint),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: words.isEmpty
                ? HomeEmpty(
                    searching: searching,
                    filter: _filter,
                    onStartQuiz: () =>
                        RootTabs.goTo(context, RootTabs.tabPractice),
                    onBrowseLessons: _pickLessons,
                  )
                : WordList(
                    words: words,
                    revealAll: _revealAll,
                    highlight: searching ? _query : null,
                    alwaysRevealed: searching,
                  ),
          ),
        ],
      ),
    );
  }

  static String _titleFor(HomeFilter f) => switch (f) {
    HomeFilter.starred => 'Cần học lại',
    HomeFilter.byLesson => 'Theo bài',
    HomeFilter.all => 'Tất cả từ',
  };
}
