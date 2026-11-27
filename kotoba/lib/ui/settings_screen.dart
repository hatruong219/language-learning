import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/file_download.dart';
import '../data/progress_store.dart';
import '../data/study_stats.dart';
import '../theme.dart';
import 'settings_widgets.dart';
import 'stats_screen.dart';
import 'sync_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _export() async {
    final scope = AppScope.of(context);
    try {
      await scope.progress.flush();
      downloadTextFile('kotoba-tien-do.json', scope.progress.exportJson());
    } on Object catch (e) {
      // Nuốt lỗi ở đây là tệ nhất trong cả app: anh tưởng đã có bản sao lưu
      // trong khi chẳng có gì, rồi gỡ app là mất sạch.
      _toast('Không xuất được: $e');
    }
  }

  Future<void> _import() async {
    final scope = AppScope.of(context);
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final bytes = picked?.files.singleOrNull?.bytes;
    if (bytes == null || !mounted) return;
    try {
      final n = await scope.progress.importJson(utf8.decode(bytes));
      _toast('Đã nhập $n từ');
    } on ImportException catch (e) {
      // Không nuốt lỗi: nuốt thì tưởng đã khôi phục xong trong khi chẳng có
      // gì được nạp.
      _toast(e.message);
    } on FormatException {
      _toast('File không phải bản sao lưu tiến độ của Kotoba.');
    } on Object catch (e) {
      _toast('Không nhập được: $e');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá toàn bộ tiến độ?'),
        content: const Text(
          'Mất hết danh sách cần học lại và thống kê đúng sai. '
          'Không thể khôi phục nếu chưa xuất file sao lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Xoá', style: TextStyle(color: context.c.shu)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      AppScope.of(context).progress.clearAll();
      _toast('Đã xoá tiến độ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.settings;
    final c = context.c;

    return Scaffold(
      appBar: AppBar(titleSpacing: 20, title: const Text('Cài đặt')),
      body: AnimatedBuilder(
        animation: Listenable.merge([s, scope.progress]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          children: [
            SettingsGroup(
              title: 'Học tập',
              children: [
                SettingsRow(
                  label: 'Thống kê',
                  sublabel: 'Từ nào đã học bao nhiêu lượt, sai mấy lượt',
                  value: _testedLabel(scope),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StatsScreen(),
                    ),
                  ),
                ),
                SettingsRow(
                  label: 'Đang đánh dấu cần học lại',
                  value: '${scope.progress.starredCount} từ',
                ),
              ],
            ),
            SettingsGroup(
              title: 'Dữ liệu',
              children: [
                SettingsRow(
                  label: 'Từ vựng đã tải',
                  sublabel: 'Bài 1–${scope.vocabulary.lessons.length}',
                  value: '${scope.vocabulary.words.length} từ',
                ),
                SettingsRow(
                  label: 'Chữ Hán đã tải',
                  sublabel:
                      'N5 ${scope.kanji.set.byLevel('N5').length}'
                      ' · N4 ${scope.kanji.set.byLevel('N4').length}',
                  value: '${scope.kanji.set.kanji.length} chữ',
                ),
                const SyncRow(),
              ],
            ),
            SettingsGroup(
              title: 'Chấm điểm',
              children: [
                SettingsSwitch(
                  label: 'Bỏ qua trường âm',
                  sublabel: 'びょういん ≈ びよういん',
                  value: s.ignoreLongVowel,
                  onChanged: (v) => s.ignoreLongVowel = v,
                ),
                SettingsSwitch(
                  label: 'Chấp nhận lẫn hiragana và katakana',
                  sublabel: 'Tắt thì テープ ≠ てーぷ',
                  value: s.mixKana,
                  onChanged: (v) => s.mixKana = v,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Cách nhập',
              children: [
                SettingsSwitch(
                  label: 'Tự đổi romaji sang kana',
                  sublabel: 'Tắt thì dùng bàn phím tiếng Nhật của thiết bị',
                  value: s.autoRomaji,
                  onChanged: (v) => s.autoRomaji = v,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Giọng đọc',
              children: [
                SettingsSlider(
                  label: 'Tốc độ đọc',
                  value: s.speechRate,
                  onChanged: (v) => s.speechRate = v,
                  onChangeEnd: (v) => scope.speech.speak('がくせい', rate: v),
                ),
                SettingsSwitch(
                  label: 'Tự đọc khi hiện đáp án',
                  value: s.autoSpeakAnswer,
                  onChanged: (v) => s.autoSpeakAnswer = v,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Phiên học',
              children: [
                SettingsSwitch(
                  label: 'Xáo trộn thứ tự từ',
                  sublabel: 'Tắt thì chạy đúng thứ tự giáo trình',
                  value: s.shuffle,
                  onChanged: (v) => s.shuffle = v,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Sao lưu',
              children: [
                SettingsRow(
                  label: 'Xuất tiến độ ra file',
                  accent: c.ai,
                  onTap: _export,
                ),
                SettingsRow(
                  label: 'Nhập từ file sao lưu',
                  accent: c.ai,
                  onTap: _import,
                ),
                SettingsRow(
                  label: 'Xoá toàn bộ tiến độ',
                  accent: c.shu,
                  onTap: _confirmClear,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Ứng dụng',
              children: const [SettingsRow(label: 'Phiên bản', value: '1.0.0')],
            ),
          ],
        ),
      ),
    );
  }

  /// Số từ đã kiểm ít nhất một lượt, hiện ngay ở dòng Cài đặt.
  ///
  /// Tính ở đây thay vì mở màn mới rồi mới biết: dòng trống trơn thì không ai
  /// biết bấm vào có gì, mà bấm vào thấy "chưa có số liệu" là một cú bấm phí.
  static String _testedLabel(AppScope scope) {
    final n = StudyStats.of(scope.progress, scope.vocabulary).testedCount;
    return n == 0 ? 'chưa có' : '$n từ';
  }
}
