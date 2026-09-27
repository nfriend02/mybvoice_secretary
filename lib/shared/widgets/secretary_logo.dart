import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';

class SecretaryLogo extends StatelessWidget {
  const SecretaryLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        children: [
          const Text('🎙️', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MYB',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 0.9,
                  color: AppTheme.ink,
                ),
              ),
              Text(
                'VOICE',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.coral,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.82, end: 1),
          duration: const Duration(milliseconds: 620),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: const Text('🎙️', style: TextStyle(fontSize: 78, height: 1)),
        ),
        Text(
          'MYB',
          style: GoogleFonts.fredoka(
            fontSize: 76,
            fontWeight: FontWeight.w700,
            height: 0.86,
            color: AppTheme.ink,
          ),
        ),
        Text(
          'VOICE SECRETARY',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            letterSpacing: 3.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.coral,
          ),
        ),
      ],
    );
  }
}
