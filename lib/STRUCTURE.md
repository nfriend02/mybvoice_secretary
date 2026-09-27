# MYB Voice Secretary — Feature-Sliced Design

```
lib/
├── main.dart                         # Flutter entry (Firebase + runApp)
├── firebase_options.dart             # .env override + built-in project
├── app/                              # router, theme, firebase bootstrap
├── pages/
│   ├── home/home_page.dart
│   ├── voice_chat/voice_chat_page.dart
│   ├── pdf_summary/pdf_summary_page.dart   # class UploadPage
│   ├── conversation/conversation_page.dart
│   ├── rag_search/rag_search_page.dart
│   └── upload/upload_page.dart             # class PortfolioUploadPage
├── features/
│   ├── voice_chat/
│   ├── pdf_summary/
│   ├── conversation/                       # screen lives in pages/
│   └── rag_search/
├── services/
│   ├── firestore_service.dart
│   ├── auth_service.dart
│   └── secretary_session.dart
└── shared/
    ├── api/                          # /api client
    ├── config/
    ├── layouts/                      # LayoutBuilder shell
    ├── widgets/
    └── utils/
```

Import direction: `pages → features → shared`.
`app` and `services` wire the layers together.

API routes live in `api/` (`/api/health`, `/api/summarize`).
