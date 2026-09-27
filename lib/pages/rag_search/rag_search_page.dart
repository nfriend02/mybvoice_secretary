import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/rag_search/domain/rag_ranker.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';

class RagSearchPage extends StatelessWidget {
  const RagSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    final thread = session
        .ofKind('rag')
        .where((record) => record.title == '나' || record.title == 'MYB')
        .toList();
    final docs = session
        .ofKind('rag')
        .where((record) => record.title != '나' && record.title != 'MYB')
        .toList();
    return FeatureScaffold(
      title: 'RAG 검색',
      subtitle: '필요한 정보를 빠르게 찾아드립니다.',
      icon: Icons.search,
      accent: AppTheme.lavender,
      child: ConversationBox(
        records: thread,
        hint: '찾고 싶은 내용을 말하거나 적어 보세요',
        tint: AppTheme.lavender,
        emptyMessage: 'PDF나 대화를 요약하면 검색 재료가 생겨요.',
        onSubmit: (text) => session.replyTurn(
          kind: 'rag',
          text: text,
          answer: (text, history) async {
            final hits = RagRanker.rank(text, docs);
            if (hits.isEmpty) {
              final follow = history.isEmpty
                  ? ''
                  : '\n\n이전 검색도 이어서 봤지만 겹치는 문장이 없어요.';
              return '이 단어와 겹치는 기록이 없어요.$follow';
            }
            return hits
                .take(3)
                .map((hit) => '${hit.record.title}\n${hit.record.body}')
                .join('\n\n');
          },
        ),
      ),
    );
  }
}
