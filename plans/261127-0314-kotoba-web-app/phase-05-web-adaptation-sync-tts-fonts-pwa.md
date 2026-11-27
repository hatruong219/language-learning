# Phase 05 — Thích nghi web: sync same-origin, font, PWA

## Context Links
- `kotoba/lib/data/sync_service.dart` (`apiBase = String.fromEnvironment('KOTOBA_API_BASE')`, URL = `'$_base/api/$path'`)
- `kotoba/lib/theme.dart` (dòng ~99: "để hệ thống tự chọn font, iOS có Hiragino")
- `kotoba/assets/app-icon-source.png`, `kotoba/tools/make-app-icon.py` (PIL, sinh icon iOS)
- `kotoba/web/{index.html,manifest.json,icons/}` (sinh ở phase 01)

## Overview
- Priority: P2 · Status: done · Effort 3h · Phụ thuộc: 04 (cùng `pubspec.yaml`, `sync_service` đã sửa ở 02)
- App chạy đúng khi phục vụ dưới `/kotoba-app/app/`, đồng bộ qua cùng origin, chữ Nhật/Việt hiện ngay không chờ font từ Google, cài được ra màn hình chính.

## Key Insights
- `sync_service` ghép `$base/api/kotoba/grammar` → default phải là `/kotoba-app` (KHÔNG phải `/kotoba-app/api`) để ra `/kotoba-app/api/kotoba/grammar` khớp rewrite phase 06. BrowserClient chấp nhận URL tương đối.
- CanvasKit không dùng font hệ thống; thiếu glyph thì tải Noto từ `fonts.gstatic.com` lúc chạy → lần đầu hiện ô vuông/nháy, offline thì hỏng. Bundle font subset là cách chắc chắn.
- Noto Sans JP thiếu dấu tiếng Việt chồng (ế, ặ…) → font chính = Noto Sans (Latin + Vietnamese), `fontFamilyFallback: ['NotoSansJP']`.
- Ước tính: ~2.5–3k ký tự CJK duy nhất trong assets → subset NotoSansJP ~1–1.5 MB/độ đậm. Lấy 2 độ đậm tĩnh 400 + 700 (theme dùng 500/600/700 → Flutter chọn gần nhất) ≈ 2–3 MB; Noto Sans Latin+VN ~100 KB/độ đậm. Chấp nhận — so với canvaskit.wasm ~7 MB.
- Dữ liệu đồng bộ sau này có thể thêm kanji ngoài subset → rơi về fallback Google (online) — chấp nhận, chạy lại script subset khi cần.
- `flutter build web --no-web-resources-cdn`: tự host canvaskit thay vì gstatic → không phụ thuộc CDN bên thứ ba, cùng tinh thần bundle font. Dung lượng deploy ~15–20 MB tĩnh, ổn trên Vercel.
- Flutter đang bỏ service worker mặc định (chuyển sang SW tự dọn) → KHÔNG dựa vào nó; PR này không làm offline (YAGNI). Chrome Android hiện không bắt buộc SW để cài PWA; iOS chỉ cần manifest/meta.
- URL chuẩn `/kotoba-app/app/index.html`: Next (trailingSlash=false) redirect `/kotoba-app/app/` → `/kotoba-app/app`, nằm NGOÀI scope `/kotoba-app/app/` → PWA hiện thanh trình duyệt. Dùng `index.html` làm `start_url` là nằm gọn trong scope.

## Requirements
- `apiBase = String.fromEnvironment('KOTOBA_API_BASE', defaultValue: '/kotoba-app')`; cập nhật chú thích (bỏ hướng dẫn `flutter build ios`).
- Font: `kotoba/tools/subset-fonts.py` (fontTools/pyftsubset) tải Noto Sans JP + Noto Sans từ repo `google/fonts` (OFL), gom ký tự từ `assets/*.json` + chuỗi trong `lib/**.dart` + bảng kana đầy đủ + ASCII/Latin-VN, xuất TTF vào `kotoba/fonts/` (commit kết quả + `OFL.txt`; script không chạy trên Vercel).
- `pubspec.yaml` khai báo font family `NotoSans`, `NotoSansJP` (400/700); `theme.dart` đặt `fontFamily` + `fontFamilyFallback` cho cả light/dark.
- PWA `kotoba/web/manifest.json`: `name: "Kotoba — Minna no Nihongo"`, `short_name: "Kotoba"`, `start_url: "/kotoba-app/app/index.html"`, `scope: "/kotoba-app/app/"`, `display: "standalone"`, `background_color`/`theme_color` lấy từ palette `theme.dart` (paper/ai), `lang: "vi"`, icons 192/512/maskable-512.
- `kotoba/web/index.html`: `<title>Kotoba</title>`, `apple-mobile-web-app-capable=yes`, `apple-mobile-web-app-title=Kotoba`, `apple-mobile-web-app-status-bar-style`, `theme-color`, `<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">` (180), `lang="vi"`, viewport `viewport-fit=cover`. Giữ `$FLUTTER_BASE_HREF`.
- Icon: mở rộng `make-app-icon.py` (hoặc đổi tên `make-web-icons.py`) sinh `web/icons/Icon-192.png`, `Icon-512.png`, `Icon-maskable-512.png` (nền đặc, logo trong vùng an toàn 80%), `apple-touch-icon.png` 180, `web/favicon.png`. Bỏ phần sinh iOS iconset (không còn `ios/`).

## Related Code Files
- Sửa: `kotoba/lib/data/sync_service.dart` (chỉ `apiBase` + chú thích), `kotoba/lib/theme.dart`, `kotoba/pubspec.yaml` (fonts), `kotoba/web/manifest.json`, `kotoba/web/index.html`, `kotoba/tools/make-app-icon.py`, `kotoba/test/sync_service_test.dart` (nếu có test default base rỗng → `configured`)
- Tạo: `kotoba/tools/subset-fonts.py`, `kotoba/fonts/*.ttf`, `kotoba/fonts/OFL.txt`, `kotoba/web/icons/*`

## Implementation Steps
1. `apiBase` default + sửa test liên quan "chưa cấu hình" (giờ luôn configured; giữ test bằng `base: ''` tiêm từ ngoài).
2. Viết + chạy `subset-fonts.py` (`python3 -I`, venv có `fonttools brotli`); in số glyph + cỡ file.
3. Khai báo font, sửa theme; `flutter test` (golden/text test không vỡ).
4. Icon + manifest + index.html.
5. `flutter build web --release --base-href /kotoba-app/app/ --no-web-resources-cdn`; serve `build/web` dưới đúng prefix (VD copy vào `public/` rồi `pnpm dev`, hoặc `python3 -m http.server` trên thư mục cha giả lập `/kotoba-app/app/`) → DevTools: không request nào tới `fonts.gstatic.com`/`gstatic.com` khi duyệt các tab chính; Lighthouse/Application > Manifest không lỗi.

## Todo List
- [x] apiBase `/kotoba-app`
- [x] Subset font + theme (NotoSans + NotoSansJP ~920 KB, alias Roboto)
- [x] Icon web + manifest + index.html (manifest, icons, apple-touch-icon, loading indicator)
- [x] Build web, 0 request gstatic (headless Chromium), manifest OK

### Delivery notes
- Done.
- Drift 1: sync đi qua route handler `src/app/kotoba-app/api/kotoba/[resource]/route.ts` (allowlist grammar/kanji/kanji-words, không forward cookie) thay `next.config` rewrite. Ảnh hưởng phase 06. Lý do: chốt Q2 bảo mật ở phase 07.
- Drift 2: font ~920 KB, thấp hơn ước tính 2–3 MB.
- Chưa có: cài PWA trên iPhone (phase 07 manual).

## Success Criteria
- Network tab: 0 request ra Google khi mở Trang chủ, Kanji, Ngữ pháp, Cài đặt.
- Chữ Việt có dấu chồng và kanji hiện đúng ngay frame đầu, kể cả offline sau khi đã tải trang.
- Application > Manifest: installable, icon maskable hiển thị đúng.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| Font làm tải lần đầu chậm (+2–3 MB) | Chắc chắn | TB | Subset chặt; chỉ 2 độ đậm; HTTP cache dài cho asset tĩnh |
| Glyph thiếu sau khi đồng bộ dữ liệu mới | TB | Thấp | Fallback Google tự xử lý khi online; chạy lại script |
| Scope/start_url sai → mở PWA hiện thanh URL | TB | TB | Kiểm trên iPhone ở phase 07; quy ước `index.html` |

## Rollback
Revert phase; app quay về font hệ thống/fallback Google (vẫn chạy, chỉ chậm lần đầu).

## Security Considerations
Font OFL — kèm giấy phép. Không secret.

## Next Steps
07 (cần 06 để phục vụ dưới Next).
