# Phase 01 — Worktree + chép mã Flutter, baseline xanh

## Context Links
- Nguồn: `/home/gnourt/my-project/mnn-flashcard` (pubspec.yaml, analysis_options.yaml, lib/, test/, assets/, tools/make-app-icon.py)
- Đích: `/home/gnourt/my-project/language-learning-kotoba` (worktree mới)

## Overview
- Priority: P1 (mọi phase khác dựa vào đây) · Status: done · Effort 1.5h
- Tạo worktree, chép mã Flutter vào `kotoba/`, sinh nền tảng web, chứng minh `flutter test` vẫn xanh TRƯỚC khi sửa gì (baseline để so hồi quy).

## Key Insights
- Repo nguồn KHÔNG có `web/` → phải `flutter create --platforms web .` trong `kotoba/`.
- Giữ tên package `mnn_flashcard` (mọi test import `package:mnn_flashcard/...`); đổi tên = churn vô ích.
- Flutter SDK ở `~/sdk/flutter` (chưa vào PATH) → gọi `~/sdk/flutter/bin/flutter` hoặc `export PATH`.
- `pnpm lint` (eslint flat config) sẽ quét `public/kotoba-app/app/*.js` (bản build) nếu không ignore.

## Requirements
- Worktree trên branch mới từ `master`; worktree chính và file dở `KanjiWordBrowser.tsx` không bị đụng.
- Chép: `lib/ test/ assets/ pubspec.yaml pubspec.lock analysis_options.yaml tools/make-app-icon.py`. KHÔNG chép `ios/ android/ build/ docs/ plans/ .dart_tool/ *.iml`, các tool python dựng dữ liệu (dữ liệu sống ở admin, không cần trong repo web — YAGNI).

## Related Code Files
- Tạo: `kotoba/**` (bản chép), `kotoba/web/` (flutter create), `kotoba/README.md` (viết ở phase 07)
- Sửa: `.gitignore`, `eslint.config.mjs`

## Implementation Steps
1. `cd /home/gnourt/my-project/language-learning && git fetch && git worktree add ../language-learning-kotoba -b feat.kotoba-web-app origin/master` (hoặc `master` nếu local đã mới).
2. Trong worktree: `rsync -a --exclude '.dart_tool' --exclude build --exclude ios --exclude android --exclude plans --exclude docs --exclude '*.iml' --exclude tools ../mnn-flashcard/ kotoba/` rồi chép riêng `tools/make-app-icon.py`. Bỏ `README.md` cũ của nguồn (viết lại ở 07).
3. `cd kotoba && ~/sdk/flutter/bin/flutter create --platforms web --project-name mnn_flashcard .` — chỉ nhận `web/`, xoá mọi file khác mà lệnh sinh thêm nếu có (VD `test/widget_test.dart` mẫu).
4. `flutter pub get && flutter analyze && flutter test` → ghi lại số test pass làm baseline.
5. `.gitignore` thêm: `/public/kotoba-app/app/`, `/kotoba/build/`, `/kotoba/.dart_tool/`, `/kotoba/.flutter-plugins*`, `/.flutter-sdk/`.
6. `eslint.config.mjs` globalIgnores thêm `public/kotoba-app/**`, `kotoba/**`.
7. `pnpm install && pnpm lint && pnpm build` vẫn xanh.

## Todo List
- [x] Worktree + branch `feat.kotoba-web-app`
- [x] Chép mã, sinh `web/` (`kotoba/` không có `ios/`, `android/`)
- [x] Baseline `flutter analyze` + `flutter test` (baseline 457 test)
- [x] `.gitignore`, eslint ignore (xác minh lại bằng `git status` ở phase 07)
- [ ] `pnpm lint` + `pnpm build`: build xanh; lint còn 8 lỗi có sẵn ở file không đụng, chưa đạt "0 lỗi". Cần quyết waiver hoặc fix.

### Delivery notes
- Done. Không drift phạm vi. Giữ tên package `mnn_flashcard`.

## Success Criteria
- `git -C ../language-learning status` vẫn chỉ có `KanjiWordBrowser.tsx` sửa dở.
- Baseline test xanh 100% trên VM; `ls kotoba/ios` không tồn tại.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| SDK 3.32.0 cài chưa xong | TB | Chặn | Kiểm `flutter --version` trước; chờ cài xong |
| `flutter create` ghi đè file | Thấp | TB | Chạy trên bản chép, xem `git status` rồi revert file thừa |

## Rollback
Xoá worktree: `git worktree remove ../language-learning-kotoba && git branch -D feat.kotoba-web-app`.

## Security Considerations
Không chép `.env`/khoá ký iOS (nằm trong `ios/` — đã loại).

## Next Steps
02, 03, 06 có thể bắt đầu song song.
