import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'kv_store.dart';
import 'kv_store_factory.dart';

/// Cài đặt của app. Cùng cách cất như tiến độ: một chuỗi JSON trong kho khoá–giá trị.
class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._kv, Map<String, dynamic> raw, {bool unsafe = false})
    : _raw = raw,
      _unsafe = unsafe;

  /// Bản không ghi vào đâu cả, dùng cho test dựng giao diện.
  @visibleForTesting
  SettingsStore.inMemory() : _kv = null, _raw = {}, _unsafe = false;

  /// Khoá trong kho (giữ tên file cũ).
  static const key = 'settings.json';

  final KvStore? _kv;
  final Map<String, dynamic> _raw;
  Timer? _pending;

  /// Đọc kho lỗi đầu phiên: không ghi đè bản trong kho.
  final bool _unsafe;

  static Future<SettingsStore> open({KvStore? kv}) async {
    final store = kv ?? await openDefaultKvStore();
    var raw = <String, dynamic>{};
    var unsafe = false;
    String? text;
    try {
      text = await store.get(key);
    } on Object catch (e) {
      // Đọc lỗi tạm thời: dùng mặc định nhưng không ghi đè bản trong kho.
      debugPrint('$key đọc lỗi ($e) — chạy không lưu trong phiên này');
      unsafe = true;
      store.markUnsafe();
    }
    if (text != null) {
      try {
        raw = (jsonDecode(text) as Map).cast<String, dynamic>();
      } on FormatException catch (e) {
        unsafe = await _quarantine(store, e);
      } on TypeError catch (e) {
        unsafe = await _quarantine(store, e);
      }
    }
    return SettingsStore._(store, raw, unsafe: unsafe);
  }

  /// Bản hỏng thật: đổi khoá để còn cứu tay. Trả true nếu đổi khoá cũng hỏng.
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

  T _get<T>(String key, T fallback) {
    final v = _raw[key];
    return v is T ? v : fallback;
  }

  void _set(String key, Object value) {
    final old = _raw[key];
    if (old == value) return;
    // List so sánh bằng == là so identity, không so nội dung — chọn lại đúng
    // bộ bài cũ sẽ bị coi là "đổi" và ghi đĩa vô ích.
    if (old is List && value is List && old.length == value.length) {
      var same = true;
      for (var i = 0; i < old.length; i++) {
        if (old[i] != value[i]) {
          same = false;
          break;
        }
      }
      if (same) return;
    }
    _raw[key] = value;
    _pending?.cancel();
    if (_kv != null && !_unsafe) {
      _pending = Timer(const Duration(milliseconds: 400), flush);
    }
    notifyListeners();
  }

  // ── Chấm điểm ────────────────────────────────────────────────
  /// Coi びょういん và びよういん là một. Tắt sẵn — chấm nghiêm thì học chắc hơn.
  bool get ignoreLongVowel => _get('ignoreLongVowel', false);
  set ignoreLongVowel(bool v) => _set('ignoreLongVowel', v);

  /// Cho gõ hiragana thay katakana và ngược lại. Tắt sẵn: テープ ≠ てーぷ,
  /// đúng theo quy ước dữ liệu và theo app quiz trên desktop.
  bool get mixKana => _get('mixKana', false);
  set mixKana(bool v) => _set('mixKana', v);

  // ── Cách nhập ────────────────────────────────────────────────
  /// Tắt sẵn: bàn phím tiếng Nhật của iOS lo việc đổi chữ, app không đụng vào.
  /// Bật lên thì app tự đổi romaji sang kana, gõ bằng bàn phím nào cũng được.
  bool get autoRomaji => _get('autoRomaji', false);
  set autoRomaji(bool v) => _set('autoRomaji', v);

  // ── Giọng đọc ────────────────────────────────────────────────
  double get speechRate => _get('speechRate', 0.45);
  set speechRate(double v) => _set('speechRate', v);

  bool get autoSpeakAnswer => _get('autoSpeakAnswer', true);
  set autoSpeakAnswer(bool v) => _set('autoSpeakAnswer', v);

  // ── Nhớ lựa chọn lần trước ───────────────────────────────────
  /// Những bài đã chọn ở lần học gần nhất. Mở app lên là vào học ngay, khỏi
  /// phải bấm lại từ đầu mỗi lần — thao tác đó lặp lại mỗi ngày.
  Set<int> get lastLessons {
    final raw = _raw['lastLessons'];
    if (raw is! List) return const {};
    return raw.whereType<num>().map((n) => n.toInt()).toSet();
  }

  set lastLessons(Set<int> v) => _set('lastLessons', (v.toList()..sort()));

  /// Chế độ gõ hay đọc của lần trước.
  bool get lastModeIsSpeak => _get('lastModeIsSpeak', false);
  set lastModeIsSpeak(bool v) => _set('lastModeIsSpeak', v);

  // ── Phiên học ────────────────────────────────────────────────
  /// Bật sẵn để tránh nhớ vẹt theo vị trí. Tắt thì chạy đúng thứ tự giáo trình.
  bool get shuffle => _get('shuffle', true);
  set shuffle(bool v) => _set('shuffle', v);

  Future<void> flush() async {
    _pending?.cancel();
    _pending = null;
    final kv = _kv;
    if (kv == null || _unsafe) return;
    try {
      await kv.putAll({key: jsonEncode(_raw)});
    } on Object catch (e) {
      debugPrint('không ghi được cài đặt: $e');
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}
