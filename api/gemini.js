const models = ["gemini-3.8-flash", "gemini-flash-latest"];

export async function askGemini(prompt, key) {
  let lastError = new Error("gemini failed");
  for (const model of models) {
    try {
      return await askModel(model, prompt, key);
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}

async function askModel(model, prompt, key) {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": key,
      },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
      }),
    },
  );
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(detail.slice(0, 180));
  }
  const data = await response.json();
  const parts = data?.candidates?.[0]?.content?.parts ?? [];
  const text = parts
    .map((part) => (typeof part.text === "string" ? part.text : ""))
    .join("")
    .trim();
  if (!text) throw new Error(`${model} returned an empty answer`);
  return text;
}
