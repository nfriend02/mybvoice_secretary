export default async function handler(req, res) {
  const base = String(req.query.base || "USD").trim().toUpperCase();
  const quote = String(req.query.quote || "KRW").trim().toUpperCase();
  const key = process.env.EXCHANGE_RATE_API_KEY || "";
  if (!key) {
    res.status(503).json({ error: "EXCHANGE_RATE_API_KEY missing" });
    return;
  }

  const url = `https://v6.exchangerate-api.com/v6/${key}/pair/${encodeURIComponent(base)}/${encodeURIComponent(quote)}`;
  const response = await fetch(url);
  const data = await response.json();
  if (!response.ok || data.result !== "success") {
    res.status(response.status || 502).json({
      error: data["error-type"] || "exchange failed",
    });
    return;
  }

  res.status(200).json({
    summary: `1 ${base} = ${data.conversion_rate} ${quote}`,
  });
}
