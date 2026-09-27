import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/config/app_config.dart';
import '../../shared/utils/pick_files.dart';
import '../../shared/widgets/conversation_box.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/fun_feature_button.dart';

class PortfolioUploadPage extends StatefulWidget {
  const PortfolioUploadPage({super.key});

  @override
  State<PortfolioUploadPage> createState() => _PortfolioUploadPageState();
}

class _PortfolioUploadPageState extends State<PortfolioUploadPage> {
  bool _busy = false;

  Future<void> _pick() async {
    final picked = await pickDocument();
    if (!mounted || picked.isEmpty) return;
    final file = picked.first;
    setState(() => _busy = true);
    final meta = AppConfig.uploadChecklistMeta();
    final session = context.read<SecretarySession>();
    await session.replyTurn(
      kind: 'upload',
      text: '${file.name} 저장해줘',
      answer: (text, _) async {
        await session.add(
          kind: 'upload',
          title: file.name,
          body: '업로드 체크리스트와 함께 저장',
          status: 'uploaded',
          input: text,
          output: '업로드 체크리스트와 함께 저장 · ${file.bytes.length} bytes',
          extra: {'size': file.bytes.length, 'meta': meta},
        );
        return '업로드 체크리스트와 함께 저장 · ${file.bytes.length} bytes';
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
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
      icon: Icons.cloud_upload_outlined,
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
                  onPressed: _busy ? null : _pick,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ConversationBox(
              records: records,
              hint: '체크리스트를 물어보거나, 파일을 저장해 달라고 말해 보세요',
              tint: AppTheme.butter,
              emptyMessage: '올린 파일 기록이 여기에 모여요.',
              onSubmit: (text) async {
                if (text.contains('파일') || text.contains('업로드')) {
                  await _pick();
                  return;
                }
                final lines = checks
                    .map(
                      (check) =>
                          '${check.$3 ? '완료' : '필요'} · ${check.$1} · ${check.$2}',
                    )
                    .join('\n');
                await context.read<SecretarySession>().replyTurn(
                  kind: 'upload',
                  text: text,
                  answer: (_, _) async => lines,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
