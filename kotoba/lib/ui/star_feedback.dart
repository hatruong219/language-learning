import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/vocabulary.dart';
import '../theme.dart';

/// Bật/tắt dấu sao kèm thông báo nhỏ và nút hoàn tác.
///
/// Vì sao cần: thao tác này là **nhấn giữ** — không có gì trên màn hình gợi ý
/// nó tồn tại, và cũng không có gì xác nhận nó đã xảy ra. Tệ hơn nữa, khi đang
/// đứng ở nhánh "Cần học lại" thì gỡ một từ làm nó biến mất khỏi danh sách
/// ngay lập tức: lỡ tay là mất, mà không biết vừa mất từ nào.
///
/// Nút hoàn tác chính là chỗ đáng giá nhất ở đây — danh sách này anh tích cóp
/// từng từ một qua hàng tuần.
void toggleStarWithFeedback(BuildContext context, Word word) {
  final scope = AppScope.of(context);
  final wasStarred = scope.progress.isStarred(word.id);
  scope.progress.setStarred(word.id, !wasStarred);

  final c = context.c;
  // removeCurrentSnackBar chứ KHÔNG phải hideCurrentSnackBar: bản `hide` chạy
  // hoạt ảnh đóng của thông báo cũ rồi mới mở cái mới. Bấm sao vài từ liên
  // tiếp thì mỗi lần phải chờ hết hoạt ảnh đó — đúng cái khựng nhìn thấy được.
  final messenger = ScaffoldMessenger.of(context)..removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(
            wasStarred ? Icons.star_border_rounded : Icons.star_rounded,
            size: 19,
            color: c.kincha,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              wasStarred
                  ? 'Đã gỡ ${word.reading} khỏi Cần học lại'
                  : 'Đã thêm ${word.reading} vào Cần học lại',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Hoàn tác',
        textColor: c.kincha,
        onPressed: () => scope.progress.setStarred(word.id, wasStarred),
      ),
    ),
  );
}
