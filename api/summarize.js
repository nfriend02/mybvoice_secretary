export default function handler(req, res) {
  if (req.method !== "POST") {
    res.status(405).json({ error: "POST only" });
    return;
  }

  const text = String((req.body && req.body.text) || "");
  const sentences = Number((req.body && req.body.sentences) || 3);
  res.status(200).json({
    summary: summarize(text, sentences),
    source: "/api/summarize",
  });
}

function summarize(text, maxSentences) {
  const parts = text
    .split(/(?<=[.!?。])\s+|\n+/)
    .map((part) => part.trim())
    .filter(Boolean);
  const limit = Math.max(1, Math.min(8, maxSentences || 3));
  if (parts.length <= limit) return parts.join(" ");

  const freq = new Map();
  for (const sentence of parts) {
    for (const word of words(sentence)) {
      freq.set(word, (freq.get(word) || 0) + 1);
    }
  }

  const ranked = parts
    .map((sentence, index) => {
      let score = parts.length - index;
      for (const word of words(sentence)) score += freq.get(word) || 0;
      return { score, index, sentence };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .sort((a, b) => a.index - b.index);

  return ranked.map((row) => row.sentence).join(" ");
}

function words(sentence) {
  return sentence.toLowerCase().match(/[a-z0-9가-힣]{2,}/g) || [];
}
