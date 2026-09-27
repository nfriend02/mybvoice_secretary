import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/conversation/domain/talk_summary.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';
import '../../shared/widgets/scroll_paged_list.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _note;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _summarize() async {
    final text = _controller.text.trim();
    if (!TalkSummary.canSummarize(text) || _busy) return;
    setState(() => _busy = true);
    final session = context.read<SecretarySession>();
    final note = await session.saveTalkSummary(text);
    if (!mounted) return;
    _controller.clear();
    setState(() {
      _busy = false;
      _note = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<SecretarySession>().ofKind('talk');
    return FeatureScaffold(
      title: '대화 요약',
      subtitle: '긴 대화를 몇 문장으로 접어요',
      emoji: '💬',
      accent: AppTheme.mint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(hintText: '대화 내용을 붙여 넣으세요'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FunActionButton(
              label: '요약하기',
              emoji: '✂️',
              busy: _busy,
              onPressed: _summarize,
            ),
          ),
          if (_note != null) ...[const SizedBox(height: 8), Text(_note!)],
          const SizedBox(height: 12),
          Expanded(
            child: ScrollPagedList<SecretaryRecord>(
              items: records,
              emptyMessage: '요약한 대화가 여기에 쌓여요.',
              itemBuilder: (_, record, _) =>
                  RecordTile(record: record, tint: AppTheme.mint),
            ),
          ),
        ],
      ),
    );
  }
}
