import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.emoji,
    required this.color,
    required this.blurb,
  });

  final String path;
  final String label;
  final String emoji;
  final Color color;
  final String blurb;
}

const homeNav = NavItem(
  path: '/',
  label: '홈',
  emoji: '✨',
  color: AppTheme.butter,
  blurb: '오늘의 비서',
);

const voiceNav = NavItem(
  path: '/voice',
  label: '음성 비서',
  emoji: '🎙️',
  color: AppTheme.peach,
  blurb: '말하고 기록',
);

const pdfNav = NavItem(
  path: '/pdf',
  label: 'PDF 요약',
  emoji: '📄',
  color: AppTheme.sky,
  blurb: '핵심만 쏙',
);

const talkNav = NavItem(
  path: '/talk',
  label: '대화 요약',
  emoji: '💬',
  color: AppTheme.mint,
  blurb: '긴 말을 짧게',
);

const ragNav = NavItem(
  path: '/rag',
  label: 'RAG 검색',
  emoji: '🔍',
  color: AppTheme.lavender,
  blurb: '저장본 찾기',
);

const uploadNav = NavItem(
  path: '/upload',
  label: '업로드',
  emoji: '☁️',
  color: AppTheme.butter,
  blurb: '전시 체크',
);

const featureNav = [voiceNav, pdfNav, talkNav, ragNav];

const shellNav = [homeNav, ...featureNav, uploadNav];
