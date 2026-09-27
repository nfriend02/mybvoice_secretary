import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/schedule/domain/schedule_draft.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '일정',
      subtitle: '말하면 알림으로 남기고, 캘린더 파일로 가져가요',
      icon: Icons.event_outlined,
      accent: AppTheme.deepBlue,
      child: ConversationBox(
        records: session.ofKind('schedule'),
        hint: '내일 오전 10시에 회의 준비 알려줘',
        tint: AppTheme.deepBlue,
        emptyMessage: '아직 일정이 없어요. 시간을 말해 보세요.',
        actions: const [
          TalkAction(label: '알림 저장'),
          TalkAction(label: 'Google', suffix: '구글 캘린더'),
          TalkAction(label: 'Outlook', suffix: '아웃룩'),
        ],
        onSubmit: (text) => session.replyTurn(
          kind: 'schedule',
          text: text,
          answer: (text, history) async {
            final source = text.length < 18 && history.isNotEmpty
                ? '$history\n$text'
                : text;
            return ScheduleDraft.parse(source).cardBody;
          },
        ),
      ),
    );
  }
}
