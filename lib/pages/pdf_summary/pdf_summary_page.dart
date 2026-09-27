import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../features/pdf_summary/domain/pdf_text.dart';
import '../../services/secretary_session.dart';
import '../../shared/utils/pick_files.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';
import '../../shared/widgets/scroll_paged_list.dart';

/// PDF upload example: pick a file, summarize, store metadata in Firestore.
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _busy = false;
  String? _note;

  Future<void> _pick() async {
    final picked = await pickDocument();
    if (!mounted || picked.isEmpty) return;
    final file = picked.first;
    setState(() {
      _busy = true;
      _note = '요약하는 중…';
    });
    final text = PdfText.extract(file.bytes, file.name);
    final session = context.read<SecretarySession>();
    final note = await session.savePdfSummary(fileName: file.name, text: text);
    await session.add(
      kind: 'upload',
      title: file.name,
      body: 'PDF 메타데이터 · ${file.bytes.length} bytes',
      status: 'uploaded',
      extra: {'size': file.bytes.length},
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<SecretarySession>().ofKind('pdf');
    return FeatureScaffold(
      title: 'PDF 요약',
      subtitle: '파일을 올리면 핵심 문장을 남겨요',
      emoji: '📄',
      accent: AppTheme.sky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FunActionButton(
            label: 'PDF 올리기',
            emoji: '📎',
            busy: _busy,
            onPressed: _pick,
          ),
          if (_note != null) ...[const SizedBox(height: 8), Text(_note!)],
          const SizedBox(height: 12),
          Expanded(
            child: ScrollPagedList<SecretaryRecord>(
              items: records,
              emptyMessage: '아직 요약한 PDF가 없어요.',
              itemBuilder: (_, record, _) =>
                  RecordTile(record: record, tint: AppTheme.sky),
            ),
          ),
        ],
      ),
    );
  }
}
