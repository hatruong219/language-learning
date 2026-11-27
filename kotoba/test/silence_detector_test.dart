import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/speech/silence_detector.dart';

Duration ms(int v) => Duration(milliseconds: v);

void main() {
  test('im lặng từ đầu: không bao giờ tự dừng và chưa nghe thấy tiếng', () {
    final d = SilenceDetector();
    for (var t = 0; t < 6000; t += 100) {
      expect(d.add(-55, ms(t)), isFalse);
    }
    expect(d.heardSpeech, isFalse);
  });

  test('nói rồi im đủ 1,5 giây thì dừng', () {
    final d = SilenceDetector();
    expect(d.add(-12, ms(300)), isFalse);
    expect(d.heardSpeech, isTrue);
    expect(d.add(-50, ms(400)), isFalse); // bắt đầu im
    expect(d.add(-50, ms(1800)), isFalse); // mới 1,4 giây
    expect(d.add(-50, ms(1900)), isTrue); // đủ 1,5 giây
  });

  test('ngập ngừng ngắn giữa chừng không bị cắt', () {
    final d = SilenceDetector();
    d.add(-10, ms(200));
    d.add(-50, ms(300));
    expect(d.add(-15, ms(1200)), isFalse); // nói lại, đồng hồ im lặng reset
    expect(d.add(-50, ms(1300)), isFalse);
    expect(d.add(-50, ms(2700)), isFalse);
    expect(d.add(-50, ms(2800)), isTrue);
  });
}
