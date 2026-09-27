import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/voice_chat/domain/speech_capture.dart';
import '../../services/secretary_session.dart';
import 'feature_scaffold.dart';

/// Fixed voice entry shown on every screen.
class VoiceDock extends StatefulWidget {
  const VoiceDock({super.key});

  @override
  State<VoiceDock> createState() => _VoiceDockState();
}

class _VoiceDockState extends State<VoiceDock> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final outcome = await context.read<SecretarySession>().applyCommand(text);
    if (!mounted) return;
    _controller.clear();
    setState(() => _busy = false);
    context.go(outcome.route);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(outcome.message)));
  }

  Future<void> _listen() async {
    setState(() => _busy = true);
    final transcript = await listenOnce();
    if (!mounted) return;
    setState(() => _busy = false);
    if (transcript == null || transcript.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이 화면에서는 아래 칸에 입력해 주세요.')));
      return;
    }
    _controller.text = transcript;
    await _submit(transcript);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('voice-dock'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(10, 0, 8, 8),
      decoration: AppTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: RecordDeleteButton(),
          ),
          Row(
            children: [
              const Icon(Icons.mic_none, color: AppTheme.neon),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 2,
                  style: GoogleFonts.notoSansKr(color: AppTheme.ink),
                  decoration: const InputDecoration(
                    hintText: '말하면 정리해 드릴게요.',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: _submit,
                ),
              ),
              IconButton(
                tooltip: '음성 입력',
                onPressed: _busy ? null : _listen,
                icon: const Icon(Icons.keyboard_voice_outlined),
              ),
              IconButton(
                tooltip: '보내기',
                onPressed: _busy ? null : () => _submit(_controller.text),
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
    );
  }
}
