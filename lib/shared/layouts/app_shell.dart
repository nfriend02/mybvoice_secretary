import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_theme.dart';
import '../config/breakpoints.dart';
import '../config/nav_catalog.dart';
import '../widgets/secretary_logo.dart';

/// Desktop (≥769): left sidebar + main content.
/// Mobile (≤768): one horizontal menu + main content.
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 20, 16),
                        child: child,
                      ),
                    ),
                  ),
                ],
              );
            }

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: SecretaryLogo(compact: true),
                  ),
                  _MobileNav(location: location),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: child,
                    ),
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
      decoration: const BoxDecoration(
        color: Color(0xF7FFFFFF),
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: SecretaryLogo(compact: true),
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
    return SizedBox(
      key: const Key('mobile-nav'),
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: shellNav.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = shellNav[index];
          return _NavChip(item: item, location: location);
        },
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
        color: selected ? item.color : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(item.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 18)),
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
      color: selected ? item.color : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => context.go(item.path),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.white : AppTheme.border,
            ),
          ),
          child: Text(
            '${item.emoji} ${item.label}',
            style: GoogleFonts.notoSansKr(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

bool _selected(NavItem item, String location) {
  if (item.path == '/') return location == '/';
  return location == item.path || location.startsWith('${item.path}/');
}
