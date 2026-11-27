import 'package:flutter/widgets.dart';

import 'data/answer_matcher.dart';
import 'data/grammar.dart';
import 'data/kanji_index.dart';
import 'data/kanji_words.dart';
import 'data/progress_store.dart';
import 'data/settings_store.dart';
import 'data/vocabulary.dart';
import 'speech/speech_service.dart';

/// Những thứ dùng chung cả app, nạp một lần lúc khởi động.
///
/// Cố ý KHÔNG phải ChangeNotifier: bản thân nó không đổi bao giờ. Cái đổi là
/// [progress] và [settings], và widget nào cần thì tự nghe riêng — nghe ở đây
/// sẽ dựng lại cả cây, đúng thứ phải tránh trên danh sách 2090 dòng.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.vocabulary,
    required this.kanji,
    required this.kanjiWords,
    required this.grammar,
    required this.progress,
    required this.settings,
    required this.speech,
    required super.child,
  });

  final Vocabulary vocabulary;

  /// Chữ Hán, mảnh cấu tạo, và các bảng tra ghép sẵn với từ vựng.
  ///
  /// Dựng ở đây chứ không dựng trong widget: các bảng bên trong quét toàn bộ
  /// 2090 từ, tính lại trong hàm build là phí mỗi lần cuộn.
  final KanjiIndex kanji;

  /// 448 từ của PDF MINATO — nguồn chính cho phần học chữ Hán.
  final KanjiWordSet kanjiWords;

  /// Ngữ pháp 50 bài và câu ví dụ Việt–Nhật.
  final GrammarSet grammar;

  final ProgressStore progress;
  final SettingsStore settings;
  final SpeechService speech;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'Thiếu AppScope phía trên widget này');
    return scope!;
  }

  /// Mức nới lỏng hiện tại, dựng từ cài đặt.
  Leniency get leniency => Leniency(
    mixKana: settings.mixKana,
    ignoreLongVowel: settings.ignoreLongVowel,
    realWords: vocabulary.strictForms,
  );

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      vocabulary != oldWidget.vocabulary ||
      kanji != oldWidget.kanji ||
      kanjiWords != oldWidget.kanjiWords ||
      grammar != oldWidget.grammar ||
      progress != oldWidget.progress ||
      settings != oldWidget.settings ||
      speech != oldWidget.speech;
}
