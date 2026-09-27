import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/voice_chat/domain/secretary_reply.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class VoiceChatPage extends StatelessWidget {
  const VoiceChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '음성 비서',
      subtitle: '말하면 정리해 드릴게요.',
      icon: Icons.mic_none,
      accent: AppTheme.neon,
      child: ConversationBox(
        records: session.ofKind('voice'),
        hint: '오늘 할 일을 말하거나 적어 보세요',
        tint: AppTheme.peach,
        emptyMessage: '첫 인사를 남겨 보세요. 이어서 몇 번이든 물어볼 수 있어요.',
        onSubmit: (text) => session.replyTurn(
          kind: 'voice',
          text: text,
          answer: (text, history) async =>
              SecretaryReply.reply(text, earlier: history),
        ),
      ),
    );
  }
}
