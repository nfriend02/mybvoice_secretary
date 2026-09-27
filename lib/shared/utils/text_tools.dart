List<String> tokenize(String text) {
  return RegExp(r'[A-Za-z0-9가-힣]{2,}')
      .allMatches(text.toLowerCase())
      .map((match) => match.group(0)!)
      .toList();
}

/// Splits long text into short chunks stored for RAG search.
List<String> textChunks(String text, {int size = 280}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const [];
  final sentences = trimmed
      .split(RegExp(r'(?<=[.!?。])\s+|\n+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (sentences.isEmpty) return [trimmed];

  final chunks = <String>[];
  final buffer = StringBuffer();
  for (final sentence in sentences) {
    if (buffer.length + sentence.length > size && buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
      buffer.clear();
    }
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(sentence);
  }
  if (buffer.isNotEmpty) chunks.add(buffer.toString().trim());
  return chunks;
}
