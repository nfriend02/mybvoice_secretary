class LiveQuery {
  static String cityOf(String raw) {
    final text = raw
        .replaceAll(RegExp(r'날씨|알려\s*줘|어때|오늘|지금'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text.isEmpty ? 'Seoul' : text;
  }

  static ({String base, String quote}) pairOf(String raw) {
    final found = <String>[];
    var rest = raw;
    const aliases = <(String, String)>[
      ('엔화', 'JPY'),
      ('유로', 'EUR'),
      ('위안', 'CNY'),
      ('달러', 'USD'),
      ('원화', 'KRW'),
      ('엔', 'JPY'),
      ('원', 'KRW'),
    ];
    for (final alias in aliases) {
      if (rest.contains(alias.$1)) {
        found.add(alias.$2);
        rest = rest.replaceAll(alias.$1, ' ');
      }
    }
    for (final match in RegExp(
      r'\b(USD|KRW|JPY|EUR|CNY)\b',
      caseSensitive: false,
    ).allMatches(raw)) {
      final code = match.group(0)!.toUpperCase();
      if (!found.contains(code)) found.add(code);
    }
    if (found.length >= 2) {
      return (base: found[0], quote: found[1]);
    }
    if (found.length == 1) {
      return found.first == 'KRW'
          ? (base: 'USD', quote: 'KRW')
          : (base: found.first, quote: 'KRW');
    }
    return (base: 'USD', quote: 'KRW');
  }

  static String placeOf(String raw) {
    final text = raw
        .replaceAll(RegExp(r'지도|어디|위치|길\s*찾(?:기|아)|알려\s*줘|찾아\s*줘'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text.isEmpty ? '서울' : text;
  }
}
