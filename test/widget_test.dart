import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mybvoice_secretary/app/app.dart';
import 'package:mybvoice_secretary/features/pdf_summary/domain/pdf_text.dart';
import 'package:mybvoice_secretary/features/rag_search/domain/rag_ranker.dart';
import 'package:mybvoice_secretary/features/voice_chat/domain/secretary_reply.dart';
import 'package:mybvoice_secretary/services/secretary_session.dart';
import 'package:mybvoice_secretary/shared/config/app_config.dart';
import 'package:mybvoice_secretary/shared/config/breakpoints.dart';
import 'package:mybvoice_secretary/shared/utils/extractive_summarizer.dart';
import 'package:mybvoice_secretary/shared/widgets/scroll_paged_list.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('portfolio description stays within 200 characters', () {
    expect(AppConfig.defaultDescription.length, lessThanOrEqualTo(200));
    expect(AppConfig.defaultDescription, isNotEmpty);
    expect(AppConfig.defaultAuthor, 'MyBranch Team');
    expect(AppConfig.defaultGithubUrl, contains('mybvoice_secretary'));
    expect(AppConfig.apiPrefix, '/api');
  });

  test('desktop breakpoint starts at 769px', () {
    expect(Breakpoints.isMobile(768), isTrue);
    expect(Breakpoints.isDesktop(768), isFalse);
    expect(Breakpoints.isDesktop(769), isTrue);
    expect(PaginationRules.pageSize, 10);
  });

  test('extractive summary keeps the frequent sentence', () {
    const text = '고양이가 창가에 앉았다. 고양이가 창가에서 햇빛을 보았다. 비가 조금 내렸다.';
    final summary = ExtractiveSummarizer.summarize(text, maxSentences: 1);
    expect(summary.contains('고양이'), isTrue);
  });

  test('pdf text reads a simple text file and a literal pdf string', () {
    expect(PdfText.extract(utf8.encode('안녕 비서'), 'note.txt'), '안녕 비서');
    final pdf = latin1.encode('BT (Hello secretary.) Tj ET');
    expect(PdfText.extract(pdf, 'note.pdf'), contains('Hello'));
  });

  test('rag ranker prefers the overlapping note', () {
    final docs = [
      SecretaryRecord(
        id: '1',
        kind: 'rag',
        title: '회의',
        body: '예산 회의는 금요일이다',
        status: 'active',
        createdAt: DateTime(2026, 1, 1),
      ),
      SecretaryRecord(
        id: '2',
        kind: 'rag',
        title: '점심',
        body: '샐러드를 먹었다',
        status: 'active',
        createdAt: DateTime(2026, 1, 2),
      ),
    ];
    final hits = RagRanker.rank('예산 회의', docs);
    expect(hits, isNotEmpty);
    expect(hits.first.record.id, '1');
  });

  test('voice reply greets and stores the sentence', () {
    expect(SecretaryReply.reply('안녕'), contains('MYB'));
    expect(SecretaryReply.reply('자료 찾아줘'), contains('기록'));
  });

  testWidgets('scroll pagination reveals the next 10 items', (tester) async {
    final items = [for (var i = 1; i <= 12; i++) 'Item $i'];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 320,
            child: ScrollPagedList<String>(
              items: items,
              itemBuilder: (_, item, _) =>
                  SizedBox(height: 48, child: Text(item)),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('10 / 12 · 10개씩'), findsOneWidget);
    expect(find.text('Item 12'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    expect(find.text('12 / 12 · 10개씩'), findsOneWidget);
  });

  testWidgets('desktop shell keeps the sidebar at 769px and above', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyBVoiceSecretaryApp(firebaseReady: false));
    await tester.pump();

    expect(find.byKey(const Key('desktop-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('mobile-nav')), findsNothing);
    expect(find.text('MYB'), findsWidgets);
    expect(find.text('음성 비서'), findsWidgets);
  });

  testWidgets('mobile shell stacks a single menu row', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyBVoiceSecretaryApp(firebaseReady: false));
    await tester.pump();

    expect(find.byKey(const Key('mobile-nav')), findsOneWidget);
    expect(find.byKey(const Key('desktop-sidebar')), findsNothing);
  });

  testWidgets('practice notes page in batches of 10', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyBVoiceSecretaryApp(firebaseReady: false));
    await tester.pump();
    await tester.tap(find.text('연습 기록 12개'));
    await tester.pump();

    expect(find.text('10 / 12 · 10개씩'), findsOneWidget);
    expect(find.text('연습 메모 12'), findsOneWidget);
    expect(find.text('연습 메모 1'), findsNothing);
  });
}
