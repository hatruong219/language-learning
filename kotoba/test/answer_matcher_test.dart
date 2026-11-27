import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/answer_matcher.dart';

/// Bộ chuẩn sinh từ chính `kana-quiz-popup/src/answer-matcher.js` chạy trên đúng
/// 2090 từ này. Bản Dart phải cho ra kết quả y hệt — lệch một từ là port sai.
/// Sinh lại bằng: node tools/regenerate-answer-golden.mjs
File get _goldenFile => File('test/fixtures/answer-forms-golden.json');
File get _vocabFile => File('assets/vocabulary.json');

void main() {
  group('expandVariants — quy ước ngoặc và dấu', () {
    test('ngoặc vuông là phần tùy chọn', () {
      expect(expandVariants('[カセット]テープ'), ['カセットテープ', 'テープ']);
    });

    test('ngoặc tròn là cách gọi khác', () {
      expect(expandVariants('だれ（どなた）'), ['だれ', 'どなた']);
    });

    test('gạch chéo tách hai biến thể', () {
      expect(expandVariants('～ふん / ～ぷん'), ['ふん', 'ぷん']);
    });

    test('ngoặc vuông chứa ～ sinh cả dạng thế từ chính vào vị trí ～', () {
      final forms = expandVariants('とります [しゃしんを～]');
      expect(forms, contains('とります'));
      expect(forms, contains('しゃしんをとります'));
    });

    test('bỏ dấu câu và khoảng trắng, giữ nguyên kana', () {
      expect(expandVariants('じゃ、また[あした]。'), contains('じゃまたあした'));
    });

    test('chuỗi lẫn latin hoặc số thì không kana-hoá', () {
      expect(expandVariants('ＣＤ'), isEmpty);
      expect(expandVariants('２、３にち'), isEmpty);
    });
  });

  group('checkAnswer — chấm đúng sai', () {
    test('katakana không đổi được sang hiragana', () {
      expect(isCorrectAnswer('てーぷ', ['テープ']), isFalse);
      expect(isCorrectAnswer('テープ', ['テープ']), isTrue);
    });

    test('phần tùy chọn gõ thiếu vẫn đúng', () {
      expect(isCorrectAnswer('くに', ['[お]くに']), isTrue);
      expect(isCorrectAnswer('おくに', ['[お]くに']), isTrue);
    });

    test('đáp án latin kiểu ＣＤ gõ thường vẫn đúng', () {
      final r = checkAnswer('cd', answers: ['ＣＤ']);
      expect(r.correct, isTrue);
      expect(r.kind, MatchKind.latin);
    });

    test('romaji được chấp nhận khi có cột phiên âm', () {
      final r = checkAnswer('gakusei', answers: ['がくせい'], romaji: 'gakusei');
      expect(r.correct, isTrue);
      expect(r.kind, MatchKind.romaji);
    });

    test('trả lời rỗng hoặc sai thì trượt', () {
      expect(isCorrectAnswer('', ['がくせい']), isFalse);
      expect(isCorrectAnswer('せんせい', ['がくせい']), isFalse);
    });
  });

  test('port Dart khớp từng từ với bản JS gốc trên cả 2090 từ', () {
    if (!_goldenFile.existsSync() || !_vocabFile.existsSync()) {
      fail(
        'Thiếu ${_goldenFile.path} hoặc ${_vocabFile.path} — '
        'chạy tools/extract-vocab-from-migrations.py trước.',
      );
    }
    final golden =
        jsonDecode(_goldenFile.readAsStringSync()) as Map<String, dynamic>;
    final vocab =
        jsonDecode(_vocabFile.readAsStringSync()) as Map<String, dynamic>;
    final words = (vocab['words'] as List).cast<Map<String, dynamic>>();

    expect(words.length, 2090, reason: 'dữ liệu đã đổi — sinh lại bộ chuẩn');

    final mismatches = <String>[];
    for (final w in words) {
      final key = '${w['lesson']}|${w['word']}|${w['reading']}';
      final expected = ((golden[key]?['forms'] as List?) ?? const [])
          .cast<String>()
          .toSet();
      final actual = {
        ...expandVariants(w['word'] as String?),
        ...expandVariants(w['reading'] as String?),
      };
      if (!_sameSet(expected, actual)) {
        mismatches.add(
          '$key\n    JS  : ${expected.toList()..sort()}'
          '\n    Dart: ${actual.toList()..sort()}',
        );
      }
    }

    expect(
      mismatches,
      isEmpty,
      reason: 'lệch ${mismatches.length} từ:\n${mismatches.take(8).join('\n')}',
    );
  });

  test('mọi từ đều chấm đúng khi gõ nguyên văn reading', () {
    final vocab =
        jsonDecode(_vocabFile.readAsStringSync()) as Map<String, dynamic>;
    final words = (vocab['words'] as List).cast<Map<String, dynamic>>();

    final failures = <String>[];
    for (final w in words) {
      final answers = [w['word'] as String?, w['reading'] as String?];
      final typed =
          expandVariants(w['reading'] as String?).firstOrNull ??
          normalizeLatin(w['reading'] as String?);
      if (typed.isEmpty) continue;
      if (!isCorrectAnswer(typed, answers, romaji: w['romaji'] as String?)) {
        failures.add('bài ${w['lesson']} · ${w['reading']} (gõ "$typed")');
      }
    }
    expect(
      failures,
      isEmpty,
      reason:
          '${failures.length} từ gõ đúng mà bị chấm trượt:\n'
          '${failures.take(10).join('\n')}',
    );
  });
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

extension _FirstOrNull<E> on Iterable<E> {
  // `this.` là bắt buộc: trong ngữ cảnh file test, `isEmpty` trần sẽ bắt phải
  // matcher isEmpty của gói test chứ không phải thuộc tính của Iterable.
  E? get firstOrNull => this.isEmpty ? null : first;
}
