import 'package:flutter/foundation.dart';

import '../shared/api/api_client.dart';
import '../shared/utils/text_tools.dart';
import 'firestore_service.dart';

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

  static const collections = {
    'voice': 'messages',
    'pdf': 'summaries',
    'talk': 'summaries',
    'rag': 'documents',
    'upload': 'uploads',
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
          status: 'active',
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
    try {
      if (kind == 'upload') {
        await db.uploadFileMetadata(
          title,
          status,
          extra: {'body': body, 'kind': kind, ...extra},
        );
      } else {
        await db.addData(collections[kind] ?? 'messages', {
          'kind': kind,
          'title': title,
          'body': body,
          'fileName': title,
          'status': status,
          ...extra,
        });
      }
      return 'Firestore에 저장했어요';
    } catch (e, st) {
      debugPrint('save failed: $e\n$st');
      return '화면에는 남았고, Firestore 저장은 실패했어요';
    }
  }

  Future<String> summarize(String text) => ApiClient.summarize(text);

  Future<String> savePdfSummary({
    required String fileName,
    required String text,
  }) async {
    final source = text.trim().isEmpty
        ? '파일 $fileName 을 받았어요. 본문 텍스트는 추출되지 않았어요.'
        : text.trim();
    final summary = await summarize(source);
    final note = await add(kind: 'pdf', title: fileName, body: summary);
    if (text.trim().isNotEmpty) {
      for (final chunk in textChunks(text)) {
        await add(kind: 'rag', title: fileName, body: chunk);
      }
    }
    return note;
  }

  Future<String> saveTalkSummary(String text) async {
    final summary = await summarize(text);
    final note = await add(
      kind: 'talk',
      title: '대화 요약',
      body: summary.isEmpty ? text.trim() : summary,
    );
    for (final chunk in textChunks(text)) {
      await add(kind: 'rag', title: '대화', body: chunk);
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
