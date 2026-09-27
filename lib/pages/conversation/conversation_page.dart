import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/utils/text_tools.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '대화 요약',
      subtitle: '대화는 기록되고, 언제든 요약할 수 있습니다.',
      icon: Icons.notes_outlined,
      accent: AppTheme.mint,
      child: ConversationBox(
        records: session.ofKind('talk'),
        hint: '대화 내용을 붙여 넣거나 말해 보세요',
        tint: AppTheme.mint,
        emptyMessage: '요약한 대화가 여기에 쌓여요. 이어서 더 물어볼 수 있어요.',
        onSubmit: (text) => session.replyTurn(
          kind: 'talk',
          text: text,
          answer: (text, history) async {
            final source = history.isEmpty ? text : '$history\n$text';
            final summary = await session.summarize(source);
            for (final chunk in textChunks(text)) {
              await session.add(
                kind: 'rag',
                title: '대화',
                body: chunk,
                input: text,
                output: chunk,
              );
            }
            return summary.isEmpty ? text.trim() : summary;
          },
        ),
      ),
    );
  }
}
