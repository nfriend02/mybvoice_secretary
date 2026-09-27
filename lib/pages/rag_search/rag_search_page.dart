import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/rag_search/domain/rag_ranker.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';
import '../../shared/widgets/scroll_paged_list.dart';

class RagSearchPage extends StatefulWidget {
  const RagSearchPage({super.key});

  @override
  State<RagSearchPage> createState() => _RagSearchPageState();
}

class _RagSearchPageState extends State<RagSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<SecretarySession>().ofKind('rag');
    final hits = RagRanker.rank(_query, docs);
    return FeatureScaffold(
      title: 'RAG 검색',
      subtitle: '저장해 둔 문장 안에서 찾아요',
      emoji: '🔍',
      accent: AppTheme.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: '찾고 싶은 단어를 입력'),
            onSubmitted: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FunActionButton(
              label: '찾아보기',
              emoji: '🌈',
              onPressed: () => setState(() => _query = _controller.text.trim()),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ScrollPagedList<RankedHit>(
              items: hits,
              emptyMessage: _query.isEmpty
                  ? 'PDF나 대화를 요약하면 검색 재료가 생겨요.'
                  : '이 단어와 겹치는 기록이 없어요.',
              itemBuilder: (_, hit, _) =>
                  RecordTile(record: hit.record, tint: AppTheme.lavender),
            ),
          ),
        ],
      ),
    );
  }
}
