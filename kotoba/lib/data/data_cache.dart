import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'kv_store.dart';
import 'kv_store_factory.dart';

/// Nơi cất bản dữ liệu đã tải về, và đường đọc dữ liệu lúc mở app.
///
/// Quy tắc: mở app thì đọc bản đã tải nếu có, không thì đọc bản đóng gói trong
/// `assets/`. Nhờ đó mở app KHÔNG phụ thuộc mạng, mà bấm đồng bộ một lần là
/// những lần mở sau đều thấy dữ liệu mới.
///
/// Bản tải về nằm trong IndexedDB của trình duyệt, cùng kho với tiến độ — xoá
/// dữ liệu site là mất, nhưng bản đóng gói vẫn còn nên app không bao giờ rỗng.
class DataCache {
  const DataCache({required this.assetPath, required this.key, this.store});

  /// Kho cất bản tải về. Không truyền thì dùng kho chung của app.
  ///
  /// Nhận từ ngoài để test đưa vào kho bộ nhớ riêng từng test — vẫn là mã
  /// IndexedDB thật chạy bên dưới, không phải bản giả lập.
  final KvStore? store;

  /// Đường dẫn asset đóng gói — bản dự phòng, luôn có.
  final String assetPath;

  /// Khoá trong kho (giữ tên file cũ cho dễ đối chiếu).
  final String key;

  Future<KvStore> _kv() async => store ?? await openDefaultKvStore();

  /// Đọc dữ liệu: ưu tiên bản đã tải, hỏng hoặc chưa có thì lấy asset.
  ///
  /// Bản hỏng (giải mã không được) thì ĐỔI KHOÁ thành `.broken` rồi rơi về asset, không xoá — giữ lại
  /// để còn xem được vì sao hỏng. Nếu xoá thì app tự chữa nhưng không ai biết
  /// chuyện gì đã xảy ra.
  Future<Map<String, dynamic>> read() async {
    String? raw;
    try {
      raw = await (await _kv()).get(key);
    } on Object catch (e) {
      // Đọc lỗi tạm thời: dữ liệu trong kho có thể vẫn tốt, đừng đụng vào.
      debugPrint('$key đọc lỗi ($e) — dùng asset đóng gói');
    }
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        throw const FormatException('gốc JSON không phải object');
      } on FormatException catch (e) {
        await _quarantine(e);
      }
    }
    return jsonDecode(await rootBundle.loadString(assetPath))
        as Map<String, dynamic>;
  }

  Future<void> _quarantine(Object e) async {
    debugPrint('$key giải mã không được ($e) — đổi sang $key.broken');
    try {
      await (await _kv()).rename(key, '$key.broken');
    } on Object catch (e2) {
      debugPrint('không đổi khoá được: $e2');
    }
  }

  /// Ghi bản mới. Một transaction nên đứt giữa chừng thì bản cũ vẫn nguyên.
  Future<void> write(Map<String, dynamic> json) async =>
      StagedWrite.commitAll([await stage(json)]);

  /// Mã hoá sẵn, CHƯA thay bản đang dùng.
  ///
  /// Tách hai bước để nhiều khoá thay được cùng lúc: soạn hết, kiểm xong xuôi
  /// rồi mới đồng loạt ghi. Ghi từng khoá một thì khoá đầu đã thay xong mà khoá
  /// sau hỏng, app còn lại một nửa bản mới lẫn một nửa bản cũ — mà các bản đến
  /// từ CÙNG một lần chụp database nên trộn vào là sai. Mã hoá ngay ở đây để
  /// lỗi mã hoá nổ TRƯỚC khi đụng vào kho.
  Future<StagedWrite> stage(Map<String, dynamic> json) async =>
      StagedWrite._(await _kv(), key, jsonEncode(json));

  /// Đã có bản tải về chưa.
  Future<bool> get hasDownload async => (await (await _kv()).get(key)) != null;

  /// Bỏ bản tải về, quay lại dùng asset.
  Future<void> clear() async => (await _kv()).delete(key);
}

/// Một bản mới đã mã hoá sẵn trong RAM, chờ lệnh ghi vào kho.
class StagedWrite {
  StagedWrite._(this._store, this._key, this._payload);

  final KvStore _store;
  final String _key;
  final String _payload;

  /// Ghi ĐỒNG LOẠT nhiều bản: mỗi kho một transaction nên hoặc tất cả cùng
  /// đổi, hoặc không khoá nào đổi (các bản cùng kho — trường hợp của app, vì
  /// chỉ có một kho chung). Lỗi thì ném lên để chỗ gọi báo người dùng.
  static Future<void> commitAll(List<StagedWrite> writes) async {
    final byStore = <KvStore, Map<String, String>>{};
    for (final w in writes) {
      (byStore[w._store] ??= {})[w._key] = w._payload;
    }
    for (final e in byStore.entries) {
      await e.key.putAll(e.value);
    }
  }
}

/// Cache cho chữ Hán và mảnh cấu tạo.
const kanjiCache = DataCache(
  assetPath: 'assets/kanji.json',
  key: 'kanji.json',
);

/// Cache cho 448 từ vựng chữ Hán của PDF MINATO.
const kanjiWordsCache = DataCache(
  assetPath: 'assets/kanji-words.json',
  key: 'kanji-words.json',
);

/// Cache cho ngữ pháp và câu ví dụ.
///
/// Bản đóng gói dựng bởi `tools/build-grammar-asset.py` từ cùng nguồn với
/// migration, nên mở app lần đầu là đã có đủ 50 bài — không bấm đồng bộ vẫn
/// học được.
const grammarCache = DataCache(
  assetPath: 'assets/grammar.json',
  key: 'grammar.json',
);
