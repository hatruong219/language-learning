import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'kv_store.dart';
import 'kv_store_factory.dart';
import 'word_progress.dart';

export 'word_progress.dart';

/// Tiến độ nằm hẳn trong máy, không đồng bộ đi đâu.
///
/// Cất thành MỘT chuỗi JSON trong kho khoá–giá trị thay vì dựng bảng riêng:
/// dữ liệu chỉ vài trăm dòng, mà đổi lại xuất/nhập sao lưu thành chuyện đổi
/// đúng một chuỗi — không cần chuyển đổi định dạng, không cần lo nâng cấp
/// schema về sau. Định dạng giữ nguyên với file sao lưu của app iOS.
///
/// Ghi có trì hoãn: bấm sao liên tục mấy chục lần cũng chỉ tốn một lần ghi.
class ProgressStore extends ChangeNotifier {
  ProgressStore._(this._kv, this._entries, {bool unsafe = false})
    : _unsafe = unsafe;

  /// Bản không ghi vào đâu cả, dùng cho test dựng giao diện.
  @visibleForTesting
  ProgressStore.inMemory() : _kv = null, _entries = {}, _unsafe = false;

  /// Khoá trong kho (giữ tên file cũ).
  static const key = 'progress.json';
  static const backupKey = 'progress.json.before-import';
  static const _flushDelay = Duration(milliseconds: 250);
  static final _alwaysPersistent = ValueNotifier<bool>(true);

  final KvStore? _kv;
  final Map<String, WordProgress> _entries;
  Timer? _pending;

  /// Đọc kho lỗi đầu phiên: giữ tiến độ trong RAM, không ghi đè bản trong kho.
  final bool _unsafe;

  /// False khi tiến độ sẽ mất lúc đóng app (kho chỉ trong RAM hoặc không an toàn).
  ValueListenable<bool> get persistent => _kv?.persistent ?? _alwaysPersistent;

  /// Một kênh riêng cho mỗi từ, để dòng nào nghe dòng nấy.
  ///
  /// Đây là chỗ giữ lời hứa "mở một từ thì chỉ dựng lại đúng dòng đó". Nếu mỗi
  /// dòng nghe thẳng ChangeNotifier của store thì bấm sao một từ sẽ dựng lại cả
  /// 2090 dòng — chính cái bẫy Flutter kinh điển cần tránh.
  final Map<String, ValueNotifier<bool>> _starChannels = {};

  ValueListenable<bool> starListenable(String wordId) =>
      _starChannels.putIfAbsent(wordId, () => ValueNotifier(isStarred(wordId)));

  void _pushStar(String wordId) {
    final ch = _starChannels[wordId];
    if (ch != null) ch.value = isStarred(wordId);
  }

  void _pushAllStars() {
    for (final e in _starChannels.entries) {
      e.value.value = isStarred(e.key);
    }
  }

  static Future<ProgressStore> open({KvStore? kv}) async {
    final store = kv ?? await openDefaultKvStore();
    final entries = <String, WordProgress>{};
    var unsafe = false;
    String? raw;
    try {
      raw = await store.get(key);
    } on Object catch (e) {
      // Đọc lỗi TẠM THỜI (không phải dữ liệu hỏng): chạy tiếp bằng bộ nhớ
      // nhưng KHÔNG ghi đè khoá này trong phiên, không thì bản tốt còn nằm
      // trong kho bị thay bằng bản rỗng.
      debugPrint('$key đọc lỗi ($e) — chạy không lưu trong phiên này');
      unsafe = true;
      store.markUnsafe();
    }
    if (raw != null) {
      try {
        entries.addAll(_decode(raw));
      } on FormatException catch (e) {
        unsafe = await _quarantine(store, e);
      } on TypeError catch (e) {
        unsafe = await _quarantine(store, e);
      }
    }
    return ProgressStore._(store, entries, unsafe: unsafe);
  }

  /// Bản hỏng thật (giải mã không được): đổi khoá để còn cứu tay, bắt đầu từ
  /// trống. Trả true nếu đổi khoá cũng hỏng — khi đó không được ghi đè.
  static Future<bool> _quarantine(KvStore store, Object e) async {
    debugPrint('$key giải mã không được ($e) — đổi sang $key.broken');
    try {
      await store.rename(key, '$key.broken');
      return false;
    } on Object catch (_) {
      store.markUnsafe();
      return true;
    }
  }

  /// Giải mã chặt: sai định dạng thì ném [FormatException]/[TypeError].
  static Map<String, WordProgress> _decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final words = (json['words'] as Map?)?.cast<String, dynamic>() ?? const {};
    return {
      for (final e in words.entries)
        e.key: WordProgress.fromJson((e.value as Map).cast<String, dynamic>()),
    };
  }

  WordProgress of(String wordId) => _entries[wordId] ?? const WordProgress();

  /// Mọi từ CÓ tiến độ, để bên ngoài tự tổng hợp.
  ///
  /// Trả BẢN CHỤP chứ không trả `_entries.entries`. Bản kia là khung nhìn sống:
  /// đang duyệt để tính thống kê mà có chỗ nào ghi thêm tiến độ thì nổ
  /// ConcurrentModificationError. Vài trăm mục nên chụp lại rẻ.
  List<MapEntry<String, WordProgress>> get entries => List.of(_entries.entries);

  bool isStarred(String wordId) => of(wordId).starred;

  Iterable<String> get starredIds =>
      _entries.entries.where((e) => e.value.starred).map((e) => e.key);

  int get starredCount => starredIds.length;

  void _put(String wordId, WordProgress p) {
    if (p.isEmpty) {
      _entries.remove(wordId);
    } else {
      _entries[wordId] = p;
    }
    _scheduleFlush();
    notifyListeners();
  }

  void setStarred(String wordId, bool starred) {
    _put(wordId, of(wordId).copyWith(starred: starred));
    _pushStar(wordId);
  }

  void toggleStar(String wordId) => setStarred(wordId, !isStarred(wordId));

  void starAll(Iterable<String> wordIds) {
    for (final id in wordIds) {
      _entries[id] = of(id).copyWith(starred: true);
    }
    _scheduleFlush();
    _pushAllStars();
    notifyListeners();
  }

  void record(String wordId, {required bool correct}) {
    final p = of(wordId);
    _put(
      wordId,
      correct
          ? p.copyWith(correct: p.correct + 1)
          : p.copyWith(wrong: p.wrong + 1),
    );
  }

  void clearAll() {
    _entries.clear();
    _scheduleFlush();
    _pushAllStars();
    notifyListeners();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'app': 'mnn_flashcard',
    'version': 1,
    'words': {for (final e in _entries.entries) e.key: e.value.toJson()},
  });

  /// Trả về số mục đã nạp. Ném [ImportException] (thông báo tiếng Việt, hiện
  /// thẳng cho người dùng) nếu file không phải bản sao lưu hợp lệ — nuốt lỗi ở
  /// đây thì sẽ tưởng đã khôi phục xong trong khi chẳng có gì.
  ///
  /// Trước khi thay, tiến độ hiện tại được cất ở [backupKey] (một ô duy nhất,
  /// nhập lần sau đè lần trước). Tiến độ đang trống thì bỏ qua bước này để khỏi
  /// đè mất bản cứu hộ cũ bằng một bản rỗng.
  Future<int> importJson(String raw) async {
    final parsed = _parseBackup(raw);
    final kv = _kv;
    if (kv != null && !_unsafe && _entries.isNotEmpty) {
      try {
        await kv.putAll({backupKey: exportJson()});
      } on Object catch (e) {
        throw ImportException('Không lưu được bản dự phòng nên chưa nhập: $e');
      }
    }
    _entries
      ..clear()
      ..addAll(parsed);
    _scheduleFlush();
    _pushAllStars();
    notifyListeners();
    return parsed.length;
  }

  /// Chỉ nhận file đúng định dạng của app (cả bản xuất từ app iOS): có
  /// `app == mnn_flashcard`, có map `words`, và ít nhất một mục.
  static Map<String, WordProgress> _parseBackup(String raw) {
    const notBackup = 'File này không phải bản sao lưu tiến độ của Kotoba.';
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      throw const ImportException(notBackup);
    }
    if (json is! Map || json['app'] != 'mnn_flashcard' || json['words'] is! Map) {
      throw const ImportException(notBackup);
    }
    final Map<String, WordProgress> parsed;
    try {
      parsed = _decode(raw);
    } on FormatException {
      throw const ImportException('Bản sao lưu bị lỗi, không đọc được.');
    } on TypeError {
      throw const ImportException('Bản sao lưu bị lỗi, không đọc được.');
    }
    if (parsed.isEmpty) {
      throw const ImportException('Bản sao lưu không có từ nào, chưa nhập.');
    }
    return parsed;
  }

  void _scheduleFlush() {
    _pending?.cancel();
    if (_kv == null || _unsafe) return; // không có chỗ ghi, hoặc không an toàn
    _pending = Timer(_flushDelay, flush);
  }

  Future<void> flush() async {
    _pending?.cancel();
    _pending = null;
    final kv = _kv;
    if (kv == null || _unsafe) return;
    try {
      await kv.putAll({key: exportJson()});
    } on Object catch (e) {
      debugPrint('không ghi được tiến độ: $e');
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    for (final ch in _starChannels.values) {
      ch.dispose();
    }
    _starChannels.clear();
    super.dispose();
  }
}

/// Nhập file sao lưu thất bại, [message] là câu tiếng Việt cho người dùng.
class ImportException implements Exception {
  const ImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
