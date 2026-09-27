/// Guards conversation text before it is summarized and stored.
class TalkSummary {
  static bool canSummarize(String text) => text.trim().length >= 2;
}
