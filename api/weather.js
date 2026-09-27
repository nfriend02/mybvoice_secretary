export default async function handler(req, res) {
  const city = String(req.query.q || "Seoul").trim() || "Seoul";
  const key = process.env.OPENWEATHER_API_KEY || "";
  if (!key) {
    res.status(503).json({ error: "OPENWEATHER_API_KEY missing" });
    return;
  }

  const url = new URL("https://api.openweathermap.org/data/2.5/weather");
  url.searchParams.set("q", city);
  url.searchParams.set("appid", key);
  url.searchParams.set("units", "metric");
  url.searchParams.set("lang", "kr");

  const response = await fetch(url);
  const data = await response.json();
  if (!response.ok) {
    res.status(response.status).json({ error: data.message || "weather failed" });
    return;
  }

  const description = data.weather?.[0]?.description ?? "날씨";
  const temp = Math.round(data.main?.temp ?? 0);
  res.status(200).json({
    summary: `${data.name}: ${description}, ${temp}°C`,
  });
}
