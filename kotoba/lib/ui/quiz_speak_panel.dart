import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../speech/speech_service.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'quiz_prompt.dart';
import 'quiz_speak_stages.dart';

/// Chế độ đọc: nghe → hiện chữ ra cho sửa → mới chấm.
///
/// Cố ý KHÔNG chấm ngay khi nghe xong. Nhận diện tiếng Nhật với từ đơn lẻ sai
/// khá thường xuyên, chấm thẳng thì anh bị oan liên tục. Cho xem và sửa trước
/// khi gửi thì sai là sai thật — và nhờ vậy bỏ được nút "tôi đọc đúng mà".
class QuizSpeakPanel extends StatefulWidget {
  const QuizSpeakPanel({
    super.key,
    required this.item,
    required this.onSubmit,
    required this.onSkip,
    required this.onSwitchToWrite,
  });

  final QuizItem item;
  final ValueChanged<String> onSubmit;
  final VoidCallback onSkip;
  final VoidCallback onSwitchToWrite;

  @override
  State<QuizSpeakPanel> createState() => QuizSpeakPanelState();
}

class QuizSpeakPanelState extends State<QuizSpeakPanel> {
  final _heard = TextEditingController();
  final _levels = <double>[];

  /// Trình duyệt (nhất là iOS Safari) chỉ cho AudioContext/getUserMedia chạy khi
  /// có cú chạm của người dùng. Nên lần ghi ĐẦU TIÊN của phiên trang phải do
  /// bấm nút; sau khi một lần ghi từ cú chạm đã mở được mic thì các lần sau
  /// mới tự nghe được. Biến static: sống qua các câu hỏi, mất khi tải lại trang.
  static bool _gestureUnlocked = false;

  @visibleForTesting
  static void resetGestureUnlock() => _gestureUnlocked = false;

  /// Đang chờ người dùng bấm nút mic lần đầu.
  late bool _needsTap = !_gestureUnlocked;

  // Bật sẵn khi được tự nghe: để false thì khung hình đầu tiên vẽ ra bộ nút
  // "Trả lời / Đọc lại" rồi mới nhảy sang giao diện nghe — chớp một cái, và đủ
  // để một cú chạm rơi trúng nút Đọc lại.
  late bool _listening = !_needsTap;

  /// Đã dừng ghi, đang chờ máy chủ trả chữ.
  bool _recognizing = false;
  String? _error;

  /// Chặn gọi chồng. Hai lần _startListening cùng lúc sẽ mở hai phiên nghe
  /// trên cùng một bộ nhận diện.
  bool _starting = false;

  /// Giữ tham chiếu: dispose() không tra được InheritedWidget.
  SpeechService? _speech;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speech = AppScope.of(context).speech;
  }

  @override
  void initState() {
    super.initState();
    if (!_needsTap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
    }
  }

  @override
  void dispose() {
    _speech?.cancelListening();
    _heard.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_starting) return;
    _starting = true;
    try {
      await _listenOnce();
    } finally {
      _starting = false;
    }
  }

  Future<void> _listenOnce() async {
    final scope = AppScope.of(context);
    // Không `await` gì trước listen(): iOS Safari chỉ cho xin quyền mic khi
    // lời gọi còn nằm trong cú chạm của người dùng. (setState đồng bộ nên ổn.)
    final fromTap = _needsTap;
    setState(() {
      _needsTap = false;
      _listening = true;
      _recognizing = false;
      _error = null;
      _levels.clear();
    });

    final started = await scope.speech.listen(
      // Phiên nghe có thể chết giữa chừng — mất quyền mic, mạng rớt, máy chủ
      // lỗi. Không có đường báo này thì màn hình đứng "Đang nghe…" vĩnh viễn.
      onError: (msg) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _recognizing = false;
          _error = msg;
        });
      },
      onProcessing: () {
        if (mounted) setState(() => _recognizing = true);
      },
      onLevel: (level) {
        if (!mounted) return;
        setState(() {
          _levels.add(level);
          if (_levels.length > 40) _levels.removeAt(0);
        });
      },
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          // Whisper hay trả chữ có kanji — đọc せんせい thì nó trả 先生. Tra
          // ngược trong từ điển để hiện lại dạng kana. SpeechService đã bỏ
          // dấu câu ("先生。") nên tra khớp được.
          _heard.text = _toKanaIfKnown(text, scope);
          if (isFinal) {
            _listening = false;
            _recognizing = false;
          }
        });
      },
    );

    // Mic đã mở được từ một cú chạm: từ giờ tự nghe được.
    if (started && fromTap) _gestureUnlocked = true;

    // listen() trả false khi không mở nổi phiên. Không kiểm giá trị này thì
    // giao diện kẹt ở trạng thái nghe trong khi phía dưới chưa từng chạy.
    if (mounted && !started) {
      setState(() {
        _listening = false;
        _recognizing = false;
        _error ??= scope.speech.lastError ?? 'Không bắt đầu nghe được.';
      });
    }
  }

  /// Đổi chữ máy nghe được về dạng kana nếu tra ra trong từ điển.
  String _toKanaIfKnown(String raw, AppScope scope) =>
      scope.vocabulary.bySpokenForm(raw)?.reading ?? raw.trim();

  /// Dừng tay: chờ nhận diện xong. Kết quả/lỗi về qua callback của listen();
  /// dòng cuối chỉ là lưới an toàn nếu không còn phiên nào để báo.
  Future<void> _stop() async {
    await _speech?.stopListening();
    if (mounted && _listening && !_recognizing) {
      setState(() => _listening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuizPrompt(
          label: _listening || _needsTap ? 'ĐỌC TO TỪ NÀY' : 'NGHĨA',
          text: widget.item.word.meaning,
        ),
        if (_error != null)
          ErrorNote(message: _error!, onRetry: _startListening)
        else if (_needsTap)
          TapToSpeakStage(onTap: _startListening)
        else if (_recognizing)
          const RecognizingStage()
        else if (_listening)
          ListeningStage(
            levels: _levels,
            onStop: _stop,
            partialText: _heard.text,
          )
        else
          ReviewStage(controller: _heard),
        const SizedBox(height: 12),
        if (!_listening && !_needsTap && _error == null) ...[
          FilledButton(
            onPressed: _heard.text.trim().isEmpty
                ? null
                : () => widget.onSubmit(_heard.text),
            child: const Text('Trả lời'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startListening,
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: const Text('Đọc lại'),
                  style: _outlined(c),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onSkip,
                  style: _outlined(c),
                  child: const Text('Bỏ qua'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          // Lối thoát khi đang ở chỗ đông người hoặc mic dở chứng — đổi được
          // giữa chừng, không mất lượt.
          onPressed: widget.onSwitchToWrite,
          style: TextButton.styleFrom(foregroundColor: c.inkFaint),
          child: const Text('Không dùng được micro — chuyển sang nhập chữ'),
        ),
      ],
    );
  }

  ButtonStyle _outlined(Palette c) => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(46),
    side: BorderSide(color: c.line),
    foregroundColor: c.inkSoft,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
