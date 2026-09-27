import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/pdf_summary/domain/pdf_text.dart';
import '../../services/secretary_session.dart';
import '../../shared/utils/pick_files.dart';
import '../../shared/utils/text_tools.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';

/// PDF upload example: pick a file or describe it, then keep asking.
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _busy = false;

  Future<void> _pick() async {
    final picked = await pickDocument();
    if (!mounted || picked.isEmpty) return;
    final file = picked.first;
    setState(() => _busy = true);
    final extracted = PdfText.extract(file.bytes, file.name);
    final session = context.read<SecretarySession>();
    await session.replyTurn(
      kind: 'pdf',
      text: '${file.name} 요약해줘',
      answer: (text, history) async {
        final source = extracted.trim().isEmpty
            ? '파일 ${file.name} 을 받았어요. 본문 텍스트는 추출되지 않았어요.'
            : extracted.trim();
        final summary = await session.summarize(
          history.isEmpty ? source : '$history\n$source',
        );
        for (final chunk in textChunks(extracted)) {
          await session.add(
            kind: 'rag',
            title: file.name,
            body: chunk,
            input: text,
            output: chunk,
          );
        }
        await session.add(
          kind: 'upload',
          title: file.name,
          body: 'PDF 메타데이터 · ${file.bytes.length} bytes',
          status: 'uploaded',
          input: text,
          output: 'PDF 메타데이터 · ${file.bytes.length} bytes',
          extra: {'size': file.bytes.length},
        );
        return summary;
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();
    return FeatureScaffold(
      title: 'PDF 요약',
      subtitle: '파일을 올리거나, 본문을 말하며 이어서 물어볼 수 있어요',
      icon: Icons.description_outlined,
      accent: AppTheme.sky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FunActionButton(
              label: 'PDF 올리기',
              emoji: '📎',
              busy: _busy,
              onPressed: _busy ? null : _pick,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ConversationBox(
              records: session.ofKind('pdf'),
              hint: '요약할 문장을 붙여 넣거나 말해 보세요',
              tint: AppTheme.sky,
              emptyMessage: '아직 요약한 PDF가 없어요.',
              onSubmit: (text) => session.replyTurn(
                kind: 'pdf',
                text: text,
                answer: (text, history) async {
                  final source = history.isEmpty ? text : '$history\n$text';
                  final summary = await session.summarize(source);
                  for (final chunk in textChunks(text)) {
                    await session.add(
                      kind: 'rag',
                      title: 'PDF 대화',
                      body: chunk,
                      input: text,
                      output: chunk,
                    );
                  }
                  return summary.isEmpty ? text : summary;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
