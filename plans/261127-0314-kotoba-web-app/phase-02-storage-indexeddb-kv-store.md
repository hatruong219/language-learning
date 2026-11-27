# Phase 02 — Lưu trữ IndexedDB thay dart:io/path_provider

## Context Links
- `kotoba/lib/data/progress_store.dart` (190 dòng), `settings_store.dart` (130), `data_cache.dart` (195, stage/commit/rollback `.tmp/.bak/.broken`), `sync_service.dart` (`SocketException` từ dart:io), `lib/ui/settings_screen.dart` (export qua `getTemporaryDirectory` + `Share.shareXFiles`)
- Test bị ảnh hưởng: `test/data_cache_test.dart`, `test/sync_row_test.dart`, `test/sync_service_test.dart` (nhóm "tất cả hoặc không gì cả") — đều tiêm `directory: () async => tmp`

## Overview
- Priority: P1 (rủi ro cao, làm sớm) · Status: done · Effort 3h · Phụ thuộc: 01
- `lib/` không còn `dart:io` / `path_provider`; mọi thứ lưu vào IndexedDB qua một `KvStore` duy nhất (DRY cho tiến độ, cài đặt, cache đồng bộ).

## Key Insights
- Cỡ dữ liệu: kanji 168K + grammar 476K + kanji-words 60K ≈ 700 KB UTF-8; staging cũ cần ~2–3× → 2 MB+, và grammar sẽ còn lớn. localStorage 5 MB (Safari) + đồng bộ chặn UI → không chọn. IndexedDB: quota lớn, async, có transaction.
- `idb_shim` cho cả `idbFactoryBrowser` (web) và memory factory (VM) → test chạy ĐÚNG đường mã IndexedDB trên VM, không phải mock tự chế.
- Transaction IndexedDB ghi 3 key cùng lúc là nguyên tử → `StagedWrite.commitAll` chỉ còn "giữ payload trong RAM, commit = 1 transaction putAll". Bỏ `rollback/cleanup/.bak` (YAGNI).
- iOS Safari: site không mở 7 ngày có thể bị xoá storage, TRỪ khi đã "Thêm vào MH chính". Gọi `navigator.storage.persist()` (best-effort, Android Chrome).

## Requirements
- Chức năng giữ nguyên: đọc bản tải về nếu có, hỏng → đổi sang key `<name>.broken` rồi rơi về asset; ghi trì hoãn 600/400 ms; export/import tiến độ.
- Export trên web: `Share.shareXFiles([XFile.fromData(bytes, name: 'kotoba-tien-do.json', mimeType: 'application/json')])` — iOS ra share sheet (Lưu vào Tệp), Chrome desktop tải file. Nếu share_plus web không fallback tải file → thêm helper tải bằng anchor (`package:web`, conditional import) — quyết định sau smoke test.
- Import: `FilePicker.platform.pickFiles(withData: true)` đã chạy trên web, giữ.
- `sync_service.dart`: thay `on SocketException` bằng `on http.ClientException` (cùng câu báo lỗi mạng).

## Architecture
```
lib/data/kv_store.dart              abstract KvStore {get, putAll(Map<String,String>), delete, rename}
                                    + IdbKvStore(IdbFactory) — DB 'kotoba', store 'kv'
lib/data/kv_store_factory.dart      KvStore openDefaultKvStore() — conditional import:
  kv_store_factory_web.dart          idbFactoryBrowser (+ storage.persist())
  kv_store_factory_stub.dart         memory factory (VM/test)
ProgressStore.open({KvStore? kv})   key 'progress.json'   (giữ tên key = tên file cũ)
SettingsStore.open({KvStore? kv})   key 'settings.json'
DataCache(assetPath, key, {KvStore? store})  thay tham số `directory`
StagedWrite { store, key, payload }  commitAll → nhóm theo store, 1 putAll/transaction
```
- `main.dart` `_Boot.load()` mở MỘT `KvStore` rồi truyền cho store/cache (tránh mở DB 3 lần). `kanjiCache`/`grammarCache` const hiện tại → đổi thành getter/biến top-level nhận store mặc định lười (`late final`).

## Related Code Files
- Sửa: `kotoba/lib/data/{progress_store,settings_store,data_cache,sync_service}.dart`, `kotoba/lib/ui/settings_screen.dart` (CHỈ phần export/import + bỏ import dart:io/path_provider), `kotoba/lib/main.dart` (`_Boot.load`), `kotoba/pubspec.yaml` (thêm `idb_shim`, bỏ `path_provider`)
- Tạo: `kotoba/lib/data/kv_store.dart`, `kv_store_factory.dart`, `kv_store_factory_web.dart`, `kv_store_factory_stub.dart`, `kotoba/test/kv_store_test.dart`, `kotoba/test/no_dart_io_in_lib_test.dart`
- Sửa test: `data_cache_test.dart`, `sync_row_test.dart`, `sync_service_test.dart`
- File ownership: phase 04 KHÔNG được đụng các file trên trừ khi phase 02 đã xong (settings_screen/settings_store dùng chung → 04 chạy sau 02).

## Implementation Steps
1. Spike 15': `flutter pub add idb_shim`, xác nhận API memory factory chạy trong `flutter test` VM và `idbFactoryBrowser` compile web.
2. Viết `kv_store.dart` + factory conditional import (`if (dart.library.js_interop)`).
3. Port `DataCache`: `read()` (get → decode → lỗi thì `rename(key, '$key.broken')` → asset), `stage()` (encode ngay để lỗi encode nổ trước commit), `hasDownload`, `clear()`.
4. Port `ProgressStore`/`SettingsStore`: `_file` → `_kv` + key; `inMemory()` giữ nguyên (không ghi). Thêm `AppLifecycleListener(onHide: flush)` ở `main.dart` để đóng tab không mất lần ghi cuối.
5. `sync_service.dart`: bỏ `dart:io`, `http.ClientException`.
6. `settings_screen.dart`: export bằng `XFile.fromData`.
7. Sửa 3 test file: `directory:` → `store: IdbKvStore(newMemoryFactory())`; test `.tmp/.bak` đổi thành test "commitAll lỗi giữa chừng không đổi key nào" và "`.broken` được giữ".
8. `no_dart_io_in_lib_test.dart`: quét `lib/**.dart`, fail nếu có `import 'dart:io'` hoặc `path_provider` (khoá hồi quy, cùng lối `ui_text_style_test`).
9. `flutter analyze && flutter test` xanh; `flutter build web` compile được.

## Todo List
- [x] Spike idb_shim (VM + web)
- [x] KvStore + factory
- [x] DataCache / StagedWrite (commit = 1 transaction, bỏ `.tmp/.bak`)
- [x] ProgressStore / SettingsStore + flush onHide (inactive/pause/hide/detach, debounce 250 ms)
- [x] sync_service bỏ dart:io
- [x] Export/import web (export = tải file trình duyệt, xem drift 1)
- [x] Sửa + thêm test, analyze/test xanh (528 test), build web compile

### Delivery notes
- Done. IndexedDB KvStore qua idb_shim; commit đồng bộ nguyên tử; `share_plus` và `path_provider` đã gỡ.
- Drift 1: export dùng tải file qua anchor (blob URL, có revoke) thay `Share.shareXFiles`. Lý do: quyết định sau smoke test (plan cho phép). Chi phí: iOS không còn share sheet "Lưu vào Tệp", chưa kiểm trên iPhone.
- Drift 2 (review hardening): lỗi đọc IDB tạm thời không đổi tên dữ liệu thành `.broken` nữa; import có validate + backup `progress.json.before-import`; banner cảnh báo khi storage không bền (thay SnackBar).

## Success Criteria
- `grep -rn "dart:io\|path_provider" kotoba/lib` rỗng; test mới khoá điều đó.
- Số test ≥ baseline (test thay thế, không xoá trắng).
- Trên Chrome: gắn sao → reload → sao còn; đồng bộ → reload → dữ liệu mới còn (DevTools > Application > IndexedDB `kotoba/kv`).

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| idb_shim không hợp SDK 3.32/Dart 3.8 | Thấp | Cao | Spike bước 1; fallback `sembast_web` (cùng ý, cũng có memory) |
| Safari private mode chặn IndexedDB | TB | TB | `open` lỗi → rơi về memory store + SnackBar "Không lưu được tiến độ ở chế độ này" |
| Dữ liệu cũ trên iOS app không chuyển sang | Chắc chắn | Thấp | Đúng thiết kế: xuất file ở app iOS → nhập trên web (định dạng export giữ nguyên `version: 1`) |
| ITP xoá storage | TB | Cao | Trang hướng dẫn nhắc cài PWA + xuất sao lưu định kỳ; `storage.persist()` |

## Rollback
Thay đổi gói trong `kotoba/` → revert commit của phase; không có dữ liệu server nào bị đụng.

## Security Considerations
Dữ liệu chỉ ở trình duyệt người dùng; không gửi đi đâu. File nhập vào parse bằng `jsonDecode` có try/catch (giữ hành vi cũ).

## Next Steps
Mở khoá 04 và 05.
