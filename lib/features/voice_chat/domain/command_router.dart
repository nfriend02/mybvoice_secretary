enum AssistantIntent {
  weather,
  exchange,
  map,
  schedule,
  mail,
  translate,
  workflow,
  learn,
  voice,
}

class CommandRouter {
  static AssistantIntent detect(String raw) {
    final text = raw.toLowerCase();
    if (text.contains('날씨')) return AssistantIntent.weather;
    if (text.contains('환율') || text.contains('달러') || text.contains('엔화')) {
      return AssistantIntent.exchange;
    }
    if (text.contains('지도') || text.contains('어디') || text.contains('길찾')) {
      return AssistantIntent.map;
    }
    if (text.contains('퀴즈') || text.contains('플래시') || text.contains('학습')) {
      return AssistantIntent.learn;
    }
    if (text.contains('회의록') ||
        text.contains('노션') ||
        text.contains('notion') ||
        text.contains('워크플로')) {
      return AssistantIntent.workflow;
    }
    if (text.contains('번역') || text.contains('영어로') || text.contains('한국어로')) {
      return AssistantIntent.translate;
    }
    if (text.contains('메일') || text.contains('이메일') || text.contains('메시지')) {
      return AssistantIntent.mail;
    }
    if (text.contains('일정') ||
        text.contains('회의') ||
        text.contains('캘린더') ||
        text.contains('아웃룩') ||
        text.contains('알려')) {
      return AssistantIntent.schedule;
    }
    return AssistantIntent.voice;
  }

  static String routeFor(AssistantIntent intent) {
    return switch (intent) {
      AssistantIntent.weather => '/live',
      AssistantIntent.exchange => '/live',
      AssistantIntent.map => '/live',
      AssistantIntent.schedule => '/schedule',
      AssistantIntent.mail => '/mail',
      AssistantIntent.translate => '/translate',
      AssistantIntent.workflow => '/workflow',
      AssistantIntent.learn => '/learn',
      AssistantIntent.voice => '/voice',
    };
  }
}
