import '../../../services/secretary_session.dart';
import '../../../shared/utils/text_tools.dart';

class RankedHit {
  const RankedHit(this.record, this.score);

  final SecretaryRecord record;
  final int score;
}

/// Keyword overlap search over saved document chunks.
class RagRanker {
  static List<RankedHit> rank(String query, List<SecretaryRecord> docs) {
    final terms = tokenize(query);
    if (terms.isEmpty) {
      return [for (final doc in docs) RankedHit(doc, 0)];
    }

    final hits = <RankedHit>[];
    for (final doc in docs) {
      final hay = '${doc.title} ${doc.body}'.toLowerCase();
      var score = 0;
      for (final term in terms) {
        if (hay.contains(term)) score += 2;
      }
      if (score > 0) hits.add(RankedHit(doc, score));
    }
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.record.createdAt.compareTo(a.record.createdAt);
    });
    return hits;
  }
}
