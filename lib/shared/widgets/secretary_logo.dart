import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';

enum SecretaryLogoSize { hero, rail, bar }

/// Voice mark and the AI Voice Secretary wordmark.
class SecretaryLogo extends StatelessWidget {
  const SecretaryLogo({super.key, this.size = SecretaryLogoSize.hero});

  final SecretaryLogoSize size;

  @override
  Widget build(BuildContext context) {
    final hero = size == SecretaryLogoSize.hero;
    final rail = size == SecretaryLogoSize.rail;
    final mark = hero ? 108.0 : (rail ? 64.0 : 36.0);
    final titleSize = hero ? 58.0 : (rail ? 26.0 : 16.0);
    final subtitleSize = hero ? 15.0 : (rail ? 10.0 : 8.0);
    final gap = hero ? 12.0 : 8.0;

    final title = ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: AppTheme.dark
            ? const [Color(0xFFF8FAFF), Color(0xFFD8B4FE)]
            : const [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
      ).createShader(bounds),
      child: Text(
        'AI 음성 비서',
        maxLines: 1,
        style: GoogleFonts.notoSansKr(
          fontSize: titleSize,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: hero ? -1.2 : -0.4,
          color: Colors.white,
        ),
      ),
    );
    final subtitle = Text(
      'AI VOICE SECRETARY',
      maxLines: 1,
      style: GoogleFonts.notoSansKr(
        fontSize: subtitleSize,
        fontWeight: FontWeight.w800,
        letterSpacing: hero ? 3.2 : (rail ? 1.1 : 0.4),
        color: AppTheme.neon,
        height: 1.1,
      ),
    );

    final wordmark = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: title,
        ),
        SizedBox(height: hero ? 6 : 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: subtitle,
        ),
      ],
    );

    if (size == SecretaryLogoSize.bar) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoiceMark(size: mark),
          SizedBox(width: gap),
          wordmark,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoiceMark(size: mark),
        SizedBox(height: gap),
        wordmark,
      ],
    );
  }
}

class _VoiceMark extends StatelessWidget {
  const _VoiceMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF6D28D9), Color(0xFFC084FC)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neon.withValues(alpha: 0.42),
            blurRadius: size * 0.32,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: CustomPaint(painter: _MicMarkPainter()),
    );
  }
}

class _MicMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.46, w * 0.36),
          width: w * 0.24,
          height: w * 0.36,
        ),
        Radius.circular(w * 0.14),
      ),
      fill,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.46, w * 0.44),
        width: w * 0.48,
        height: w * 0.4,
      ),
      0.15,
      2.85,
      false,
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.46, w * 0.64),
      Offset(w * 0.46, w * 0.74),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.34, w * 0.74),
      Offset(w * 0.58, w * 0.74),
      stroke,
    );

    final bar = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.045;
    canvas.drawLine(
      Offset(w * 0.72, w * 0.42),
      Offset(w * 0.72, w * 0.58),
      bar,
    );
    canvas.drawLine(
      Offset(w * 0.80, w * 0.34),
      Offset(w * 0.80, w * 0.66),
      bar,
    );
    canvas.drawLine(
      Offset(w * 0.88, w * 0.40),
      Offset(w * 0.88, w * 0.60),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
