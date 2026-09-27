class MailDraft {
  const MailDraft({required this.subject, required this.body});

  final String subject;
  final String body;

  String get fileText => 'Subject: $subject\n\n$body';

  static MailDraft compose(String raw) {
    var cleaned = raw.trim();
    cleaned = cleaned.replaceAll(
      RegExp(r'이메일|메일|메시지|초안|작성해\s*줘|보내\s*줘|써\s*줘'),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) cleaned = '오늘 논의한 내용을 공유합니다.';
    final subject = cleaned.length > 32
        ? '${cleaned.substring(0, 32)}…'
        : cleaned;
    final body =
        '안녕하세요.\n\n'
        '$cleaned\n\n'
        '필요한 내용만 짧게 정리했습니다.\n'
        '확인 부탁드립니다.';
    return MailDraft(subject: subject, body: body);
  }
}
