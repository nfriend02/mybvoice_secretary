import 'package:flutter_test/flutter_test.dart';
import 'package:mybvoice_secretary/features/learn/domain/study_pack.dart';
import 'package:mybvoice_secretary/features/live/domain/live_query.dart';
import 'package:mybvoice_secretary/features/mail/domain/mail_draft.dart';
import 'package:mybvoice_secretary/features/schedule/domain/schedule_draft.dart';
import 'package:mybvoice_secretary/features/translate/domain/phrase_book.dart';
import 'package:mybvoice_secretary/features/voice_chat/domain/command_router.dart';
import 'package:mybvoice_secretary/features/workflow/domain/workflow_bundle.dart';

void main() {
  test('schedule command keeps the meeting and 10am', () {
    final draft = ScheduleDraft.parse(
      '내일 오전 10시에 회의 준비 알려줘',
      now: DateTime(2026, 9, 27, 8),
    );
    expect(draft.title, '회의 준비');
    expect(draft.whenLabel, contains('10시'));
    expect(draft.when.hour, 10);
    expect(draft.channel, 'device');
    expect(draft.ics, contains('BEGIN:VCALENDAR'));
  });

  test('calendar words choose google or outlook', () {
    expect(ScheduleDraft.parse('구글 캘린더에 내일 오후 3시 미팅').channel, 'google');
    expect(ScheduleDraft.parse('아웃룩에 내일 오후 3시 미팅').channel, 'outlook');
  });

  test('mail draft turns speech into a short letter', () {
    final draft = MailDraft.compose('내일 회의 자료를 팀에 공유하는 메일 써줘');
    expect(draft.fileText, contains('Subject:'));
    expect(draft.body, contains('안녕하세요'));
    expect(draft.subject, contains('회의'));
  });

  test('phrase book translates a greeting both ways', () {
    expect(PhraseBook.translate('안녕하세요', from: 'ko', to: 'en'), 'Hello');
    expect(PhraseBook.translate('Hello', from: 'en', to: 'ko'), '안녕하세요');
  });

  test('workflow bundle keeps a summary and a notion note', () {
    final bundle = WorkflowBundle.build(
      source: '예산 회의는 금요일이다.',
      summary: '금요일에 예산 회의가 있다.',
    );
    expect(bundle.mail, contains('Subject:'));
    expect(bundle.notion, contains('# 회의 노트'));
  });

  test('study pack blanks the first word', () {
    final cards = StudyPack.fromTexts(['고양이가 창가에 앉았다.']);
    expect(cards, isNotEmpty);
    expect(cards.first.prompt, contains('___'));
    expect(cards.first.answer, '고양이가');
  });

  test('commands land on the matching secretary page', () {
    expect(
      CommandRouter.routeFor(CommandRouter.detect('내일 오전 10시에 회의 준비 알려줘')),
      '/schedule',
    );
    expect(CommandRouter.detect('메일 초안 써줘'), AssistantIntent.mail);
    expect(CommandRouter.detect('영어로 번역해줘'), AssistantIntent.translate);
    expect(CommandRouter.detect('회의록 정리해서 공유해줘'), AssistantIntent.workflow);
    expect(CommandRouter.detect('학습 퀴즈 만들어줘'), AssistantIntent.learn);
    expect(CommandRouter.detect('서울 날씨'), AssistantIntent.weather);
    expect(CommandRouter.routeFor(CommandRouter.detect('달러 환율')), '/live');
    expect(CommandRouter.detect('서울역 어디'), AssistantIntent.map);
  });

  test('live queries pick a city, a currency pair, and a place', () {
    expect(LiveQuery.cityOf('부산 날씨 알려줘'), '부산');
    final pair = LiveQuery.pairOf('달러 원화 환율');
    expect(pair.base, 'USD');
    expect(pair.quote, 'KRW');
    expect(LiveQuery.placeOf('서울역 어디'), '서울역');
  });
}
