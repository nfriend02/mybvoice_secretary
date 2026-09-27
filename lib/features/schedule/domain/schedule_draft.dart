class ScheduleDraft {
  const ScheduleDraft({
    required this.title,
    required this.whenLabel,
    required this.when,
    required this.channel,
  });

  final String title;
  final String whenLabel;
  final DateTime when;

  /// `device`, `google`, or `outlook`.
  final String channel;

  String get channelLabel {
    switch (channel) {
      case 'google':
        return 'Google Calendar에 넣을 일정';
      case 'outlook':
        return 'Outlook에 넣을 일정';
      default:
        return '기기 알림';
    }
  }

  String get cardBody {
    return '$whenLabel\n$channelLabel\n$title\n\n캘린더 파일로 가져갈 수 있어요.\n\n$ics';
  }

  String get ics {
    final stamp = _stamp(when);
    final summary = title.replaceAll('\n', ' ');
    return 'BEGIN:VCALENDAR\n'
        'VERSION:2.0\n'
        'PRODID:-//MYB Voice Secretary//KO\n'
        'BEGIN:VEVENT\n'
        'DTSTART:$stamp\n'
        'SUMMARY:$summary\n'
        'END:VEVENT\n'
        'END:VCALENDAR';
  }

  static ScheduleDraft parse(String raw, {DateTime? now}) {
    final text = raw.trim();
    final clock = now ?? DateTime.now();
    final time = RegExp(
      r'(오늘|내일|모레)?\s*(오전|오후)?\s*(\d{1,2})\s*시(?:\s*(\d{1,2})\s*분)?',
    ).firstMatch(text);

    var day = clock;
    var whenLabel = '내일 오전 9시';
    var hour = 9;
    var minute = 0;
    if (time != null) {
      final dayWord = time.group(1);
      final meridiem = time.group(2);
      hour = int.parse(time.group(3)!);
      minute = int.tryParse(time.group(4) ?? '') ?? 0;
      if (meridiem == '오후' && hour < 12) hour += 12;
      if (meridiem == '오전' && hour == 12) hour = 0;
      hour = hour.clamp(0, 23);
      minute = minute.clamp(0, 59);
      final offset = switch (dayWord) {
        '오늘' => 0,
        '모레' => 2,
        _ => 1,
      };
      day = DateTime(clock.year, clock.month, clock.day + offset, hour, minute);
      final dayLabel = dayWord ?? '내일';
      final hourLabel = hour == 0
          ? 12
          : hour > 12
          ? hour - 12
          : hour;
      final ampm = hour < 12 ? '오전' : '오후';
      final minuteLabel = minute == 0 ? '' : ' $minute분';
      whenLabel = '$dayLabel $ampm $hourLabel시$minuteLabel';
    } else {
      day = DateTime(clock.year, clock.month, clock.day + 1, 9);
    }

    final channel =
        text.contains('아웃룩') || text.toLowerCase().contains('outlook')
        ? 'outlook'
        : text.contains('구글') ||
              text.toLowerCase().contains('google') ||
              text.contains('캘린더')
        ? 'google'
        : 'device';

    var title = text;
    title = title.replaceAll(
      RegExp(
        r'오늘|내일|모레|오전|오후|\d{1,2}\s*시|\d{1,2}\s*분|알려\s*줘|추가해\s*줘|등록해\s*줘|잡아\s*줘|해\s*줘|일정|구글|캘린더|아웃룩|outlook|google',
        caseSensitive: false,
      ),
      ' ',
    );
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    title = title.replaceAll(RegExp(r'^[에은는을를의\s]+|[에은는을를의\s]+$'), '');
    if (title.length < 2) title = '새 일정';

    return ScheduleDraft(
      title: title,
      whenLabel: whenLabel,
      when: day,
      channel: channel,
    );
  }

  static String _stamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}T${two(time.hour)}${two(time.minute)}00';
  }
}
