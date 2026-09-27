import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../../features/voice_chat/domain/speech_capture.dart';
import '../../services/secretary_session.dart';
import 'feature_scaffold.dart';
import 'scroll_paged_list.dart';

/// A shortcut shown above the text field. [suffix] is added to the typed text.
class TalkAction {
  const TalkAction({required this.label, this.suffix = ''});

  final String label;
  final String suffix;
}

/// Multi-turn thread with a type-or-speak field and a delete control.
class ConversationBox extends StatefulWidget {
  const ConversationBox({
    super.key,
    required this.records,
    required this.hint,
    required this.tint,
    required this.onSubmit,
    this.actions = const [],
    this.emptyMessage = '타이핑하거나 마이크로 이어서 물어보세요.',
  });

  final List<SecretaryRecord> records;
  final String hint;
  final Color tint;
  final Future<void> Function(String text) onSubmit;
  final List<TalkAction> actions;
  final String emptyMessage;

  @override
  State<ConversationBox> createState() => _ConversationBoxState();
}

class _ConversationBoxState extends State<ConversationBox> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({String suffix = ''}) async {
    final text = '${_controller.text} $suffix'.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    await widget.onSubmit(text);
    if (!mounted) return;
    _controller.clear();
    setState(() => _busy = false);
  }

  Future<void> _listen() async {
    if (_busy) return;
    setState(() => _busy = true);
    final transcript = await listenOnce();
    if (!mounted) return;
    if (transcript == null || transcript.trim().isEmpty) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이 화면에서는 칸에 직접 입력해 주세요.')));
      return;
    }
    _controller.text = transcript.trim();
    setState(() => _busy = false);
    await _send();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('talk-input'),
          padding: const EdgeInsets.fromLTRB(10, 4, 8, 8),
          decoration: AppTheme.card(tint: widget.tint),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: RecordDeleteButton(),
              ),
              if (widget.actions.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final action in widget.actions)
                      ActionChip(
                        label: Text(action.label),
                        onPressed: _busy
                            ? null
                            : () => _send(suffix: action.suffix),
                      ),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: GoogleFonts.notoSansKr(color: AppTheme.ink),
                      decoration: InputDecoration(hintText: widget.hint),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    tooltip: '음성 입력',
                    onPressed: _busy ? null : _listen,
                    icon: const Icon(Icons.keyboard_voice_outlined),
                  ),
                  IconButton(
                    tooltip: '보내기',
                    onPressed: _busy ? null : () => _send(),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ScrollPagedList<SecretaryRecord>(
            items: widget.records,
            emptyMessage: widget.emptyMessage,
            itemBuilder: (_, record, _) =>
                RecordTile(record: record, tint: widget.tint),
          ),
        ),
      ],
    );
  }
}
