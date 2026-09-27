import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.blurb,
  });

  final String path;
  final String label;
  final String emoji;
  final IconData icon;
  final Color color;
  final String blurb;
}

const homeNav = NavItem(
  path: '/',
  label: '홈',
  emoji: '✦',
  icon: Icons.home_outlined,
  color: AppTheme.butter,
  blurb: '오늘의 비서',
);

const voiceNav = NavItem(
  path: '/voice',
  label: '음성 비서',
  emoji: '🎙️',
  icon: Icons.mic_none,
  color: AppTheme.neon,
  blurb: '말하면 정리',
);

const pdfNav = NavItem(
  path: '/pdf',
  label: 'PDF 요약',
  emoji: '📄',
  icon: Icons.description_outlined,
  color: AppTheme.sky,
  blurb: '문서 카드',
);

const talkNav = NavItem(
  path: '/talk',
  label: '대화 요약',
  emoji: '💬',
  icon: Icons.notes_outlined,
  color: AppTheme.mint,
  blurb: '바로 요약',
);

const ragNav = NavItem(
  path: '/rag',
  label: 'RAG 검색',
  emoji: '🔍',
  icon: Icons.search,
  color: AppTheme.lavender,
  blurb: '빠르게 찾기',
);

const scheduleNav = NavItem(
  path: '/schedule',
  label: '일정',
  emoji: '🗓️',
  icon: Icons.event_outlined,
  color: AppTheme.deepBlue,
  blurb: '알림과 캘린더',
);

const mailNav = NavItem(
  path: '/mail',
  label: '메일',
  emoji: '✉️',
  icon: Icons.mail_outline,
  color: AppTheme.peach,
  blurb: '초안 카드',
);

const translateNav = NavItem(
  path: '/translate',
  label: '번역',
  emoji: '🌐',
  icon: Icons.translate,
  color: AppTheme.mint,
  blurb: '다른 언어로',
);

const workflowNav = NavItem(
  path: '/workflow',
  label: '워크플로',
  emoji: '⚡',
  icon: Icons.account_tree_outlined,
  color: AppTheme.neon,
  blurb: '정리하고 공유',
);

const learnNav = NavItem(
  path: '/learn',
  label: '학습',
  emoji: '📘',
  icon: Icons.school_outlined,
  color: AppTheme.lavender,
  blurb: '퀴즈와 카드',
);

const liveNav = NavItem(
  path: '/live',
  label: '실시간',
  emoji: '🌐',
  icon: Icons.public,
  color: AppTheme.sky,
  blurb: '날씨·환율·지도',
);

const uploadNav = NavItem(
  path: '/upload',
  label: '업로드',
  emoji: '☁️',
  icon: Icons.cloud_upload_outlined,
  color: AppTheme.butter,
  blurb: '전시 체크',
);

const featureNav = [voiceNav, pdfNav, talkNav, ragNav];

/// Ten home menus, excluding the home screen itself and the upload checklist.
const homeMenus = [...featureNav, ...extendedNav];

const extendedNav = [
  liveNav,
  scheduleNav,
  mailNav,
  translateNav,
  workflowNav,
  learnNav,
];

const shellNav = [homeNav, ...featureNav, ...extendedNav, uploadNav];
