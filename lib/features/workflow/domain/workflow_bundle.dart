import '../../mail/domain/mail_draft.dart';

class WorkflowBundle {
  const WorkflowBundle({
    required this.summary,
    required this.mail,
    required this.notion,
  });

  final String summary;
  final String mail;
  final String notion;

  static WorkflowBundle build({
    required String source,
    required String summary,
  }) {
    final note = summary.trim().isEmpty ? source.trim() : summary.trim();
    return WorkflowBundle(
      summary: note,
      mail: MailDraft.compose(note).fileText,
      notion: '# 회의 노트\n\n$note\n\n## 원문\n\n${source.trim()}',
    );
  }
}
