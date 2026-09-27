import 'package:flutter/services.dart';

Future<String> saveTextFileImpl(String filename, String content) async {
  await Clipboard.setData(ClipboardData(text: content));
  return '클립보드에 복사했어요';
}
