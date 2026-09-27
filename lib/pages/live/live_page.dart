import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/live/domain/live_query.dart';
import '../../features/voice_chat/domain/command_router.dart';
import '../../services/secretary_session.dart';
import '../../shared/api/api_client.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  Future<String> _answer(String text) async {
    final intent = CommandRouter.detect(text);
    switch (intent) {
      case AssistantIntent.exchange:
        final pair = LiveQuery.pairOf(text);
        return ApiClient.exchange(base: pair.base, quote: pair.quote);
      case AssistantIntent.map:
        return ApiClient.place(LiveQuery.placeOf(text));
      case AssistantIntent.weather:
        return ApiClient.weather(LiveQuery.cityOf(text));
      default:
        if (text.contains('환율') || text.contains('달러')) {
          final pair = LiveQuery.pairOf(text);
          return ApiClient.exchange(base: pair.base, quote: pair.quote);
        }
        if (text.contains('어디') || text.contains('지도')) {
          return ApiClient.place(LiveQuery.placeOf(text));
        }
        return ApiClient.weather(LiveQuery.cityOf(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '실시간',
      subtitle: '날씨, 환율, 지도는 말로 이어서 물어볼 수 있어요',
      icon: Icons.public,
      accent: AppTheme.sky,
      child: ConversationBox(
        records: session.ofKind('live'),
        hint: '서울 날씨, 달러 환율, 서울역 어디',
        tint: AppTheme.sky,
        emptyMessage: '날씨, 환율, 지도를 물어보면 대화로 남아요.',
        actions: const [
          TalkAction(label: '날씨', suffix: '날씨'),
          TalkAction(label: '환율', suffix: '환율'),
          TalkAction(label: '지도', suffix: '어디'),
        ],
        onSubmit: (text) => session.replyTurn(
          kind: 'live',
          text: text,
          answer: (text, _) => _answer(text),
        ),
      ),
    );
  }
}
