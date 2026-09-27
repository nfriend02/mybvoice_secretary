import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../config/breakpoints.dart';
import '../config/nav_catalog.dart';
import '../widgets/secretary_logo.dart';
import '../widgets/theme_toggle_button.dart';

/// Desktop (≥769): left sidebar + main content.
/// Mobile (≤768): two rows of tabs, then the main content.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: DecoratedBox(
        decoration: AppTheme.pageBackground(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = Breakpoints.isDesktop(constraints.maxWidth);
            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Sidebar(location: location),
                  Expanded(
                    child: SafeArea(
                      child: _Stage(location: location, child: child),
                    ),
                  ),
                ],
              );
            }

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
                    child: Row(
                      children: const [
                        SecretaryLogo(size: SecretaryLogoSize.bar),
                        Spacer(),
                        ThemeToggleButton(),
                      ],
                    ),
                  ),
                  _MobileNav(location: location),
                  Expanded(
                    child: _Stage(location: location, child: child),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('desktop-sidebar'),
      width: 248,
      decoration: BoxDecoration(
        color: AppTheme.sidebar,
        border: Border(
          right: BorderSide(color: AppTheme.neon.withValues(alpha: 0.28)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: SecretaryLogo(size: SecretaryLogoSize.rail),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: [
                  for (final item in shellNav)
                    _NavTile(item: item, location: location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNav extends StatelessWidget {
  const _MobileNav({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final split = (shellNav.length / 2).ceil();
    final rows = [shellNav.sublist(0, split), shellNav.sublist(split)];
    return Padding(
      key: const Key('mobile-nav'),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Column(
        children: [
          for (var row = 0; row < rows.length; row++) ...[
            if (row > 0) const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  for (var index = 0; index < rows[row].length; index++) ...[
                    if (index > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _NavChip(
                        item: rows[row][index],
                        location: location,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.location});

  final NavItem item;
  final String location;

  @override
  Widget build(BuildContext context) {
    final selected = _selected(item, location);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? item.color.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(item.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: item.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.notoSansKr(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
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

class _NavChip extends StatelessWidget {
  const _NavChip({required this.item, required this.location});

  final NavItem item;
  final String location;

  @override
  Widget build(BuildContext context) {
    final selected = _selected(item, location);
    return Material(
      color: AppTheme.chipFill(selected),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => context.go(item.path),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppTheme.chipBorder(selected),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 14, color: item.color),
              const SizedBox(width: 3),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: GoogleFonts.notoSansKr(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final here = location == '/talk';
    final desktop = Breakpoints.isDesktop(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('talk-shortcut'),
                    onPressed: here ? null : () => context.go('/talk'),
                    icon: const Icon(Icons.notes_outlined, size: 18),
                    label: Text(here ? '이 화면에서 대화를 요약해요' : '대화 요약 바로가기'),
                  ),
                ),
              ),
              if (desktop) const ThemeToggleButton(),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

bool _selected(NavItem item, String location) {
  if (item.path == '/') return location == '/';
  return location == item.path || location.startsWith('${item.path}/');
}
