import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/config/app_config.dart';
import '../../shared/utils/pick_files.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';
import '../../shared/widgets/scroll_paged_list.dart';

class PortfolioUploadPage extends StatefulWidget {
  const PortfolioUploadPage({super.key});

  @override
  State<PortfolioUploadPage> createState() => _PortfolioUploadPageState();
}

class _PortfolioUploadPageState extends State<PortfolioUploadPage> {
  bool _busy = false;
  String? _note;

  Future<void> _pick() async {
    final picked = await pickDocument();
    if (!mounted || picked.isEmpty) return;
    final file = picked.first;
    setState(() => _busy = true);
    final meta = AppConfig.uploadChecklistMeta();
    final note = await context.read<SecretarySession>().add(
      kind: 'upload',
      title: file.name,
      body: '업로드 체크리스트와 함께 저장',
      status: 'uploaded',
      extra: {'size': file.bytes.length, 'meta': meta},
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = AppConfig.uploadChecklistMeta();
    final firebaseReady = context.watch<bool>();
    final records = context.watch<SecretarySession>().ofKind('upload');
    final checks = <(String, String, bool)>[
      (
        'Github branch URL',
        meta['githubBranchUrl'] ?? '',
        (meta['githubBranchUrl'] ?? '').startsWith('http'),
      ),
      ('아이콘 이미지', meta['iconUrl'] ?? '', (meta['iconUrl'] ?? '').isNotEmpty),
      (
        '설명 200자 이내',
        '${(meta['description'] ?? '').length}/200',
        (meta['description'] ?? '').length <= 200,
      ),
      ('제작자 이름/팀명', meta['author'] ?? '', (meta['author'] ?? '').isNotEmpty),
      ('Firebase 연결', firebaseReady ? '연결됨' : '데모', firebaseReady),
    ];

    return FeatureScaffold(
      title: '업로드',
      subtitle: '전시 체크리스트와 파일 메타데이터',
      emoji: '☁️',
      accent: AppTheme.butter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.card(tint: AppTheme.butter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta['title'] ?? AppConfig.defaultTitle,
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meta['description'] ?? '',
                  style: GoogleFonts.notoSansKr(),
                ),
                const SizedBox(height: 12),
                for (final check in checks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          check.$3
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: check.$3
                              ? const Color(0xFF2E9B6A)
                              : AppTheme.muted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${check.$1} · ${check.$2}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansKr(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                FunActionButton(
                  label: '파일 메타데이터 저장',
                  emoji: '🚀',
                  busy: _busy,
                  onPressed: _pick,
                ),
                if (_note != null) ...[
                  const SizedBox(height: 8),
                  Text(_note!, style: GoogleFonts.notoSansKr()),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ScrollPagedList<SecretaryRecord>(
              items: records,
              emptyMessage: '올린 파일 기록이 여기에 모여요.',
              itemBuilder: (_, record, _) =>
                  RecordTile(record: record, tint: AppTheme.butter),
            ),
          ),
        ],
      ),
    );
  }
}
