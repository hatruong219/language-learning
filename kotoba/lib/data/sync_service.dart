import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'data_cache.dart';
import 'kanji.dart';
import 'kanji_words.dart';

/// Gốc của MỌI lời gọi API (đồng bộ và nhận diện giọng nói), nạp lúc build.
///
/// Mặc định `/kotoba-app`: app được phục vụ dưới `/kotoba-app/app/` cùng tên
/// miền với API, nên dùng đường dẫn tương đối, không CORS, không hard-code URL
/// triển khai. Đồng bộ gọi `$apiBase/api/kotoba/{grammar|kanji}`, nhận diện giọng
/// gọi `$apiBase/api/stt`.
///
/// Chạy dev với API ở máy khác cổng thì ghi đè:
///
///     flutter run -d chrome --dart-define=KOTOBA_API_BASE=http://localhost:3000/kotoba-app
const apiBase = String.fromEnvironment(
  'KOTOBA_API_BASE',
  defaultValue: '/kotoba-app',
);

/// Kết quả một lần đồng bộ, đủ để màn hình nói rõ đã tải được gì.
class SyncResult {
  const SyncResult({
    required this.kanjiCount,
    required this.partCount,
    required this.kanjiWordCount,
    required this.grammarCount,
    required this.sentenceCount,
  });

  final int kanjiCount;
  final int partCount;
  final int kanjiWordCount;
  final int grammarCount;
  final int sentenceCount;

  String get summary =>
      '$kanjiCount chữ · $partCount mảnh · $kanjiWordCount từ Hán'
      ' · $grammarCount mẫu ngữ pháp · $sentenceCount câu';
}

/// Lỗi đồng bộ đã dịch sang câu người dùng đọc hiểu.
///
/// Ném kiểu riêng chứ không để `http` hay `FormatException` lọt ra ngoài: màn
/// hình mà hiện `ClientException: Failed to fetch` thì người dùng không biết
/// phải làm gì.
class SyncException implements Exception {
  const SyncException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Tải dữ liệu mới từ máy chủ.
///
/// Chỉ gọi khi người dùng BẤM NÚT — app không tự đồng bộ. Chưa bấm thì đọc bản
/// đóng gói trong `assets/`, nên mở app không phụ thuộc mạng.
class SyncService {
  SyncService({
    http.Client? client,
    String? base,
    DataCache? kanjiStore,
    DataCache? kanjiWordsStore,
    DataCache? grammarStore,
  }) : _client = client ?? http.Client(),
       // Cắt dấu / cuối: người cấu hình rất hay dán cả 'https://.../' từ thanh
       // địa chỉ, và ghép thẳng sẽ ra '…//api/kotoba/kanji'. Nhiều máy chủ trả
       // 404 cho đường dẫn đó, mà lỗi hiện ra lại là "máy chủ chưa có dữ liệu"
       // — dẫn người dùng đi tìm nhầm chỗ, tưởng migration chưa chạy.
       _base = _trimBase(base ?? apiBase),
       _kanjiStore = kanjiStore ?? kanjiCache,
       _kanjiWordsStore = kanjiWordsStore ?? kanjiWordsCache,
       _grammarStore = grammarStore ?? grammarCache;

  static String _trimBase(String raw) {
    var s = raw.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  final http.Client _client;
  final String _base;

  /// Nơi ghi bản tải về. Nhận từ ngoài để test dùng kho bộ nhớ riêng.
  final DataCache _kanjiStore;
  final DataCache _kanjiWordsStore;
  final DataCache _grammarStore;

  /// Hạn cho MỘT lời gọi mạng.
  static const _timeout = Duration(seconds: 30);

  /// Hạn cho CẢ lượt đồng bộ, tính từ lúc bấm nút tới lúc thay xong cache.
  ///
  /// Cần hạn riêng ngoài hạn từng lời gọi: mạng chập chờn có thể nhỏ giọt đủ
  /// để không lời gọi nào chạm hạn 30 giây, mà cả lượt vẫn kéo vài phút.
  static const _deadline = Duration(seconds: 45);

  bool get configured => _base.isNotEmpty;

  /// Tải chữ Hán và mảnh cấu tạo.
  ///
  /// Dùng lại [KanjiSet.fromJson] — cùng một bộ phân tích với đường đọc asset.
  /// Route API cố ý trả đúng hình dạng của `assets/kanji.json` vì thế: hai bộ
  /// phân tích thì sớm muộn lệch nhau, và lỗi chỉ lộ ra SAU khi đồng bộ, đúng
  /// lúc khó truy nhất.
  Future<KanjiSet> fetchKanji() async =>
      _parseKanji(await _get('kotoba/kanji'));

  /// Tải ngữ pháp và câu ví dụ. Trả về JSON thô — phần này chưa có mô hình
  /// riêng, màn ngữ pháp dựng xong sẽ nhận việc phân tích.
  Future<Map<String, dynamic>> fetchGrammar() => _get('kotoba/grammar');

  /// Tải HẾT và thay cache, để lần mở app sau vẫn thấy dữ liệu mới.
  ///
  /// TẤT CẢ HOẶC KHÔNG GÌ CẢ. Ba chốt, theo đúng thứ tự:
  ///
  ///   1. tải cả BA phần xong xuôi (chữ Hán, từ vựng chữ Hán, ngữ pháp)
  ///   2. kiểm cả ba phần đọc được
  ///   3. mã hoá cả ba trong RAM, rồi ghi một transaction
  ///
  /// Bản cũ chỉ bị thay ở bước cuối, nên hỏng ở bất cứ đâu trước đó thì app vẫn
  /// đang chạy nguyên bản cũ — không bao giờ có chuyện chữ Hán là bản mới còn
  /// ngữ pháp là bản cũ. Ba file trông thì độc lập nhưng đến từ CÙNG một lần
  /// chụp database, trộn các đời với nhau là dữ liệu sai chứ không phải "cũ".
  ///
  /// Quá [_deadline] thì bỏ cuộc và giữ nguyên bản cũ. Mạng chập chờn có thể
  /// treo rất lâu mà không đứt hẳn; không có hạn chung thì người dùng ngồi nhìn
  /// vòng xoay không biết bao giờ mới xong, cũng không biết có nên bấm lại.
  Future<SyncResult> downloadAll() {
    return _run().timeout(
      _deadline,
      onTimeout: () => throw const SyncException(
        'Tải quá lâu nên đã dừng. Dữ liệu cũ vẫn còn nguyên — thử lại khi mạng'
        ' khá hơn.',
      ),
    );
  }

  Future<SyncResult> _run() async {
    // Bước 1: tải cả ba. Song song vì chúng không phụ thuộc nhau, và như thế
    // hạn giờ chung tính theo phần chậm nhất chứ không phải tổng ba phần.
    //
    // Future.wait chứ KHÔNG phải `(a, b).wait` của record: bản record gói lỗi
    // vào ParallelWaitError, nên SyncException đã dịch sang tiếng Việt bị bọc
    // mất và lọt nguyên khối lên màn hình dưới dạng
    // "ParallelWaitError: ...". Future.wait ném thẳng lỗi đầu tiên.
    final parts = await Future.wait([
      _get('kotoba/kanji'),
      _get('kotoba/kanji-words'),
      _get('kotoba/grammar'),
    ]);
    final kanjiJson = parts[0];
    final wordsJson = parts[1];
    final grammarJson = parts[2];

    // Bước 2: kiểm. Payload hỏng mà ghi thẳng thì đè mất bản đang dùng tốt, và
    // app hỏng cho tới khi có mạng lại.
    final set = _parseKanji(kanjiJson);
    final words = _parseKanjiWords(wordsJson);
    final counts = grammarJson['counts'];
    if (counts is! Map) {
      throw const SyncException(
        'Dữ liệu ngữ pháp trả về không đúng dạng. Bản app có thể đã cũ.',
      );
    }

    // Bước 3: mã hoá hết trong RAM rồi ghi cả ba trong một transaction.
    final staged = [
      await _kanjiStore.stage(kanjiJson),
      await _kanjiWordsStore.stage(wordsJson),
      await _grammarStore.stage(grammarJson),
    ];
    try {
      await StagedWrite.commitAll(staged);
    } on SyncException {
      rethrow;
    } on Object catch (e) {
      debugPrint('thay cache lỗi: $e');
      throw const SyncException(
        'Không ghi được dữ liệu mới. Dữ liệu cũ vẫn còn nguyên.',
      );
    }

    int n(String key) => (counts[key] as num?)?.toInt() ?? 0;
    return SyncResult(
      kanjiCount: set.kanji.length,
      partCount: set.parts.length,
      kanjiWordCount: words.words.length,
      grammarCount: n('grammar'),
      sentenceCount: n('sentences'),
    );
  }

  KanjiWordSet _parseKanjiWords(Map<String, dynamic> json) {
    try {
      final set = KanjiWordSet.fromJson(json);
      if (set.words.isEmpty) throw const FormatException('rỗng');
      return set;
    } on Object catch (e) {
      debugPrint('kanjiWords.fromJson lỗi: $e');
      throw const SyncException(
        'Dữ liệu từ vựng chữ Hán trả về không đúng dạng. Bản app có thể đã cũ.',
      );
    }
  }

  KanjiSet _parseKanji(Map<String, dynamic> json) {
    try {
      return KanjiSet.fromJson(json);
    } on Object catch (e) {
      debugPrint('kanji.fromJson lỗi: $e');
      throw const SyncException(
        'Dữ liệu chữ Hán trả về không đúng dạng. Bản app có thể đã cũ.',
      );
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    if (!configured) {
      throw const SyncException(
        'Chưa cấu hình địa chỉ máy chủ cho bản app này.',
      );
    }
    final uri = Uri.parse('$_base/api/$path');
    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode == 404) {
        throw const SyncException(
          'Máy chủ chưa có dữ liệu này. Có thể migration chưa chạy.',
        );
      }
      if (res.statusCode != 200) {
        debugPrint('$uri trả ${res.statusCode}: ${res.body}');
        throw SyncException('Máy chủ trả lỗi ${res.statusCode}.');
      }
      // Đọc theo bytes rồi tự giải UTF-8: `res.body` dùng latin-1 khi máy chủ
      // không ghi charset trong Content-Type, và lúc đó tiếng Nhật thành ký tự
      // rác. Đã trả giá cho lỗi này một lần ở chỗ nhập file sao lưu.
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const SyncException('Máy chủ trả về dữ liệu không đúng dạng.');
      }
      return decoded;
    } on SyncException {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('mạng lỗi: $e');
      throw const SyncException('Không kết nối được. Kiểm tra mạng.');
    } on FormatException catch (e) {
      debugPrint('json lỗi: $e');
      throw const SyncException('Máy chủ trả về dữ liệu không đọc được.');
    } on Object catch (e) {
      debugPrint('đồng bộ lỗi: $e');
      throw const SyncException('Không tải được dữ liệu. Thử lại sau.');
    }
  }

  void close() => _client.close();
}
