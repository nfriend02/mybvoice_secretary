import '../../../shared/utils/extractive_summarizer.dart';

/// Short local replies for the voice secretary.
class SecretaryReply {
  static String reply(String input, {String earlier = ''}) {
    final text = input.trim();
    if (text.isEmpty) return '한 마디만 들려 주세요.';
    if (earlier.isNotEmpty &&
        (text.contains('다시') ||
            text.contains('더') ||
            text.contains('이어서') ||
            text.contains('그게'))) {
      final summary = ExtractiveSummarizer.summarize(
        '$earlier\n$text',
        maxSentences: 2,
      );
      return '이어서 정리하면 이렇게야. $summary';
    }
    if (text.contains('안녕')) {
      return '안녕! 나는 MYB 음성 비서야. PDF, 대화, 검색을 같이 정리해 줄게.';
    }
    if (text.contains('요약')) {
      final summary = ExtractiveSummarizer.summarize(text, maxSentences: 2);
      return '핵심만 정리하면 이렇게야. $summary';
    }
    if (text.contains('검색') || text.toLowerCase().contains('rag')) {
      return 'RAG 검색 메뉴에서 저장해 둔 문장을 찾아볼 수 있어요.';
    }
    return '기록해 둘게요. "$text"';
  }
}
