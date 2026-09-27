import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/api/api_client.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  bool _toEnglish = true;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: '번역',
      subtitle: '기본 어휘로 바로 옮기고, 이어서 다시 물어볼 수 있어요',
      icon: Icons.translate,
      accent: AppTheme.mint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('한국어 → EN')),
              ButtonSegment(value: false, label: Text('EN → 한국어')),
            ],
            selected: {_toEnglish},
            onSelectionChanged: (value) =>
                setState(() => _toEnglish = value.first),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ConversationBox(
              records: session.ofKind('translate'),
              hint: '안녕하세요. 내일 회의 자료를 공유합니다.',
              tint: AppTheme.mint,
              emptyMessage: '번역할 문장을 말하거나 적어 보세요.',
              onSubmit: (text) => session.replyTurn(
                kind: 'translate',
                text: text,
                answer: (text, _) => ApiClient.translate(
                  text,
                  from: _toEnglish ? 'ko' : 'en',
                  to: _toEnglish ? 'en' : 'ko',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
