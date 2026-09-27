import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../../services/secretary_session.dart';
import '../../shared/config/nav_catalog.dart';
import '../../shared/widgets/fun_feature_button.dart';
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
        final wide = constraints.maxWidth >= 720;
        final tight = constraints.maxHeight < 680;
        final buttonHeight = tight ? 78.0 : 104.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SecretaryLogo(compact: tight),
            const SizedBox(height: 6),
            Text(
              '말하고, 요약하고, 다시 찾는 파스텔 비서',
              style: GoogleFonts.notoSansKr(
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 12),
            if (wide)
              SizedBox(
                height: buttonHeight,
                child: Row(
                  children: [
                    for (var i = 0; i < featureNav.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: _featureButton(context, featureNav[i])),
                    ],
                  ],
                ),
              )
            else ...[
              SizedBox(
                height: buttonHeight,
                child: Row(
                  children: [
                    Expanded(child: _featureButton(context, featureNav[0])),
                    const SizedBox(width: 10),
                    Expanded(child: _featureButton(context, featureNav[1])),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: buttonHeight,
                child: Row(
                  children: [
                    Expanded(child: _featureButton(context, featureNav[2])),
                    const SizedBox(width: 10),
                    Expanded(child: _featureButton(context, featureNav[3])),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '최근 기록',
                  style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: session.fillPracticeNotes,
                  child: const Text('연습 기록 12개'),
                ),
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

  Widget _featureButton(BuildContext context, NavItem item) {
    return FunFeatureButton(
      label: item.label,
      emoji: item.emoji,
      color: item.color,
      blurb: item.blurb,
      onTap: () => context.go(item.path),
    );
  }
}
