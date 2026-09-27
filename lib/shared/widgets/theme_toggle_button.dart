import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_controller.dart';

/// Top-right control that flips between the bright and dark screens.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeController>().dark;
    final label = dark ? '낮' : '밤';
    return Material(
      key: const Key('theme-toggle'),
      color: AppTheme.chipFill(false),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => context.read<ThemeController>().toggle(),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.chipBorder(true)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 16,
                color: AppTheme.neon,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.notoSansKr(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
