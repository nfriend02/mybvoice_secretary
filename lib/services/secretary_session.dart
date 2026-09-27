import 'package:flutter/foundation.dart';

import '../features/learn/domain/study_pack.dart';
import '../features/live/domain/live_query.dart';
import '../features/mail/domain/mail_draft.dart';
import '../features/schedule/domain/schedule_draft.dart';
import '../features/voice_chat/domain/command_router.dart';
import '../features/voice_chat/domain/secretary_reply.dart';
import '../features/workflow/domain/workflow_bundle.dart';
import '../shared/api/api_client.dart';
import '../shared/utils/text_tools.dart';
import 'firestore_service.dart';

class CommandOutcome {
  const CommandOutcome({required this.route, required this.message});

  final String route;
  final String message;
}

class SecretaryRecord {
  const SecretaryRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String kind;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;

  factory SecretaryRecord.fromMap(
    Map<String, dynamic> data, {
    required String fallbackKind,
  }) {
    final ms = FirestoreService.createdAtMs(data['createdAt']);
    return SecretaryRecord(
      id: data['id'] as String? ?? '',
      kind: data['kind'] as String? ?? fallbackKind,
      title: (data['title'] ?? data['fileName'] ?? '기록') as String,
      body: (data['body'] ?? data['fileName'] ?? '') as String,
      status: data['status'] as String? ?? 'active',
      createdAt: ms == 0
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }
}

/// In-memory session that also writes Firestore when Firebase is ready.
class SecretarySession extends ChangeNotifier {
  SecretarySession(this.firestore);

  final FirestoreService? firestore;
  final records = <SecretaryRecord>[];
  final selectedIds = <String>{};

  bool isSelected(String id) => selectedIds.contains(id);

  void toggleSelected(String id) {
    if (!selectedIds.add(id)) selectedIds.remove(id);
    notifyListeners();
  }

  static const collections = {
    'voice': 'messages',
    'pdf': 'summaries',
    'talk': 'summaries',
    'rag': 'documents',
    'upload': 'uploads',
    'schedule': 'schedules',
    'mail': 'drafts',
    'translate': 'translations',
    'workflow': 'workflows',
    'learn': 'study_cards',
    'live': 'live_queries',
  };

  List<SecretaryRecord> ofKind(String kind) {
    return records.where((record) => record.kind == kind).toList();
  }

  Future<void> hydrate() async {
    final db = firestore;
    if (db == null) return;
    final loaded = <SecretaryRecord>[];
    for (final entry in collections.entries) {
      try {
        final rows = await db.listPage(
          collection: entry.value,
          status: null,
          limit: 100,
        );
        for (final row in rows) {
          final record = SecretaryRecord.fromMap(row, fallbackKind: entry.key);
          if (entry.key == 'pdf' || entry.key == 'talk') {
            if (record.kind != entry.key) continue;
          }
          loaded.add(record);
        }
      } catch (e, st) {
        debugPrint('hydrate ${entry.value} skipped: $e\n$st');
      }
    }
    final localOnly = records.where((record) => record.id.startsWith('local-'));
    records
      ..clear()
      ..addAll(loaded)
      ..addAll(localOnly);
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<String> add({
    required String kind,
    required String title,
    required String body,
    String status = 'active',
    String input = '',
    String output = '',
    Map<String, dynamic> extra = const {},
  }) async {
    final record = SecretaryRecord(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      title: title,
      body: body,
      status: status,
      createdAt: DateTime.now(),
    );
    records.insert(0, record);
    notifyListeners();

    final db = firestore;
    if (db == null) return '데모 모드에 남겼어요';
    final savedInput = _clip(input);
    final savedOutput = _clip(output.isEmpty ? body : output);
    try {
      final String remoteId;
      final fields = {
        'kind': kind,
        'title': title,
        'body': body,
        'input': savedInput,
        'output': savedOutput,
        'fileName': title,
        'status': status,
        ...extra,
      };
      if (kind == 'upload') {
        remoteId = await db.uploadFileMetadata(title, status, extra: fields);
      } else {
        remoteId = await db.addData(collections[kind] ?? 'messages', fields);
      }
      _replaceId(record.id, remoteId, record);
      return 'Firestore에 저장했어요';
    } catch (e, st) {
      debugPrint('save failed: $e\n$st');
      return '화면에는 남았고, Firestore 저장은 실패했어요';
    }
  }

  void _replaceId(String localId, String remoteId, SecretaryRecord record) {
    final index = records.indexWhere((item) => item.id == localId);
    if (index < 0) return;
    final wasSelected = selectedIds.remove(localId);
    records[index] = SecretaryRecord(
      id: remoteId,
      kind: record.kind,
      title: record.title,
      body: record.body,
      status: record.status,
      createdAt: record.createdAt,
    );
    if (wasSelected) selectedIds.add(remoteId);
    notifyListeners();
  }

  Future<String> deleteSelected() async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return '삭제할 기록을 선택해 주세요';
    final removing = records
        .where((record) => ids.contains(record.id))
        .toList();
    records.removeWhere((record) => ids.contains(record.id));
    selectedIds.removeAll(ids);
    notifyListeners();

    final db = firestore;
    if (db != null) {
      for (final record in removing) {
        if (record.id.startsWith('local-')) continue;
        final collection = collections[record.kind];
        if (collection == null) continue;
        try {
          await db.deleteData(collection, record.id);
        } catch (e, st) {
          debugPrint('delete failed: $e\n$st');
        }
      }
    }
    return '${removing.length}개를 삭제했어요';
  }

  static String _clip(String value) {
    const maxChars = 200000;
    if (value.length <= maxChars) return value;
    return value.substring(0, maxChars);
  }

  Future<String> summarize(String text) => ApiClient.summarize(text);

  String _recentSource(String utterance) {
    final prior = records
        .where(
          (record) =>
              record.kind == 'talk' ||
              record.kind == 'pdf' ||
              record.kind == 'voice' ||
              record.kind == 'rag',
        )
        .take(4)
        .map((record) => record.body)
        .where((body) => body.trim().isNotEmpty)
        .join('\n');
    if (utterance.trim().length >= 12 && prior.isEmpty) return utterance.trim();
    if (prior.isNotEmpty && utterance.trim().length < 24) return prior;
    return utterance.trim().isEmpty ? prior : utterance.trim();
  }

  /// Saves the user's line, then the assistant's answer, so the thread can continue.
  Future<String> replyTurn({
    required String kind,
    required String text,
    required Future<String> Function(String text, String history) answer,
    String answerTitle = 'MYB',
  }) async {
    final history = ofKind(kind)
        .take(8)
        .toList()
        .reversed
        .map((record) => '${record.title}: ${record.body}')
        .join('\n');
    await add(kind: kind, title: '나', body: text, input: text);
    final output = await answer(text, history);
    return add(
      kind: kind,
      title: answerTitle,
      body: output,
      input: text,
      output: output,
    );
  }

  Future<CommandOutcome> applyCommand(String raw) async {
    final text = raw.trim();
    final intent = CommandRouter.detect(text);
    final route = CommandRouter.routeFor(intent);
    switch (intent) {
      case AssistantIntent.weather:
        final city = LiveQuery.cityOf(text);
        final body = await ApiClient.weather(city);
        final note = await add(
          kind: 'live',
          title: '날씨 · $city',
          body: body,
          input: text,
          output: body,
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.exchange:
        final pair = LiveQuery.pairOf(text);
        final body = await ApiClient.exchange(
          base: pair.base,
          quote: pair.quote,
        );
        final note = await add(
          kind: 'live',
          title: '환율 · ${pair.base}/${pair.quote}',
          body: body,
          input: text,
          output: body,
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.map:
        final place = LiveQuery.placeOf(text);
        final body = await ApiClient.place(place);
        final note = await add(
          kind: 'live',
          title: '지도 · $place',
          body: body,
          input: text,
          output: body,
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.schedule:
        final draft = ScheduleDraft.parse(text);
        final note = await add(
          kind: 'schedule',
          title: draft.title,
          body: draft.cardBody,
          input: text,
          output: draft.cardBody,
          extra: {'whenLabel': draft.whenLabel, 'channel': draft.channel},
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.mail:
        final draft = MailDraft.compose(text);
        final body = await ApiClient.draftEmail(text);
        final note = await add(
          kind: 'mail',
          title: draft.subject,
          body: body,
          input: text,
          output: body,
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.translate:
        final to = text.contains('한국어로') ? 'ko' : 'en';
        final from = to == 'ko' ? 'en' : 'ko';
        final translated = await ApiClient.translate(text, from: from, to: to);
        final note = await add(
          kind: 'translate',
          title: to == 'en' ? '한국어 → English' : 'English → 한국어',
          body: translated,
          input: text,
          output: translated,
        );
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.workflow:
        final source = _recentSource(text);
        final summary = await summarize(source);
        final bundle = WorkflowBundle.build(source: source, summary: summary);
        final notion =
            text.contains('노션') || text.toLowerCase().contains('notion');
        final card = notion
            ? bundle.notion
            : '${bundle.summary}\n\n${bundle.mail}';
        final note = await add(
          kind: 'workflow',
          title: notion ? 'Notion 노트' : '공유용 회의록',
          body: card,
          input: source,
          output: card,
        );
        if (!notion) {
          await add(
            kind: 'mail',
            title: '회의록 메일',
            body: bundle.mail,
            input: source,
            output: bundle.mail,
          );
        }
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.learn:
        final sources = records
            .where(
              (record) =>
                  record.kind == 'pdf' ||
                  record.kind == 'talk' ||
                  record.kind == 'rag',
            )
            .map((record) => record.body);
        final cards = StudyPack.fromTexts(sources);
        if (cards.isEmpty) {
          final note = await add(
            kind: 'learn',
            title: '학습 카드',
            body: 'PDF나 대화 요약을 먼저 남기면 퀴즈를 만들 수 있어요.',
            input: text,
            output: 'PDF나 대화 요약을 먼저 남기면 퀴즈를 만들 수 있어요.',
          );
          return CommandOutcome(route: route, message: note);
        }
        String note = '';
        for (final card in cards) {
          note = await add(
            kind: 'learn',
            title: '퀴즈',
            body: card.fileText,
            input: text,
            output: card.fileText,
          );
        }
        return CommandOutcome(route: route, message: note);
      case AssistantIntent.voice:
        final reply = SecretaryReply.reply(text);
        await add(
          kind: 'voice',
          title: '나',
          body: text,
          input: text,
          output: reply,
        );
        final note = await add(
          kind: 'voice',
          title: 'MYB',
          body: reply,
          input: text,
          output: reply,
        );
        return CommandOutcome(route: route, message: note);
    }
  }

  Future<String> savePdfSummary({
    required String fileName,
    required String text,
  }) async {
    final source = text.trim().isEmpty
        ? '파일 $fileName 을 받았어요. 본문 텍스트는 추출되지 않았어요.'
        : text.trim();
    final summary = await summarize(source);
    final note = await add(
      kind: 'pdf',
      title: fileName,
      body: summary,
      input: source,
      output: summary,
    );
    if (text.trim().isNotEmpty) {
      for (final chunk in textChunks(text)) {
        await add(
          kind: 'rag',
          title: fileName,
          body: chunk,
          input: source,
          output: chunk,
        );
      }
    }
    return note;
  }

  Future<String> saveTalkSummary(String text) async {
    final summary = await summarize(text);
    final card = summary.isEmpty ? text.trim() : summary;
    final note = await add(
      kind: 'talk',
      title: '대화 요약',
      body: card,
      input: text.trim(),
      output: card,
    );
    for (final chunk in textChunks(text)) {
      await add(
        kind: 'rag',
        title: '대화',
        body: chunk,
        input: text.trim(),
        output: chunk,
      );
    }
    return note;
  }

  void fillPracticeNotes() {
    if (records.any((record) => record.id.startsWith('local-demo-'))) return;
    for (var i = 1; i <= 12; i++) {
      records.add(
        SecretaryRecord(
          id: 'local-demo-$i',
          kind: 'voice',
          title: '연습 메모 $i',
          body: '스크롤하면 10개씩 더 보이는 연습 기록 $i',
          status: 'active',
          createdAt: DateTime.now().subtract(Duration(minutes: 13 - i)),
        ),
      );
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }
}
