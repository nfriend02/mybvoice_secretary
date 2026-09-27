export default function handler(req, res) {
  res.status(200).json({
    ok: true,
    service: "mybvoice_secretary",
    prefix: "/api",
  });
}
