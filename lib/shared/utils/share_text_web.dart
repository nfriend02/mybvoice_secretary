import 'package:web/web.dart' as web;

Future<String> saveTextFileImpl(String filename, String content) async {
  final anchor = web.HTMLAnchorElement()
    ..href = 'data:text/plain;charset=utf-8,${Uri.encodeComponent(content)}'
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return '파일을 저장했어요';
}
