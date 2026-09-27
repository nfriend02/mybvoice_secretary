import 'speech_capture_stub.dart'
    if (dart.library.js_interop) 'speech_capture_web.dart'
    as impl;

/// One-shot speech transcript. Returns null when the browser cannot listen.
Future<String?> listenOnce() => impl.listenOnceImpl();
