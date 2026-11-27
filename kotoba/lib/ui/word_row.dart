import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../data/vocabulary.dart';
import '../theme.dart';
import 'word_row_parts.dart';

/// Một dòng từ vựng: nghĩa bên trái, kana bên phải (mặc định che).
///
/// Dòng này tự giữ trạng thái ẩn/hiện của chính nó và tự nghe hai kênh riêng
/// (`revealAll` chung, `starred` của riêng nó). Widget cha KHÔNG biết dòng nào
/// đang mở — nhờ vậy lật một ô chỉ dựng lại một dòng, không đụng tới 2089 dòng
/// còn lại. Đây là ràng buộc bắt buộc, đừng đổi sang setState ở cha.
class WordRow extends StatefulWidget {
  const WordRow({
    super.key,
    required this.word,
    required this.revealAll,
    required this.starred,
    this.onSpeak,
    this.onToggleStar,
    this.onTap,
    this.alwaysRevealed = false,
    this.highlight,
    this.trailingStatus,
    this.subtitle,
  });

  final Word word;

  /// Cờ chung cho nút "Hiện tất cả" — mọi dòng cùng nghe một kênh này thay vì
  /// để widget cha gọi setState và dựng lại cả danh sách.
  final ValueListenable<bool> revealAll;
  final ValueListenable<bool> starred;

  final VoidCallback? onSpeak;
  final VoidCallback? onToggleStar;
  final VoidCallback? onTap;

  /// Màn tìm kiếm và màn tổng kết luôn hiện chữ — che đi thì tra làm gì.
  final bool alwaysRevealed;

  /// Chuỗi cần tô vàng trong phần nghĩa (kết quả tìm kiếm).
  final String? highlight;

  /// Chấm màu trạng thái ở mép trái (đúng/sai) trong phiên học.
  final Color? trailingStatus;

  final String? subtitle;

  @override
  State<WordRow> createState() => _WordRowState();
}

/// Chiều cao một dòng, chưa tính lề. Danh sách dùng `itemExtent: rowExtent`.
const double rowHeight = 72; // đủ cho 2 dòng nghĩa, hoặc 1 dòng + phụ đề
const double rowExtent = rowHeight + 6;

class _WordRowState extends State<WordRow> {
  final _revealedSelf = ValueNotifier(false);

  @override
  void dispose() {
    _revealedSelf.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    if (!widget.alwaysRevealed) _revealedSelf.value = !_revealedSelf.value;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ValueListenableBuilder<bool>(
      valueListenable: widget.starred,
      builder: (context, starred, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onLongPress: widget.onToggleStar,
          child: Container(
            // Chiều cao cố định: dải màu bên trái dùng CrossAxisAlignment.stretch,
            // mà trong ListView chiều cao không chặn thì stretch không có mốc để
            // giãn. Con số khớp với itemExtent 72 trừ 6 lề dưới.
            height: rowHeight,
            margin: const EdgeInsets.only(bottom: 6),
            // Viền phải đồng màu: Flutter cấm bo góc khi các cạnh khác màu
            // nhau. Vạch hổ phách vẽ thành dải riêng bên trong, không phải
            // bằng cách đổi màu cạnh trái.
            decoration: c.cardBox(radius: Radii.row),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (starred) Container(width: 3, color: c.kincha),
                if (widget.trailingStatus != null)
                  Container(width: 3, color: widget.trailingStatus),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 11, 12, 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _meaning(c)),
                        const SizedBox(width: 10),
                        SizedBox(width: 138, child: _japanese(c)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _meaning(Palette c) {
    final sub = widget.subtitle;
    // Bọc Flexible chứ không canh cho vừa khít: dòng cao cố định, mà chiều cao
    // chữ còn phụ thuộc cỡ chữ hệ thống anh đặt trong Cài đặt máy. Canh số
    // pixel thì chỉ đúng ở một cỡ chữ; để nó co lại thì đúng ở mọi cỡ.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: HighlightedText(
            text: widget.word.meaning,
            highlight: widget.highlight,
            maxLines: sub != null ? 1 : 2,
            style: TextStyle(fontSize: 15, height: 1.25, color: c.ink),
            hitStyle: TextStyle(
              fontSize: 15,
              height: 1.25,
              color: c.kincha,
              fontWeight: FontWeight.w600,
              backgroundColor: c.kinchaWash,
            ),
          ),
        ),
        if (sub != null)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, height: 1.2, color: c.inkFaint),
              ),
            ),
          ),
      ],
    );
  }

  Widget _japanese(Palette c) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.revealAll,
            builder: (context, all, _) => ValueListenableBuilder<bool>(
              valueListenable: _revealedSelf,
              builder: (context, self, _) {
                final show = widget.alwaysRevealed || all || self;
                // Ô che cao đúng bằng một dòng kana — đổi chiều cao giữa hai
                // trạng thái thì cả danh sách giật mỗi lần bấm.
                return SizedBox(
                  height: 22,
                  child: show
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.word.reading,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: c.ink,
                              ),
                            ),
                          ),
                        )
                      : MaskBar(c: c),
                );
              },
            ),
          ),
        ),
        if (widget.onSpeak != null) ...[
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.volume_up_rounded,
            color: c.ai,
            background: c.aiWash,
            onTap: widget.onSpeak!,
            tooltip: 'Nghe',
          ),
        ],
      ],
    );
  }
}
