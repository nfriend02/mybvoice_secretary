import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/api/api_client.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class MailPage extends StatelessWidget {
  const MailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '메일',
      subtitle: '말로 전하면 짧은 이메일 초안이 카드로 나와요',
      icon: Icons.mail_outline,
      accent: AppTheme.peach,
      child: ConversationBox(
        records: session.ofKind('mail'),
        hint: '내일 회의 자료를 팀에 공유하는 메일 써줘',
        tint: AppTheme.peach,
        emptyMessage: '아직 초안이 없어요. 이어서 톤을 바꿔 달라고 할 수 있어요.',
        actions: const [TalkAction(label: '초안 만들기')],
        onSubmit: (text) => session.replyTurn(
          kind: 'mail',
          text: text,
          answer: (text, history) {
            final source = history.isEmpty ? text : '$history\n$text';
            return ApiClient.draftEmail(source);
          },
        ),
      ),
    );
  }
}
