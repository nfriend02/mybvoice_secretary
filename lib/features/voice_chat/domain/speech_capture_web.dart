import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS()
extension type _Speech._(JSObject _) implements JSObject {
  external set lang(JSString value);
  external set interimResults(JSBoolean value);
  external void start();
  external void stop();
  external set onresult(JSFunction? fn);
  external set onerror(JSFunction? fn);
  external set onend(JSFunction? fn);
}

extension type _ResultEvent._(JSObject _) implements JSObject {
  external _ResultList get results;
}

extension type _ResultList._(JSObject _) implements JSObject {
  external _Result item(int index);
}

extension type _Result._(JSObject _) implements JSObject {
  external _Alternative item(int index);
}

extension type _Alternative._(JSObject _) implements JSObject {
  external String get transcript;
}

Future<String?> listenOnceImpl() async {
  final ctor =
      globalContext['SpeechRecognition'] ??
      globalContext['webkitSpeechRecognition'];
  if (ctor == null || !ctor.isA<JSFunction>()) return null;

  final speech = _Speech._((ctor as JSFunction).callAsConstructor<JSObject>());
  final completer = Completer<String?>();

  speech.lang = 'ko-KR'.toJS;
  speech.interimResults = false.toJS;
  speech.onresult = ((JSObject event) {
    try {
      final transcript = _ResultEvent._(event).results
          .item(0)
          .item(0)
          .transcript;
      if (!completer.isCompleted) completer.complete(transcript.trim());
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }
  }).toJS;
  speech.onerror = ((JSObject _) {
    if (!completer.isCompleted) completer.complete(null);
  }).toJS;
  speech.onend = ((JSObject _) {
    if (!completer.isCompleted) completer.complete(null);
  }).toJS;

  try {
    speech.start();
  } catch (_) {
    return null;
  }

  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () {
      try {
        speech.stop();
      } catch (_) {}
      return null;
    },
  );
}
