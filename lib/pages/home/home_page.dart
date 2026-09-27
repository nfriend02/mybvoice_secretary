import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/config/breakpoints.dart';
import '../../shared/config/nav_catalog.dart';
import '../../shared/widgets/feature_scaffold.dart';
import '../../shared/widgets/scroll_paged_list.dart';
import '../../shared/widgets/secretary_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SecretarySession>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = Breakpoints.isDesktop(MediaQuery.sizeOf(context).width);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SecretaryLogo(size: SecretaryLogoSize.hero),
            const SizedBox(height: 6),
            Text(
              '말하면 정리해 드릴게요.',
              style: GoogleFonts.notoSansKr(
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            if (desktop)
              Text(
                '필요한 정보를 빠르게 찾아드립니다.',
                style: GoogleFonts.notoSansKr(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
            const SizedBox(height: 12),
            _HomeMenuGrid(desktop: desktop),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '최근 기록',
                  style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                const RecordDeleteButton(),
              ],
            ),
            Expanded(
              child: ScrollPagedList<SecretaryRecord>(
                items: session.records,
                emptyMessage: '아직 기록이 없어요. 음성 비서에게 먼저 말해 보세요.',
                itemBuilder: (context, record, _) =>
                    RecordTile(record: record, tint: AppTheme.peach),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final columns = desktop ? 2 : 3;
    final rows = <Widget>[];
    for (var index = 0; index < homeMenus.length; index += columns) {
      final slice = homeMenus.skip(index).take(columns).toList();
      rows.add(
        Row(
          children: [
            for (var column = 0; column < columns; column++) ...[
              if (column > 0) const SizedBox(width: 8),
              Expanded(
                child: column < slice.length
                    ? _HomeMenuTile(item: slice[column], desktop: desktop)
                    : const SizedBox(height: 44),
              ),
            ],
          ],
        ),
      );
      if (index + columns < homeMenus.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return Column(
      key: Key(desktop ? 'home-menu-2' : 'home-menu-3'),
      children: rows,
    );
  }
}

class _HomeMenuTile extends StatelessWidget {
  const _HomeMenuTile({required this.item, required this.desktop});

  final NavItem item;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.menuFill,
      borderRadius: BorderRadius.circular(desktop ? 16 : 999),
      child: InkWell(
        borderRadius: BorderRadius.circular(desktop ? 16 : 999),
        onTap: () => context.go(item.path),
        child: Container(
          height: desktop ? 58 : 44,
          padding: EdgeInsets.symmetric(horizontal: desktop ? 12 : 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(desktop ? 16 : 999),
            border: Border.all(color: item.color.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: desktop ? 20 : 16, color: item.color),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontWeight: FontWeight.w800,
                        fontSize: desktop ? 14 : 12,
                        color: AppTheme.ink,
                        height: 1.1,
                      ),
                    ),
                    if (desktop)
                      Text(
                        item.blurb,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                          height: 1.1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
