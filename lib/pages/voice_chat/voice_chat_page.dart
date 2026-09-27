import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/voice_chat/domain/secretary_reply.dart';
import '../../features/voice_chat/domain/speech_capture.dart';
import '../../services/secretary_session.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';
import '../../shared/widgets/scroll_paged_list.dart';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _note;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final session = context.read<SecretarySession>();
    final userNote = await session.add(kind: 'voice', title: '나', body: text);
    await session.add(
      kind: 'voice',
      title: 'MYB',
      body: SecretaryReply.reply(text),
    );
    if (!mounted) return;
    _controller.clear();
    setState(() {
      _busy = false;
      _note = userNote;
    });
  }

  Future<void> _listen() async {
    setState(() => _note = '듣고 있어요…');
    final transcript = await listenOnce();
    if (!mounted) return;
    if (transcript == null || transcript.isEmpty) {
      setState(() => _note = '이 화면에서는 키보드로 말해 주세요.');
      return;
    }
    _controller.text = transcript;
    await _send(transcript);
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<SecretarySession>().ofKind('voice');
    return FeatureScaffold(
      title: '음성 비서',
      subtitle: '말하면 기록하고, 짧게 대답해요',
      emoji: '🎙️',
      accent: AppTheme.peach,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(hintText: '오늘 할 일을 말해 보세요'),
            onSubmitted: _send,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FunActionButton(
                label: '보내기',
                emoji: '✨',
                busy: _busy,
                onPressed: () => _send(_controller.text),
              ),
              FunActionButton(
                label: '마이크',
                emoji: '🎤',
                onPressed: _busy ? null : _listen,
              ),
            ],
          ),
          if (_note != null) ...[const SizedBox(height: 8), Text(_note!)],
          const SizedBox(height: 12),
          Expanded(
            child: ScrollPagedList<SecretaryRecord>(
              items: records,
              emptyMessage: '첫 인사를 남겨 보세요.',
              itemBuilder: (_, record, _) =>
                  RecordTile(record: record, tint: AppTheme.peach),
            ),
          ),
        ],
      ),
    );
  }
}
