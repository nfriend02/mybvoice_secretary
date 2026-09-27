import 'dart:convert';
import 'dart:typed_data';

/// Pulls visible text from `.txt`, `.md`, and simple uncompressed PDF strings.
class PdfText {
  static String extract(Uint8List bytes, String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.txt') || lower.endsWith('.md')) {
      return utf8.decode(bytes, allowMalformed: true).trim();
    }

    final raw = latin1.decode(bytes);
    final buffer = StringBuffer();
    final pattern = RegExp(r'\((?:\\\)|[^\)]){1,}\)\s*Tj');
    for (final match in pattern.allMatches(raw)) {
      var inner = match.group(0)!;
      inner = inner.replaceFirst(RegExp(r'\)\s*Tj$'), '');
      if (inner.startsWith('(')) inner = inner.substring(1);
      inner = inner
          .replaceAll(r'\(', '(')
          .replaceAll(r'\)', ')')
          .replaceAll(r'\n', ' ');
      final cleaned = inner.replaceAll(RegExp(r'[^A-Za-z0-9가-힣 .,!?]'), ' ');
      if (cleaned.trim().length >= 2) buffer.write('${cleaned.trim()} ');
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
