import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String emoji;
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
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                      height: 1,
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
        const SizedBox(height: 16),
        Expanded(child: child),
      ],
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, this.tint});

  final SecretaryRecord record;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(tint: tint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            record.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansKr(color: AppTheme.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}
