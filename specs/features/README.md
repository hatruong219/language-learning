# Features

Mỗi tính năng lớn có 1 thư mục riêng. Cấu trúc chuẩn:

```
features/
└── <feature-name>/
    ├── spec.md          ← DB schema, components, routes, types, API
    └── data-sources.md  ← nguồn data, workflow seed (nếu cần)
```

## Danh sách features

| Thư mục | Tính năng | Route |
|---------|-----------|-------|
| [mnn-lessons/](mnn-lessons/) | みんなの日本語 — học theo giáo trình | `/lessons` |
| [writing-test/](writing-test/) | Luyện viết AI chấm điểm (Groq) | `/writing-test` |
