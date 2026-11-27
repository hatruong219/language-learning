# Phase 04 — Mic trên web: ghi âm + gửi STT (kèm sửa TTS web)

## Context Links
- `kotoba/lib/speech/speech_service.dart` (245 dòng; speech_to_text + flutter_tts + iOS audio category)
- `kotoba/lib/ui/quiz_speak_panel.dart` (216; `_toKanaIfKnown` tra ngược kanji→kana), `quiz_speak_stages.dart` (levels dBFS, `_norm`), `test/sound_level_test.dart`
- `kotoba/lib/ui/settings_screen.dart` (công tắc "Nhận diện giọng ngoại tuyến", `_probeSpeech`), `kotoba/lib/data/settings_store.dart` (`offlineSpeech`)
- Hợp đồng phase 03: `POST /kotoba-app/api/stt`, body raw audio, trả `{text}` | `{error}`

## Overview
- Priority: P1 (rủi ro cao) · Status: done (iPhone chưa test) · Effort 3h · Phụ thuộc: 02 (cùng file settings), 03 (contract; có thể code song song, test thật cần 03 xong)
- Thay speech_to_text bằng ghi âm trong trình duyệt → Groq Whisper. Bỏ chế độ ngoại tuyến. Giữ tra ngược kanji→kana. Đồng thời gỡ code âm thanh riêng iOS khỏi phần TTS (vì nó làm `speak` hỏng trên web).

## Key Insights
- Chọn package `record` (có web impl) với `AudioEncoder.wav`, 16 kHz, mono: một content-type `audio/wav` cho cả Chrome lẫn iOS Safari → né khác biệt `audio/webm` (Chrome) vs `audio/mp4` (Safari) của MediaRecorder. File nhỏ (8 s ≈ 256 KB). `onAmplitudeChanged` trả dBFS — khớp đúng thang `levels` mà `ListeningStage` đang dùng (-60..0) → widget sóng giữ nguyên.
- Trên web `stop()` trả blob URL → lấy bytes bằng `http.get(Uri.parse(blobUrl))` (BrowserClient đọc được `blob:`), rồi POST.
- Không còn kết quả từng phần: gọi `onResult(text, true)` đúng một lần → API `listen()` giữ được hình dạng, panel đổi ít.
- Tự dừng: đã nghe thấy tiếng (dBFS > ngưỡng ~-35) rồi im ≥ 1.5 s → stop; trần 8 s; nút dừng tay giữ nguyên. Chưa từng vượt ngưỡng → KHÔNG gửi lên (tiết kiệm quota + chặn ảo giác Whisper), báo "Không nghe thấy giọng nói."
- Whisper trả có dấu câu ("先生。") → bỏ `。、！？!?.,` và khoảng trắng hai đầu TRƯỚC `_toKanaIfKnown`.
- flutter_tts web: `setSharedInstance`, `setIosAudioCategory` không có trên web → hiện bị ném trong `init()`/`speak()` làm hỏng đọc. App giờ chỉ build web → xoá hẳn các lời gọi đó (KISS, không rẽ nhánh `kIsWeb`).
- Thang rate: iOS 0–1 (0.5 bình thường), web speechSynthesis 0.1–10 (1 bình thường). Kiểm thực tế flutter_tts web có quy đổi không; nếu không → `webRate = rate * 2`.
- iOS Safari: lần `speak` đầu phải trong cử chỉ người dùng; tự đọc đáp án có thể câm cho tới cú chạm đầu — chấp nhận, ghi chú.
- iOS PWA standalone có thể hỏi quyền mic mỗi phiên — giới hạn của WebKit, ghi vào trang hướng dẫn.

## Requirements
- `SpeechService({http.Client? client, String? sttUrl})` — constructor KHÔNG đụng plugin (test dựng `SpeechService()` trên VM).
- Tách phần gọi STT ra `lib/speech/stt_client.dart` (thuần Dart, test được bằng `MockClient`): map 413/415/429/5xx/mạng lỗi → câu tiếng Việt; parse `{text}`.
- Lỗi quyền mic (`NotAllowedError`) → "Chưa có quyền dùng micro. Bật lại trong cài đặt trang web của trình duyệt."
- Chuỗi hiển thị mới không xưng hô (test `ui_text_style_test`).
- `sttUrl` mặc định `'$apiBase/api/stt'` (dùng chung `apiBase` của sync — DRY; phase 05 đổi default thành `/kotoba-app`).

## Architecture
```
QuizSpeakPanel._listenOnce
  → speech.listen(onLevel, onResult, onError)
      record.start(wav,16k,mono) → amplitude stream → onLevel(dBFS) + bộ dò im lặng
      stop → blob URL → bytes → SttClient.transcribe(bytes,'audio/wav') → POST /kotoba-app/api/stt
      → stripPunctuation → onResult(text, true)
  → _toKanaIfKnown(text) → _heard (cho sửa) → onSubmit → chấm như cũ
```

## Related Code Files
- Sửa: `kotoba/lib/speech/speech_service.dart`, `kotoba/lib/ui/quiz_speak_panel.dart`, `kotoba/lib/ui/settings_screen.dart` (bỏ công tắc + `_probeSpeech`), `kotoba/lib/data/settings_store.dart` (bỏ `offlineSpeech`), `kotoba/pubspec.yaml` (thêm `record`, bỏ `speech_to_text`)
- Tạo: `kotoba/lib/speech/stt_client.dart`, `kotoba/lib/speech/silence_detector.dart` (thuần, test được), `kotoba/test/stt_client_test.dart`, `kotoba/test/silence_detector_test.dart`
- Sửa test nếu tham chiếu `offlineSpeech`/`preferOnDevice` (grep).
- File ownership: phase 05 chạy SAU phase này (cùng `pubspec.yaml`).

## Implementation Steps
1. Spike 30' (làm TRƯỚC): app tối giản ghi WAV bằng `record` trên Chrome desktop + iPhone Safari qua `flutter run -d web-server --web-hostname 0.0.0.0` + tunnel HTTPS (getUserMedia cần secure context; `localhost` ok trên máy, iPhone cần HTTPS — dùng `cloudflared tunnel --url` hoặc deploy tạm). Nếu `record` web hỏng trên iOS → fallback: MediaRecorder qua `package:web` (`audio/mp4` trên Safari, `audio/webm` Chrome — route 03 đã cho cả hai).
2. `stt_client.dart` + test.
3. `silence_detector.dart` (vào: chuỗi dBFS theo thời gian; ra: `shouldStop`, `heardSpeech`) + test.
4. Viết lại `SpeechService`: `init()` = kiểm `hasPermission()`; `listen/stopListening/cancelListening`; giữ `speak/stopSpeaking`, xoá iOS category; xử lý rate web.
5. `QuizSpeakPanel`: bỏ `preferOnDevice`; thêm trạng thái "Đang nhận diện…" giữa dừng ghi và có chữ; bỏ dấu câu trước `_toKanaIfKnown`.
6. Settings: xoá công tắc ngoại tuyến + `offlineSpeech`.
7. `flutter analyze && flutter test`; build web; thử Chrome: nói "せんせい" → hiện せんせい.

## Todo List
- [ ] Spike record web: Chrome OK; iPhone thật chưa test (chuyển sang phase 07 manual)
- [x] SttClient + test
- [x] SilenceDetector + test
- [x] SpeechService viết lại, TTS web chạy (`rate * 2`)
- [x] QuizSpeakPanel + bỏ dấu câu
- [x] Bỏ chế độ ngoại tuyến
- [x] analyze/test xanh
- [ ] Thử Chrome "せんせい" → hiện kana: chưa có bằng chứng E2E mic trong báo cáo smoke (smoke chỉ render/persist/sync)

### Delivery notes
- Done. Gỡ công tắc ngoại tuyến + `offlineSpeech`; bỏ lời gọi iOS audio category khỏi TTS.
- Drift 1: thêm lọc ảo giác Whisper ở mức text (ngoài silence gating). Không đổi API.
- Drift 2: lần ghi đầu mỗi phiên phải chạm (cử chỉ người dùng iOS); bỏ `await` trước `start`. Ghi chú cho trang hướng dẫn.

## Success Criteria
- Chrome desktop: chế độ đọc nghe → hiện chữ kana → sửa được → chấm đúng.
- Im lặng 8 s → không có request nào tới `/kotoba-app/api/stt` (DevTools Network).
- Nút loa đọc tiếng Nhật ở tốc độ gần bản iOS.
- (Phase 07) iPhone Safari + PWA đã cài: mic chạy.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| `record` web/iOS Safari lỗi (AudioWorklet, quyền) | TB | Cao | Spike bước 1; fallback MediaRecorder `package:web` |
| Whisper sai từ đơn ngắn | Cao | TB | Luồng "xem và sửa trước khi chấm" đã có sẵn; tra ngược kana |
| Độ trễ (upload + Groq ~1 s) | TB | Thấp | Trạng thái "Đang nhận diện…" rõ ràng |
| Không có giọng ja-JP (Android thiếu Google TTS) | TB | TB | Báo "Thiết bị chưa có giọng đọc tiếng Nhật" khi `getVoices` không có ja |

## Rollback
Revert phase; app quay lại bản có speech_to_text (không chạy trên web nhưng build được ở bước 02).

## Security Considerations
Chỉ gửi âm thanh khi người dùng đang ở chế độ đọc; không lưu âm thanh phía client; không gửi đáp án lên server.

## Next Steps
05.
