import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/learn/domain/study_pack.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '학습',
      subtitle: '올려 둔 문장으로 퀴즈와 플래시카드를 만들어요',
      icon: Icons.school_outlined,
      accent: AppTheme.lavender,
      child: ConversationBox(
        records: session.ofKind('learn'),
        hint: '이 내용으로 퀴즈를 더 만들어줘',
        tint: AppTheme.lavender,
        emptyMessage: 'PDF나 대화 요약을 남긴 뒤 퀴즈를 말해 보세요.',
        actions: const [TalkAction(label: '퀴즈 만들기', suffix: '학습 퀴즈 만들어줘')],
        onSubmit: (text) => session.replyTurn(
          kind: 'learn',
          text: text,
          answer: (text, history) async {
            final sources = [
              ...session.records
                  .where(
                    (record) =>
                        record.kind == 'pdf' ||
                        record.kind == 'talk' ||
                        record.kind == 'rag',
                  )
                  .map((record) => record.body),
              if (history.isNotEmpty) history,
              text,
            ];
            final cards = StudyPack.fromTexts(sources);
            if (cards.isEmpty) {
              return 'PDF나 대화 요약을 먼저 남기면 퀴즈를 만들 수 있어요.';
            }
            return cards.map((card) => card.fileText).join('\n\n');
          },
        ),
      ),
    );
  }
}
