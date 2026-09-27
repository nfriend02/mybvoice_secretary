export default async function handler(req, res) {
  const query = String(req.query.q || "").trim();
  const key = process.env.YOUR_GOOGLE_MAPS_API_KEY || "";
  if (!query) {
    res.status(400).json({ error: "q is required" });
    return;
  }

  if (key) {
    const google = await googleGeocode(query, key);
    if (google) {
      res.status(200).json({ summary: google, source: "google" });
      return;
    }
  }

  const located = await nominatim(query);
  if (located) {
    res.status(200).json({ summary: located, source: "nominatim" });
    return;
  }

  res.status(502).json({
    error: key
      ? "Google Geocoding is not allowed for this key, and the place was not found"
      : "YOUR_GOOGLE_MAPS_API_KEY missing",
  });
}

async function googleGeocode(query, key) {
  const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
  url.searchParams.set("address", query);
  url.searchParams.set("key", key);
  url.searchParams.set("language", "ko");
  const response = await fetch(url);
  const data = await response.json();
  const first = data.results?.[0];
  if (!response.ok || data.status !== "OK" || !first) return "";
  return formatPlace(
    first.formatted_address || query,
    first.geometry?.location?.lat,
    first.geometry?.location?.lng,
  );
}

async function nominatim(query) {
  const url = new URL("https://nominatim.openstreetmap.org/search");
  url.searchParams.set("q", query);
  url.searchParams.set("format", "jsonv2");
  url.searchParams.set("limit", "1");
  url.searchParams.set("accept-language", "ko");
  const response = await fetch(url, {
    headers: {
      "User-Agent": "MYBVoiceSecretary/1.0 (https://mybvoice-secretary.vercel.app)",
      Accept: "application/json",
    },
  });
  if (!response.ok) return "";
  const rows = await response.json();
  const first = Array.isArray(rows) ? rows[0] : null;
  if (!first) return "";
  return formatPlace(first.display_name || query, first.lat, first.lon);
}

function formatPlace(name, lat, lng) {
  const mapUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${lat},${lng}`)}`;
  return `${name}\n${lat}, ${lng}\n${mapUrl}`;
}
