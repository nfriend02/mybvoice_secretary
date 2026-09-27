import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/workflow/domain/workflow_bundle.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class WorkflowPage extends StatelessWidget {
  const WorkflowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '워크플로',
      subtitle: '회의록을 요약해 메일로, 노트는 마크다운으로',
      icon: Icons.account_tree_outlined,
      accent: AppTheme.neon,
      child: ConversationBox(
        records: session.ofKind('workflow'),
        hint: '정리할 회의 내용을 말하거나 붙여 넣으세요',
        tint: AppTheme.neon,
        emptyMessage: '공유 카드가 여기에 모여요. 이어서 다시 정리할 수 있어요.',
        actions: const [
          TalkAction(label: '회의록 공유', suffix: '회의록 정리해서 팀에 공유해줘'),
          TalkAction(label: 'Notion 노트', suffix: 'Notion에 저장해줘'),
        ],
        onSubmit: (text) => session.replyTurn(
          kind: 'workflow',
          text: text,
          answer: (text, history) async {
            final prior = session.records
                .where(
                  (record) =>
                      record.kind == 'talk' ||
                      record.kind == 'pdf' ||
                      record.kind == 'voice',
                )
                .take(4)
                .map((record) => record.body)
                .join('\n');
            final source = text.trim().length < 24 && prior.isNotEmpty
                ? prior
                : (history.isEmpty ? text : '$history\n$text');
            final summary = await session.summarize(source);
            final bundle = WorkflowBundle.build(
              source: source,
              summary: summary,
            );
            final notion =
                text.contains('노션') || text.toLowerCase().contains('notion');
            if (!notion) {
              await session.add(
                kind: 'mail',
                title: '회의록 메일',
                body: bundle.mail,
                input: text,
                output: bundle.mail,
              );
            }
            return notion
                ? bundle.notion
                : '${bundle.summary}\n\n${bundle.mail}';
          },
        ),
      ),
    );
  }
}
