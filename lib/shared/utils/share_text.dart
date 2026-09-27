import 'share_text_stub.dart'
    if (dart.library.js_interop) 'share_text_web.dart'
    as impl;

/// Saves a text card. Web downloads a file; other targets copy it.
Future<String> saveTextFile(String filename, String content) {
  return impl.saveTextFileImpl(filename, content);
}
