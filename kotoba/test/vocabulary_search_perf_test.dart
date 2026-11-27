import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';

/// Đo thật chi phí `Vocabulary.search` — hàm quét tuyến tính cả 2090 từ sau
/// mỗi lần debounce (200ms, xem lib/ui/home_screen.dart dòng 64-69).
///
/// Không đoán mò "chắc là nhanh" — đo hẳn ra số mili-giây trên máy chạy CI/dev
/// thật, để biết ngưỡng đó có đáng lo hay không.
void main() {
  late Vocabulary vocab;

  setUpAll(() {
    final raw = File('assets/vocabulary.json').readAsStringSync();
    vocab = Vocabulary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('search() trên 2090 từ — đo thời gian, không chỉ đoán', () {
    const queries = ['học', 'がくせい', 'gakusei', 'a', 'nhà', 'ăn'];
    const rounds = 200; // ≈ mô phỏng gõ 200 lần trong một phiên dùng dài

    final sw = Stopwatch()..start();
    for (var i = 0; i < rounds; i++) {
      for (final q in queries) {
        vocab.search(q);
      }
    }
    sw.stop();

    final totalCalls = rounds * queries.length;
    final perCall = sw.elapsedMicroseconds / totalCalls;
    // In ra để review đọc số thật, không phải để pass/fail theo ngưỡng cứng.
    // ignore: avoid_print
    print(
      'search(): $totalCalls lần gọi, ${sw.elapsedMilliseconds}ms tổng, '
      '≈${perCall.toStringAsFixed(1)}µs/lần trên 2090 từ',
    );

    // Ngưỡng rất rộng — chỉ để bắt hồi quy kiểu "quét O(n²)" chứ không phải
    // để chốt ngân sách hiệu năng chặt chẽ (máy CI chạy chậm, không đại diện
    // cho hiệu năng thiết bị thật).
    expect(
      perCall,
      lessThan(5000),
      reason: 'search() chậm bất thường — có hồi quy hiệu năng.',
    );
  });
}
