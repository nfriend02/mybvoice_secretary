import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';

class FunFeatureButton extends StatefulWidget {
  const FunFeatureButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.color,
    required this.blurb,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final String blurb;
  final VoidCallback onTap;

  @override
  State<FunFeatureButton> createState() => _FunFeatureButtonState();
}

class _FunFeatureButtonState extends State<FunFeatureButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (_hover ? 1.04 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _hover ? 0.55 : 0.28),
                  blurRadius: _hover ? 16 : 0,
                  offset: Offset(_hover ? 3 : 4, _hover ? 8 : 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 26)),
                const Spacer(),
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppTheme.ink,
                  ),
                ),
                Text(
                  widget.blurb,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FunActionButton extends StatelessWidget {
  const FunActionButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final String emoji;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text('$emoji  $label'),
    );
  }
}
