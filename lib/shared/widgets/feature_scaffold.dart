import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../utils/share_text.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.7)),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansKr(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(child: child),
      ],
    );
  }
}

class RecordDeleteButton extends StatelessWidget {
  const RecordDeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final session = context.read<SecretarySession>();
        final note = await session.deleteSelected();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(note)));
      },
      child: const Text('기록 삭제'),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, this.tint});

  final SecretaryRecord record;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<SecretarySession>().isSelected(record.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 8),
      decoration: AppTheme.card(tint: tint),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  record.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    color: AppTheme.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final note = await saveTextFile(
                        '${record.title}.txt',
                        '${record.title}\n\n${record.body}',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(note)));
                    },
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('다운로드'),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: selected,
            onChanged: (_) =>
                context.read<SecretarySession>().toggleSelected(record.id),
          ),
        ],
      ),
    );
  }
}
