class StudyCard {
  const StudyCard({required this.prompt, required this.answer});

  final String prompt;
  final String answer;

  String get fileText => 'Q. $prompt\nA. $answer';
}

class StudyPack {
  static List<StudyCard> fromTexts(Iterable<String> sources, {int limit = 8}) {
    final cards = <StudyCard>[];
    final seen = <String>{};
    for (final source in sources) {
      final sentences = source
          .split(RegExp(r'(?<=[.!?。])\s+|\n+'))
          .map((part) => part.trim())
          .where((part) => part.length >= 4);
      for (final sentence in sentences) {
        final match = RegExp(r'[A-Za-z0-9가-힣]{2,}').firstMatch(sentence);
        if (match == null) continue;
        final answer = match.group(0)!;
        final prompt = sentence.replaceFirst(answer, '___');
        if (!seen.add(prompt)) continue;
        cards.add(StudyCard(prompt: prompt, answer: answer));
        if (cards.length >= limit) return cards;
      }
    }
    return cards;
  }
}
