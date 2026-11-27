/// Thành tích của một từ. Tách riêng khỏi kho lưu để đọc và test độc lập.
class WordProgress {
  const WordProgress({this.correct = 0, this.wrong = 0, this.starred = false});

  final int correct;
  final int wrong;

  /// Anh tự bấm sao. App không bao giờ tự thêm hay tự gỡ.
  final bool starred;

  bool get isEmpty => correct == 0 && wrong == 0 && !starred;

  WordProgress copyWith({int? correct, int? wrong, bool? starred}) =>
      WordProgress(
        correct: correct ?? this.correct,
        wrong: wrong ?? this.wrong,
        starred: starred ?? this.starred,
      );

  Map<String, dynamic> toJson() => {
    if (correct != 0) 'c': correct,
    if (wrong != 0) 'w': wrong,
    if (starred) 's': 1,
  };

  factory WordProgress.fromJson(Map<String, dynamic> j) => WordProgress(
    correct: (j['c'] ?? 0) as int,
    wrong: (j['w'] ?? 0) as int,
    starred: (j['s'] ?? 0) == 1,
  );
}
