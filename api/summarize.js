import { askGemini } from "./gemini.js";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.status(405).json({ error: "POST only" });
    return;
  }

  const text = String((req.body && req.body.text) || "");
  const sentences = Number((req.body && req.body.sentences) || 3);
  const key = process.env.GEMINI_API_KEY || "";
  if (key && text.trim()) {
    try {
      const summary = await askGemini(
        `다음 글을 한국어로 ${Math.max(1, Math.min(8, sentences || 3))}문장 이내로 요약해 주세요.\n\n${text}`,
        key,
      );
      if (summary) {
        res.status(200).json({ summary, source: "gemini" });
        return;
      }
    } catch (error) {
      console.error("gemini summarize fallback", error.message);
    }
  }

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
