import 'progress_store.dart';
import 'vocabulary.dart';

/// Thành tích của một từ, đã ghép với từ tương ứng.
class WordStat {
  const WordStat(this.word, this.progress);

  final Word word;
  final WordProgress progress;

  int get correct => progress.correct;
  int get wrong => progress.wrong;

  /// Số lượt đã kiểm tra từ này.
  int get attempts => correct + wrong;

  /// Tỉ lệ đúng, 0..1. Chưa kiểm lần nào thì bằng 0.
  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  bool get starred => progress.starred;
}

/// Thống kê học tập, tính từ tiến độ đang có trong máy.
///
/// Chỉ tính, không lưu gì thêm: `correct` và `wrong` đã nằm sẵn trong
/// `progress.json` từ trước, nên bật màn thống kê KHÔNG làm mất dữ liệu cũ và
/// cũng không cần đổi định dạng file.
///
/// Toàn bộ nằm trong máy, không gửi đi đâu.
class StudyStats {
  StudyStats._(this.words);

  /// Những từ ĐÃ từng kiểm tra ít nhất một lần, sắp theo mức đáng lo giảm dần.
  ///
  /// Từ chưa kiểm lần nào không có mặt ở đây. Đưa vào thì danh sách phình lên
  /// 2090 dòng toàn số 0, và thứ cần nhìn — từ đang sai — trôi mất.
  final List<WordStat> words;

  factory StudyStats.of(ProgressStore progress, Vocabulary vocabulary) {
    final out = <WordStat>[];
    for (final entry in progress.entries) {
      final word = vocabulary.byId(entry.key);
      // Bỏ qua id không còn từ tương ứng: nhập file sao lưu cũ, hoặc giáo trình
      // đổi id. Giữ lại thì màn hình phải vẽ một dòng không có chữ nào.
      if (word == null) continue;
      final p = entry.value;
      if (p.correct == 0 && p.wrong == 0) continue;
      out.add(WordStat(word, p));
    }
    out.sort(_byConcern);
    return StudyStats._(out);
  }

  /// Sắp xếp theo mức đáng lo.
  ///
  /// Sai nhiều nhất lên trước. Bằng nhau thì tỉ lệ đúng thấp hơn lên trước —
  /// sai 3/4 lượt đáng lo hơn sai 3/20. Bằng nữa thì từ ít được kiểm lên trước,
  /// vì nó là từ chưa đủ dữ liệu để yên tâm.
  static int _byConcern(WordStat a, WordStat b) {
    final byWrong = b.wrong.compareTo(a.wrong);
    if (byWrong != 0) return byWrong;
    final byAccuracy = a.accuracy.compareTo(b.accuracy);
    if (byAccuracy != 0) return byAccuracy;
    return a.attempts.compareTo(b.attempts);
  }

  /// Số từ đã kiểm tra ít nhất một lần.
  int get testedCount => words.length;

  int get totalAttempts => words.fold(0, (sum, w) => sum + w.attempts);

  int get totalWrong => words.fold(0, (sum, w) => sum + w.wrong);

  int get totalCorrect => totalAttempts - totalWrong;

  /// Tỉ lệ đúng trên TỔNG SỐ LƯỢT, không phải trung bình tỉ lệ từng từ.
  ///
  /// Trung bình các tỉ lệ cho một từ kiểm 1 lần cùng trọng số với một từ kiểm
  /// 20 lần, nên vài từ mới gặp có thể kéo lệch cả con số.
  double get accuracy => totalAttempts == 0 ? 0 : totalCorrect / totalAttempts;

  /// Những từ còn sai — phần đáng xem nhất.
  List<WordStat> get needWork =>
      words.where((w) => w.wrong > 0).toList(growable: false);

  /// Từ đã kiểm mà chưa sai lần nào.
  int get cleanCount => words.length - needWork.length;

  bool get isEmpty => words.isEmpty;
}
