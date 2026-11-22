// Supabase 연결 정보 (publishable 키는 공개되어도 되는 키입니다)
const SUPABASE_URL = "https://qipuagaqzvwghxuvulgr.supabase.co";
const SUPABASE_KEY = "sb_publishable_DXM8lm6acAEJ0HBpBi-Fnw_GWzjE2qf";

async function rpc(fn, args) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { apikey: SUPABASE_KEY, "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });
  if (!res.ok) {
    let detail = "";
    try { const j = await res.json(); detail = j.message || j.hint || JSON.stringify(j); } catch {}
    throw new Error(`${res.status} ${detail}`.trim());
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

// 010-1234-5678 형태로 맞추기
function formatPhone(v) {
  const d = String(v || "").replace(/\D/g, "").slice(0, 11);
  if (d.length < 4) return d;
  if (d.length < 8) return d.slice(0, 3) + "-" + d.slice(3);
  if (d.length === 10) return d.slice(0, 3) + "-" + d.slice(3, 6) + "-" + d.slice(6);
  return d.slice(0, 3) + "-" + d.slice(3, 7) + "-" + d.slice(7);
}
const PHONE_RE = /^01[0-9]-[0-9]{3,4}-[0-9]{4}$/;
