class PhraseBook {
  static const koEn = <String, String>{
    '안녕하세요': 'Hello',
    '감사합니다': 'Thank you',
    '회의': 'meeting',
    '내일': 'tomorrow',
    '오늘': 'today',
    '오전': 'morning',
    '오후': 'afternoon',
    '자료': 'document',
    '요약': 'summary',
    '일정': 'schedule',
    '이메일': 'email',
    '번역': 'translation',
    '팀': 'team',
    '공유': 'share',
    '준비': 'preparation',
  };

  static final enKo = {
    for (final entry in koEn.entries) entry.value.toLowerCase(): entry.key,
  };

  static String translate(String raw, {String? from, String? to}) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    final source = from ?? (RegExp('[가-힣]').hasMatch(text) ? 'ko' : 'en');
    final target = to ?? (source == 'ko' ? 'en' : 'ko');
    final map = source == 'ko' && target == 'en'
        ? koEn
        : source == 'en' && target == 'ko'
        ? enKo
        : koEn;
    final keys = map.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    var output = source == 'en' ? text.toLowerCase() : text;
    for (final key in keys) {
      output = output.replaceAll(key, map[key]!);
    }
    if (output == text || output == text.toLowerCase()) {
      return text;
    }
    return output;
  }
}
