import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'app_scope.dart';
import 'browser_safe_area.dart';
import 'data/grammar.dart';
import 'flush_on_leave.dart';
import 'data/kanji.dart';
import 'data/kanji_words.dart';
import 'data/kanji_index.dart';
import 'data/kv_store_factory.dart';
import 'data/progress_store.dart';
import 'data/settings_store.dart';
import 'data/vocabulary.dart';
import 'speech/speech_service.dart';
import 'theme.dart';
import 'ui/root_tabs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mặc định Flutter bản phát hành thay widget hỏng bằng một ô xám trơn —
  // nhìn ra màn trắng, không biết hỏng ở đâu. App này không debug được trên
  // iPhone (mỗi vòng CI 12 phút), nên bắt nó khai ra lỗi ngay trên màn hình.
  ErrorWidget.builder = (FlutterErrorDetails details) =>
      _OnScreenError(details);

  runApp(const MnnFlashcardApp());
}

/// Hiện lỗi thẳng lên màn hình, kèm nút chép để gửi lại.
class _OnScreenError extends StatelessWidget {
  const _OnScreenError(this.details);
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final text =
        '${details.exception}\n\n'
        '${details.stack.toString().split('\n').take(12).join('\n')}';
    return Material(
      color: const Color(0xFF2C1917),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đã xảy ra lỗi',
                style: TextStyle(
                  fontFamily: bundledFontFamily,
                  fontFamilyFallback: bundledFontFallback,
                  color: Color(0xFFE8705C),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      color: Color(0xFFEDEFF4),
                      fontSize: 11.5,
                      height: 1.4,
                      fontFamily: bundledFontFamily,
                      fontFamilyFallback: bundledFontFallback,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: text)),
                child: const Text('Sao chép chi tiết lỗi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MnnFlashcardApp extends StatefulWidget {
  const MnnFlashcardApp({super.key});

  @override
  State<MnnFlashcardApp> createState() => _MnnFlashcardAppState();
}

class _MnnFlashcardAppState extends State<MnnFlashcardApp> {
  late final Future<_Boot> _boot = _Boot.load();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Đóng/ẩn tab là có thể không bao giờ quay lại: ghi ngay lần chót thay vì
    // chờ bộ đếm trì hoãn, không thì mất thao tác vừa làm.
    _lifecycle = flushOnLeave(_flushAll);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _flushAll() => _boot.then((b) {
    b.progress.flush();
    b.settings.flush();
  }, onError: (_) {});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Boot>(
      future: _boot,
      builder: (context, snap) {
        if (snap.hasError) return _shell(_BootFailure(error: snap.error!));
        final boot = snap.data;
        if (boot == null) {
          return _shell(
            const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        // AppScope phải nằm TRÊN MaterialApp, không được nhét vào `home:`.
        //
        // MaterialApp tự dựng một Navigator bên trong nó, và mọi tấm nền trượt
        // lên hay hộp thoại đều là một route của Navigator đó. Đặt AppScope
        // dưới MaterialApp thì route sinh ra Ở TRÊN nó — tấm nền không thấy
        // AppScope, of(context) trả null, dấu ! nổ ngay khi mở bộ chọn bài.
        //
        // Khung test cũng lồng đúng thứ tự này. Lệch nhau thì test xanh trên
        // một tiền đề sai — đúng chuyện đã xảy ra: mọi bài kiểm tấm nền đều
        // qua trong khi máy thật sập.
        return AppScope(
          vocabulary: boot.vocabulary,
          kanji: boot.kanji,
          kanjiWords: boot.kanjiWords,
          grammar: boot.grammar,
          progress: boot.progress,
          settings: boot.settings,
          speech: boot.speech,
          child: _shell(const RootTabs()),
        );
      },
    );
  }

  Widget _shell(Widget home) => MaterialApp(
    title: 'Kotoba',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    builder: (context, child) => BrowserSafeArea(child: child!),
    home: home,
  );
}

class _Boot {
  _Boot(
    this.vocabulary,
    this.kanji,
    this.kanjiWords,
    this.grammar,
    this.progress,
    this.settings,
    this.speech,
  );

  final Vocabulary vocabulary;
  final KanjiIndex kanji;
  final KanjiWordSet kanjiWords;
  final GrammarSet grammar;
  final ProgressStore progress;
  final SettingsStore settings;
  final SpeechService speech;

  static Future<_Boot> load() async {
    // Mở MỘT kho rồi chia cho mọi bên, đỡ mở DB nhiều lần.
    final kv = await openDefaultKvStore();
    final results = await Future.wait([
      Vocabulary.load(),
      KanjiSet.load(),
      KanjiWordSet.load(),
      GrammarSet.load(),
      ProgressStore.open(kv: kv),
      SettingsStore.open(kv: kv),
    ]);
    final vocabulary = results[0] as Vocabulary;
    // Cố ý không gọi speech.init() ở đây: xin quyền mic ngay lúc mở app là một
    // hộp thoại vô duyên chắn màn hình đầu tiên. Để tới khi anh bấm nút mic.
    return _Boot(
      vocabulary,
      KanjiIndex.build(results[1] as KanjiSet, vocabulary),
      results[2] as KanjiWordSet,
      results[3] as GrammarSet,
      results[4] as ProgressStore,
      results[5] as SettingsStore,
      SpeechService(),
    );
  }
}

/// Hỏng lúc khởi động thì nói thẳng hỏng ở đâu, đừng để màn hình trắng.
class _BootFailure extends StatelessWidget {
  const _BootFailure({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cuộn được: màn báo lỗi mà lại bị cắt mất chữ thì vô dụng nhất.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Không mở được dữ liệu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text('$error', style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
