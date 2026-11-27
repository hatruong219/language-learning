import 'dart:convert';
import 'dart:io';

import 'package:mnn_flashcard/data/grammar.dart';
import 'package:mnn_flashcard/data/kanji_words.dart';

/// Dữ liệu đóng gói, đọc thẳng từ file cho test.
///
/// Đọc bằng dart:io chứ không qua rootBundle: phần lớn test ở đây không dựng
/// binding, mà rootBundle không có binding thì ném.
///
/// Đọc MỘT lần rồi dùng lại: `assets/grammar.json` gần 500 KB, mỗi test file
/// dựng lại là thêm vài trăm mili giây cho cả bộ.
GrammarSet? _grammar;

GrammarSet loadGrammarFixture() => _grammar ??= GrammarSet.fromJson(
  jsonDecode(File('assets/grammar.json').readAsStringSync())
      as Map<String, dynamic>,
);

KanjiWordSet? _kanjiWords;

/// 448 từ của PDF MINATO. Đọc bằng dart:io vì phần lớn test không dựng binding.
KanjiWordSet loadKanjiWordsFixture() => _kanjiWords ??= KanjiWordSet.fromJson(
  jsonDecode(File('assets/kanji-words.json').readAsStringSync())
      as Map<String, dynamic>,
);
