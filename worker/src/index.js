/**
 * Max Coach – WHOOP Backend (Cloudflare Worker)
 * ------------------------------------------------------------------
 * Endpunkte:
 *   POST /exchange   { code, redirect_uri }   -> tauscht OAuth-Code in Token, speichert in KV
 *   POST /webhook                              -> empfängt WHOOP-Webhooks (Signatur-Check), 200
 *   GET  /data                                 -> liefert aktuelle WHOOP-Daten als JSON für die App
 *   GET  /login                                -> (optional) leitet zu WHOOP-Login weiter
 *   GET  /                                     -> Status
 *
 * Benötigt:
 *   - KV-Namespace gebunden als:  WHOOP_KV
 *   - Secrets / Variablen:
 *       CLIENT_ID      (WHOOP Client ID)
 *       CLIENT_SECRET  (WHOOP Client Secret)   <-- als Secret anlegen, nie öffentlich!
 *       APP_SECRET     (optional) schützt /data; gleicher Wert wie "Access-Token" in der App
 *       ALLOW_ORIGIN   (optional) z.B. https://deinname.github.io   (Default: *)
 *
 * WHOOP API: https://api.prod.whoop.com
 */

const WHOOP_TOKEN = "https://api.prod.whoop.com/oauth/oauth2/token";
const WHOOP_API   = "https://api.prod.whoop.com/developer/v1";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = env.ALLOW_ORIGIN || "*";
    const cors = {
      "Access-Control-Allow-Origin": origin,
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Atlas-Device, X-Atlas-Dev, X-Atlas-Token",
      "Access-Control-Max-Age": "86400",
      "Vary": "Origin",
    };
    // Zeitkonstanter Vergleich + Bearer-Prüfung (schützt vor Timing-Angriffen)
    const safeEqual = (a, b) => { a = String(a); b = String(b); if (a.length !== b.length) return false; let r = 0; for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i); return r === 0; };
    // Client-Auth: akzeptiert den öffentlichen Client-Token (bewusst NICHT geheim, steht so im index.html)
    // sowie optional in Cloudflare gesetzte CLIENT_TOKEN/APP_SECRET. So funktioniert die KI unabhängig davon,
    // ob CLIENT_TOKEN gesetzt wurde — echter Schutz = Quota + IP-Bremse + Budget-Sicherung, nicht dieser Token.
    const acceptTokens = ["atlas-pub-9m3xR7q2", env.CLIENT_TOKEN, env.APP_SECRET].filter(Boolean);
    const authOK = () => { const h = request.headers.get("Authorization") || ""; if (!h.startsWith("Bearer ")) return false; const t = h.slice(7); return acceptTokens.some((x) => safeEqual(t, x)); };
    // Developer-Zugang: Header X-Atlas-Dev == DEV_SECRET (eigenes, geheimes Secret; NICHT der öffentliche Client-Token)
    // → hebt das Gerät-Kontingent auf. Der globale Budget-Deckel bleibt als Notbremse aktiv.
    const isDev = () => { if (!env.DEV_SECRET) return false; const h = request.headers.get("X-Atlas-Dev") || ""; return h && safeEqual(h, env.DEV_SECRET); };
    const json = (obj, status = 200) =>
      new Response(JSON.stringify(obj), { status, headers: { "Content-Type": "application/json", ...cors } });

    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });

    try {
      // ---- Status ----
      if (url.pathname === "/" ) {
        return new Response("Atlas One Worker läuft. Endpunkte: /coach, /food, /ping, /exchange, /webhook, /data", { headers: cors });
      }

      // ---- KI-Diagnose (ohne LLM-Aufruf, ohne Kontingent) ----
      if (url.pathname === "/ping") {
        return json({ ok: true, coach: !!env.ANTHROPIC_API_KEY, auth: authOK(), model: env.COACH_MODEL || "claude-haiku-4-5-20251001" });
      }

      // ---- Konto-Registrierung: legt/aktualisiert den Nutzer im KV an (best-effort vom Client) ----
      if (url.pathname === "/register" && request.method === "POST") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        try {
          const { account, profile } = await request.json();
          if (!account || !account.deviceId) return json({ error: "bad_request" }, 400);
          const clip = (s, n) => (s == null ? "" : String(s).slice(0, n));
          const rec = {
            deviceId: clip(account.deviceId, 64),
            method: clip(account.method, 20),
            firstName: clip(account.firstName, 80),
            lastName: clip(account.lastName, 80),
            email: clip(account.email, 120),
            pro: !!account.pro,
            createdAt: account.createdAt || Date.now(),
            updatedAt: Date.now(),
            profile: profile ? {
              sex: clip(profile.sex, 4), age: parseInt(profile.age, 10) || null,
              weight: parseFloat(profile.weight) || null, height: parseFloat(profile.height) || null,
              birthday: clip(profile.birthday, 12), goal: clip(profile.goal, 20),
              bodyFat: parseFloat(profile.bodyFat) || null, foodPhil: clip(profile.foodPhil, 20),
            } : null,
          };
          if (env.WHOOP_KV) await env.WHOOP_KV.put("user:" + rec.deviceId, JSON.stringify(rec));
          return json({ ok: true });
        } catch (e) { return json({ error: "register_failed" }, 500); }
      }

      // ---- Admin: alle registrierten Nutzer als JSON (nur mit DEV_SECRET) ----
      if (url.pathname === "/admin/users" && request.method === "GET") {
        if (!isDev()) return json({ error: "forbidden" }, 403);
        if (!env.WHOOP_KV) return json({ count: 0, users: [] });
        const out = []; let cursor;
        do {
          const list = await env.WHOOP_KV.list({ prefix: "user:", cursor });
          for (const k of list.keys) { const v = await env.WHOOP_KV.get(k.name); if (v) { try { out.push(JSON.parse(v)); } catch (e) {} } }
          cursor = list.list_complete ? null : list.cursor;
        } while (cursor);
        return json({ count: out.length, users: out });
      }

      // ==== Account (E-Mail + Passwort) + Cloud-Sync der App-Daten ====
      const emailNorm = (e) => String(e || "").trim().toLowerCase().slice(0, 120);
      const toHex = (buf) => [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
      const pbkdf2 = async (pw, saltHex) => {
        const enc = new TextEncoder();
        const salt = Uint8Array.from(saltHex.match(/.{1,2}/g).map((x) => parseInt(x, 16)));
        const k = await crypto.subtle.importKey("raw", enc.encode(pw), "PBKDF2", false, ["deriveBits"]);
        const bits = await crypto.subtle.deriveBits({ name: "PBKDF2", salt, iterations: 100000, hash: "SHA-256" }, k, 256);
        return toHex(bits);
      };
      const newToken = () => toHex(crypto.getRandomValues(new Uint8Array(24)));
      const tokenEmail = async () => { const h = request.headers.get("X-Atlas-Token") || ""; if (!h || !env.WHOOP_KV) return null; return (await env.WHOOP_KV.get("tok:" + h)) || null; };
      // Developer-Accounts: per env DEV_EMAIL (kommagetrennt) markiert → unlimitierte KI/Uploads + Test-Funktionen, am Account statt am Gerät
      const devEmails = (env.DEV_EMAIL || "").toLowerCase().split(/[,;\s]+/).filter(Boolean);
      const isDevEmail = (em) => !!em && devEmails.indexOf(em) >= 0;
      const tokenIsDev = async () => { const em = await tokenEmail(); return isDevEmail(em); };
      const YEAR = 60 * 60 * 24 * 365;

      if (url.pathname === "/auth/register" && request.method === "POST") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        if (!env.WHOOP_KV) return json({ error: "storage_unavailable" }, 500);
        const { email, password } = await request.json().catch(() => ({}));
        const em = emailNorm(email);
        if (!em || em.indexOf("@") < 1 || !password || String(password).length < 6) return json({ error: "invalid" }, 400);
        if (await env.WHOOP_KV.get("acct:" + em)) return json({ error: "exists" }, 409);
        const saltHex = toHex(crypto.getRandomValues(new Uint8Array(16)));
        const hash = await pbkdf2(String(password), saltHex);
        await env.WHOOP_KV.put("acct:" + em, JSON.stringify({ email: em, salt: saltHex, hash, created: Date.now() }));
        const token = newToken();
        await env.WHOOP_KV.put("tok:" + token, em, { expirationTtl: YEAR });
        return json({ ok: true, token, email: em, dev: isDevEmail(em) });
      }

      if (url.pathname === "/auth/login" && request.method === "POST") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        if (!env.WHOOP_KV) return json({ error: "storage_unavailable" }, 500);
        const { email, password } = await request.json().catch(() => ({}));
        const em = emailNorm(email);
        const raw = em && (await env.WHOOP_KV.get("acct:" + em));
        if (!raw) return json({ error: "no_account" }, 404);
        const acc = JSON.parse(raw);
        const hash = await pbkdf2(String(password || ""), acc.salt);
        if (!safeEqual(hash, acc.hash)) return json({ error: "wrong_password" }, 401);
        const token = newToken();
        await env.WHOOP_KV.put("tok:" + token, em, { expirationTtl: YEAR });
        return json({ ok: true, token, email: em, dev: isDevEmail(em) });
      }

      // ---- Live-Dev-Status: liefert per Login-Token, ob die Mail in DEV_EMAIL steht ----
      if (url.pathname === "/auth/me" && request.method === "GET") {
        const em = await tokenEmail();
        if (!em) return json({ ok: false, error: "unauthorized" }, 401);
        return json({ ok: true, email: em, dev: isDevEmail(em), devEmailSet: !!(env.DEV_EMAIL || "").trim() });
      }

      if (url.pathname === "/state" && request.method === "GET") {
        const em = await tokenEmail();
        if (!em) return json({ error: "unauthorized" }, 401);
        const raw = await env.WHOOP_KV.get("state:" + em);
        return json({ ok: true, state: raw ? JSON.parse(raw) : null, email: em });
      }

      if (url.pathname === "/state" && request.method === "POST") {
        const em = await tokenEmail();
        if (!em) return json({ error: "unauthorized" }, 401);
        const body = await request.json().catch(() => ({}));
        if (!body || typeof body.state !== "object" || body.state === null) return json({ error: "bad_request" }, 400);
        const str = JSON.stringify(body.state);
        if (str.length > 3000000) return json({ error: "too_large" }, 413);
        await env.WHOOP_KV.put("state:" + em, str);
        return json({ ok: true, savedAt: Date.now() });
      }

      // ---- Lebensmittel-Suche: USDA FoodData Central (große generische Datenbank; kostenlos) ----
      if (url.pathname === "/foodsearch" && request.method === "GET") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        const q = (url.searchParams.get("q") || "").slice(0, 80).trim();
        if (!q) return json({ items: [] });
        const key = env.USDA_KEY || "DEMO_KEY";
        try {
          const r = await fetch("https://api.nal.usda.gov/fdc/v1/foods/search?pageSize=25&dataType=" +
            encodeURIComponent("Foundation,SR Legacy,Branded") + "&query=" + encodeURIComponent(q) + "&api_key=" + encodeURIComponent(key));
          if (!r.ok) return json({ items: [] });
          const d = await r.json();
          const nv = (x) => { const v = parseFloat(x); return isFinite(v) ? v : 0; };
          const items = (d.foods || []).map((f) => {
            const nut = {};
            (f.foodNutrients || []).forEach((n) => { const id = n.nutrientNumber || n.number; if (id != null) nut[String(id)] = n.value; });
            const kcal = nv(nut["1008"]) || nv(nut["2047"]) || nv(nut["2048"]);
            const nm = (f.description || "").trim();
            if (!nm || !kcal) return null;
            const brand = (f.brandOwner || f.brandName || "").trim();
            const cap = (s) => s.replace(/\s+/g, " ").trim();
            // Mikronährstoffe pro 100 g (USDA FDC-Nummern → App-Keys)
            const MI = { vitd:"1114", mag:"1090", b12:"1178", fol:"1177", zinc:"1095", iron:"1089", b6:"1175", b2:"1166", vitc:"1162", sel:"1103", cho:"1180", cal:"1087", pot:"1092", fib:"1079" };
            const mi100 = {};
            for (const kk in MI) { const val = nv(nut[MI[kk]]); if (val > 0) mi100[kk] = Math.round(val * 100) / 100; }
            return { name: cap(nm.charAt(0) + nm.slice(1).toLowerCase()) + (brand ? " · " + cap(brand) : ""),
              per100: { kcal: Math.round(kcal), p: Math.round(nv(nut["1003"]) * 10) / 10, c: Math.round(nv(nut["1005"]) * 10) / 10, f: Math.round(nv(nut["1004"]) * 10) / 10 },
              mi100: mi100 };
          }).filter(Boolean);
          return json({ items });
        } catch (e) { return json({ items: [] }); }
      }

      // ---- (optional) Login-Weiterleitung ----
      if (url.pathname === "/login" && request.method === "GET") {
        const redirect = url.searchParams.get("redirect_uri") || "";
        const state = Math.random().toString(36).slice(2, 12);
        const scope = "read:recovery read:sleep read:workout read:cycles read:profile offline";
        const auth = "https://api.prod.whoop.com/oauth/oauth2/auth?response_type=code"
          + "&client_id=" + encodeURIComponent(env.CLIENT_ID)
          + "&redirect_uri=" + encodeURIComponent(redirect)
          + "&scope=" + encodeURIComponent(scope)
          + "&state=" + state;
        return Response.redirect(auth, 302);
      }

      // ---- OAuth-Code -> Token ----
      if (url.pathname === "/exchange" && request.method === "POST") {
        const { code, redirect_uri } = await request.json();
        if (!code || !redirect_uri) return json({ error: "missing code/redirect_uri" }, 400);
        const body = new URLSearchParams({
          grant_type: "authorization_code",
          code,
          redirect_uri,
          client_id: env.CLIENT_ID,
          client_secret: env.CLIENT_SECRET,
        });
        const r = await fetch(WHOOP_TOKEN, {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body,
        });
        if (!r.ok) return json({ error: "token_exchange_failed", status: r.status, detail: await r.text() }, 502);
        const tok = await r.json();
        await saveTokens(env, tok);
        return json({ ok: true });
      }

      // ---- Webhook-Empfang (Signaturprüfung) ----
      if (url.pathname === "/webhook" && request.method === "POST") {
        const raw = await request.text();
        const sig = request.headers.get("X-WHOOP-Signature");
        const ts  = request.headers.get("X-WHOOP-Signature-Timestamp");
        const ok = await verifyWhoopSignature(env.CLIENT_SECRET, ts, raw, sig);
        if (!ok) return new Response("invalid signature", { status: 401, headers: cors });
        // Pull-Modell: wir bestätigen nur schnell. /data holt beim nächsten Sync ohnehin frische Daten.
        return new Response("ok", { status: 200, headers: cors });
      }

      // ---- Coach (LLM-Chat mit Zugriff auf die App-Daten) ----
      if (url.pathname === "/coach" && request.method === "POST") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        if (!env.ANTHROPIC_API_KEY) return json({ error: "coach_not_configured" }, 400);
        // --- Sicherheit: Gratis-Kontingent pro Gerät + globaler Budget-Deckel (Developer: kein Limit) ---
        const devHdr = request.headers.get("X-Atlas-Device") || "";
        const dev = isDev() || (await tokenIsDev());
        const q = dev ? { ok: true, used: 0, limit: Infinity, key: null } : await checkQuota(env, devHdr, "coach", parseInt(env.COACH_FREE || "10", 10));
        if (!q.ok) return json({ error: "quota_exceeded", kind: "coach", limit: q.limit, used: q.used }, 429);
        const ip = request.headers.get("CF-Connecting-IP") || "";
        if (!dev && !(await ipGate(env, ip, "coach", parseInt(env.IP_HOURLY || "40", 10)))) return json({ error: "rate_limited" }, 429);
        if (!(await budgetGate(env))) return json({ error: "budget_exceeded" }, 503);
        const { messages, snapshot } = await request.json();
        const sys =
          "You are Atlas, the user's personal performance, health and longevity coach inside the app 'Atlas One'. " +
          "You have COMPLETE access to the user's app data (below as JSON): every tracked day with all logged meals (incl. per-food 1-5 score), every training set (weight/reps/RIR) and cardio session, sleep, recovery, WHOOP data, all micronutrients with 14-day averages vs. DRI/optimum, every supplement, peptide and medication with dose, all blood values, methylation SNPs, body-composition history, journal entries, personal records and goals. The field app_logik explains exactly how the app calculates its scores - always argue consistently with it and never contradict what the app displays.\n" +
          "Use the real history: when asked about yesterday, last week, trends or progress, look it up FIRST in wochenrueckblick (ready-made weekly aggregates incl. average day score, training days, total sets, volume, cardio minutes, kcal, protein, sleep), score_verlauf_30t (daily scores) and historie_alle_tage (every logged day in full detail). training_heute and cardio_heute hold today's session.\n" +
          "NEVER say you cannot see the user's history or ask them to paste their workouts - the data is in this JSON. Only if a field is genuinely empty, say that nothing was tracked for that period. Cite concrete numbers and dates.\n" +
          "SCORES - do not mix them up: trainings_score is the training ring the user sees on the training page; atlas_tagesscore is the overall day score on the home screen. If the user asks about their training score, quote trainings_score / trainings_score_schnitt only. If your number contradicts what the user says they saw, assume you took the wrong field and re-check trainings_score before telling them they are wrong.\n\n" +
          "STYLE RULES — follow exactly:\n" +
          "1. LANGUAGE: Always reply in the SAME language the user writes in. German in → German out, English in → English out. Never switch languages on your own.\n" +
          "2. Most important thing FIRST. Lead with the answer or the key action, then briefly why.\n" +
          "3. Be solution-oriented: every answer gives a concrete next step or recommendation, never just describes the problem.\n" +
          "4. As FEW characters as possible. Short sentences. Explain simply, no filler, no repetition, no long intros or outros.\n" +
          "5. Highlight the few most important words/numbers in **bold** using double asterisks (the app renders them as bold). Do not overuse it — only the essentials.\n" +
          "6. NO emojis. NO single asterisks, no markdown headings, no tables. Only plain text, **bold**, and simple lines. For lists use short lines starting with '- '.\n" +
          "7. Clean and easy to read: use line breaks between points instead of long blocks.\n\n" +
          "PRIORITIZE: Sleep > Nutrition > Training > Recovery, then the rest. Let evidence-based protocol principles (Huberman-style) flow in where relevant — e.g. morning light for circadian anchoring, caffeine 90–120 min after waking and cutoff ~10 h before sleep, training in the late-afternoon performance window, NSDR/breaks for recovery, zone-2 cardio, consistent sleep/wake times. Use them only when they fit the question; don't force them. " +
          "PEPTIDES & MEDICATIONS — harm reduction, not prescribing: You do not recommend, encourage or prescribe peptides, PEDs or prescription drugs. But if the user states a plan, you may put it in factual context to prevent serious mistakes — flag clearly when a stated dose, frequency or route is far outside the commonly reported range, name the typical reported range for orientation (e.g. BPC-157 is usually dosed in the hundreds of micrograms, not grams), and warn about obvious dangers or interactions. Frame it as neutral information, never as an instruction to take anything, and always recommend medical supervision and bloodwork for injectables, hormones and prescription drugs. " +
          "Give no medical diagnosis; for risky topics recommend seeing a doctor.\n\nCURRENT USER DATA (JSON):\n" +
          JSON.stringify(snapshot || {});
        const msgs = (messages || [])
          .filter((m) => m && m.content && m.content !== "…")
          .slice(-24)
          .map((m) => ({ role: m.role === "assistant" ? "assistant" : "user", content: String(m.content).slice(0, 4000) }));
        const body = {
          model: env.COACH_MODEL || "claude-haiku-4-5-20251001",
          max_tokens: 1400,
          system: sys,
          messages: msgs.length ? msgs : [{ role: "user", content: "Gib mir einen kurzen Überblick über meinen heutigen Tag und die wichtigste Empfehlung." }],
        };
        const r = await fetch("https://api.anthropic.com/v1/messages", {
          method: "POST",
          headers: {
            "x-api-key": env.ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
        if (!r.ok) return json({ error: "llm_error", detail: (await r.text()).slice(0, 300) }, 502);
        const d = await r.json();
        const reply = (d.content && d.content[0] && d.content[0].text) || "";
        if (!dev) await incQuota(env, q.key);
        return json({ reply, quota: { kind: "coach", used: q.used + 1, limit: q.limit } });
      }

      // ---- Foto-Mahlzeit-Analyse (Vision) ----
      if (url.pathname === "/food" && request.method === "POST") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        if (!env.ANTHROPIC_API_KEY) return json({ error: "coach_not_configured" }, 400);
        // --- Gratis-Kontingent: 2 Foto-Scans gesamt pro Gerät + globaler Budget-Deckel (Developer: kein Limit) ---
        const devHdrF = request.headers.get("X-Atlas-Device") || "";
        const devF = isDev() || (await tokenIsDev());
        const qf = devF ? { ok: true, used: 0, limit: Infinity, key: null } : await checkQuota(env, devHdrF, "food", parseInt(env.FOOD_FREE || "2", 10));
        if (!qf.ok) return json({ error: "quota_exceeded", kind: "food", limit: qf.limit, used: qf.used }, 429);
        const ipF = request.headers.get("CF-Connecting-IP") || "";
        if (!devF && !(await ipGate(env, ipF, "food", parseInt(env.IP_HOURLY_FOOD || "15", 10)))) return json({ error: "rate_limited" }, 429);
        if (!(await budgetGate(env))) return json({ error: "budget_exceeded" }, 503);
        const { image, note } = await request.json();
        let media_type = "image/jpeg", data = image || "";
        const m = /^data:(image\/[a-zA-Z0-9.+-]+);base64,([\s\S]*)$/.exec(data);
        if (m) { media_type = m[1]; data = m[2]; }
        if (!data) return json({ error: "no_image" }, 400);
        if (data.length > 9_000_000) return json({ error: "image_too_large" }, 413); // ~6.5 MB Bild
        if (note && String(note).length > 500) return json({ error: "note_too_long" }, 400);
        // --- Spezialisierte Food-Erkennung via LogMeal (nur wenn LOGMEAL_KEY gesetzt). Bei jedem Fehler → Fallback auf Claude-Vision unten. ---
        if (env.LOGMEAL_KEY) {
          try {
            const binL = atob(data); const bytesL = new Uint8Array(binL.length); for (let k = 0; k < binL.length; k++) bytesL[k] = binL.charCodeAt(k);
            const blobL = new Blob([bytesL], { type: media_type });
            const fdL = new FormData(); fdL.append("image", blobL, "meal.jpg");
            const seg = await fetch("https://api.logmeal.com/v2/image/segmentation/complete/v1.0", { method: "POST", headers: { Authorization: "Bearer " + env.LOGMEAL_KEY }, body: fdL });
            if (seg.ok) {
              const sd = await seg.json();
              const imageId = sd.imageId || sd.image_id;
              const names = [];
              (sd.segmentation_results || []).forEach((s) => { const rr = (s.recognition_results || [])[0]; if (rr && rr.name) names.push(rr.name); });
              if (imageId) {
                const nu = await fetch("https://api.logmeal.com/v2/nutrition/recipe/nutritionalInfo/v1.0", { method: "POST", headers: { Authorization: "Bearer " + env.LOGMEAL_KEY, "Content-Type": "application/json" }, body: JSON.stringify({ imageId }) });
                if (nu.ok) {
                  const nd = await nu.json();
                  const tn = (nd.nutritional_info && nd.nutritional_info.totalNutrients) || nd.totalNutrients || {};
                  const gv = (k) => (tn[k] && tn[k].quantity != null) ? Math.round(tn[k].quantity) : 0;
                  const total = { kcal: gv("ENERC_KCAL"), p: gv("PROCNT"), c: gv("CHOCDF"), f: gv("FAT") };
                  const serv = nd.serving_size || (nd.nutritional_info && nd.nutritional_info.serving_size) || null;
                  if (total.kcal > 0) {
                    const fn = Array.isArray(nd.foodName) ? nd.foodName[0] : nd.foodName;
                    const out = { items: [{ name: String(names[0] || fn || "Erkannte Mahlzeit"), grams: serv ? Math.round(serv) : null, kcal: total.kcal, p: total.p, c: total.c, f: total.f, mi: {} }], total: total, source: "logmeal" };
                    if (!devF) await incQuota(env, qf.key);
                    out.quota = { kind: "food", used: qf.used + 1, limit: qf.limit };
                    return json(out);
                  }
                }
              }
            }
          } catch (e) { /* Fallback auf Claude-Vision */ }
        }
        const sys =
          "Du bist ein präziser Ernährungs-Analyst für Foto-Erkennung. Gehe SCHRITTWEISE vor (aber gib nur das finale JSON aus):\n" +
          "1) Identifiziere jedes einzelne Lebensmittel auf dem Teller so genau wie möglich (Zubereitungsart beachten: roh/gebraten/frittiert/paniert, sichtbares Öl, Soßen). Bei schlechtem Licht oder Unschärfe: nenne die WAHRSCHEINLICHSTE Option statt aufzugeben.\n" +
          "2) Schätze die Portionsgröße in Gramm mit visuellen Referenzen: Teller-Durchmesser ~26 cm, Gabel ~19 cm, eine Handfläche ~120 g Fleisch, eine Faust ~150 g Beilage, ein Esslöffel Öl ~12 g. Nutze Höhe/Volumen, nicht nur Fläche.\n" +
          "3) Berechne die Nährwerte FÜR DIE GESCHÄTZTE PORTION (nicht pro 100 g), inkl. sichtbarem Koch-Öl/Butter/Soße.\n" +
          "Erkenne auch EINFACHE Einzel-Lebensmittel sicher (z.B. eine Banane, ein Apfel, ein Brötchen, ein Glas Milch, ein Joghurt, ein Steak, eine Handvoll Nüsse) — nicht nur komplexe Teller. Gib IMMER mindestens ein Item zurück; ist etwas unklar, nimm die WAHRSCHEINLICHSTE Vermutung mit realistischer Portion statt leer zu antworten. Deutsche Alltagslebensmittel bevorzugen.\n" +
          "Wenn eine Textnotiz mitgegeben wird, hat sie Vorrang vor deiner Bild-Schätzung. Lieber eine plausible Schätzung als gar keine.\n" +
          "Antworte AUSSCHLIESSLICH mit reinem JSON (kein Markdown, kein Text drumherum) in genau diesem Schema: " +
          '{"items":[{"name":string,"grams":number,"kcal":number,"p":number,"c":number,"f":number,"nova":number,"mi":{}}],"total":{"kcal":number,"p":number,"c":number,"f":number}}. ' +
          "Das Feld nova ist der geschaetzte Verarbeitungsgrad je Item (NOVA): 1=unverarbeitet/frisch (z.B. Apfel, Ei, Haehnchenbrust, Gemuese), 2=Kuechenzutat (Oel, Butter, Zucker), 3=verarbeitet (Brot, Kaese, Konserve), 4=hochverarbeitet/Fertigprodukt (Fastfood, Chips, Suessigkeiten, Softdrinks, Fertiggerichte). Schaetze nova immer, auch bei Unsicherheit. " +
          "Das Feld mi ist optional und darf nur diese Keys nutzen (Einheiten in Klammern): vitd(mcg),mag(mg),ome(mg),b12(mcg),fol(mcg),zinc(mg),iron(mg),b6(mg),k2(mcg),b2(mg),vitc(mg),sel(mcg),cho(mg),cal(mg),pot(mg),fib(g). " +
          "Schätze bestmöglich, auch wenn du unsicher bist. Namen auf Deutsch.";
        const body = {
          model: env.VISION_MODEL || "claude-haiku-4-5-20251001",
          max_tokens: 1300,
          system: sys,
          messages: [{ role: "user", content: [
            { type: "image", source: { type: "base64", media_type, data } },
            { type: "text", text: "Analysiere diese Mahlzeit." + (note ? " Zusatzinfo: " + note : "") },
          ]}],
        };
        const r2 = await fetch("https://api.anthropic.com/v1/messages", {
          method: "POST",
          headers: { "x-api-key": env.ANTHROPIC_API_KEY, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
          body: JSON.stringify(body),
        });
        if (!r2.ok) return json({ error: "vision_error", detail: (await r2.text()).slice(0, 300) }, 502);
        const d2 = await r2.json();
        const txt = (d2.content && d2.content[0] && d2.content[0].text) || "";
        let parsed = null;
        try { const jm = txt.match(/\{[\s\S]*\}/); parsed = JSON.parse(jm ? jm[0] : txt); } catch (e) {}
        if (!parsed || !parsed.items) return json({ error: "parse_failed", raw: txt.slice(0, 300) }, 502);
        if (!devF) await incQuota(env, qf.key);
        parsed.quota = { kind: "food", used: qf.used + 1, limit: qf.limit };
        return json(parsed);
      }

      // ---- Daten für die App ----
      if (url.pathname === "/data" && request.method === "GET") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        const access = await getAccessToken(env);
        if (!access) return json({ error: "not_connected" }, 401);
        const data = await pullWhoop(access);
        return json(data);
      }

      // ---- Tagesplan: Arbeits-/Gym-Zonen aus WHOOP (für Kalender/Kurzbefehl) ----
      if (url.pathname === "/plan" && request.method === "GET") {
        if (!authOK()) return json({ error: "unauthorized" }, 401);
        const access = await getAccessToken(env);
        if (!access) return json({ error: "not_connected" }, 401);
        const plan = await computePlan(access);
        return json(plan);
      }

      return json({ error: "not_found" }, 404);
    } catch (e) {
      return json({ error: "worker_error", detail: String(e) }, 500);
    }
  },
};

// ---------- Token-Verwaltung ----------
async function saveTokens(env, tok) {
  const rec = {
    access_token: tok.access_token,
    refresh_token: tok.refresh_token,
    expires_at: Date.now() + (tok.expires_in || 3600) * 1000,
  };
  await env.WHOOP_KV.put("tokens", JSON.stringify(rec));
  return rec;
}

async function getAccessToken(env) {
  const raw = await env.WHOOP_KV.get("tokens");
  if (!raw) return null;
  let t = JSON.parse(raw);
  if (Date.now() < t.expires_at - 60000) return t.access_token; // noch gültig
  // Refresh
  if (!t.refresh_token) return null;
  const body = new URLSearchParams({
    grant_type: "refresh_token",
    refresh_token: t.refresh_token,
    client_id: env.CLIENT_ID,
    client_secret: env.CLIENT_SECRET,
    scope: "offline",
  });
  const r = await fetch(WHOOP_TOKEN, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });
  if (!r.ok) return null;
  const tok = await r.json();
  const saved = await saveTokens(env, tok);
  return saved.access_token;
}

// ---------- WHOOP-Daten ziehen & normalisieren ----------
async function pullWhoop(access) {
  const h = { Authorization: "Bearer " + access };
  const get = async (path) => {
    const r = await fetch(WHOOP_API + path, { headers: h });
    if (!r.ok) return null;
    return r.json();
  };

  const out = {};

  // Cycle (latest) -> day strain + cycle_id für Recovery
  const cycles = await get("/cycle?limit=1");
  const cycle = cycles && cycles.records && cycles.records[0];
  if (cycle) {
    const date = (cycle.start || cycle.created_at || "").slice(0, 10);
    out.cycle = { date, score: cycle.score || {} };
    // Recovery für diesen Cycle
    const rec = await get("/cycle/" + cycle.id + "/recovery");
    if (rec && rec.score) {
      out.recovery = { date, score: rec.score };
    }
  }

  // Sleep (latest)
  const sleeps = await get("/activity/sleep?limit=1");
  const sleep = sleeps && sleeps.records && sleeps.records[0];
  if (sleep) {
    const date = (sleep.end || sleep.start || "").slice(0, 10);
    out.sleep = { date, score: sleep.score || {}, start: sleep.start, end: sleep.end, tz: sleep.timezone_offset };
  }

  // Workout (latest)
  const workouts = await get("/activity/workout?limit=1");
  const workout = workouts && workouts.records && workouts.records[0];
  if (workout) {
    const date = (workout.start || workout.created_at || "").slice(0, 10);
    out.workout = { date, score: workout.score || {} };
  }

  return out;
}

// ---------- Tagesplan (Arbeits-/Gym-Zonen aus WHOOP) ----------
// Portiert die Zwei-Prozess-Energiekurve + Zonen-Logik der App auf den Server.
// Ernährung liegt nur lokal in der App vor → hier neutral (Timing der Zonen wird
// ohnehin von Aufwachzeit, Recovery & Circadianik bestimmt, nicht von den Makros).
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
function localHour(iso, tz) {
  if (!iso) return null;
  const d = new Date(iso);
  if (isNaN(d)) return null;
  let h = d.getUTCHours() + d.getUTCMinutes() / 60;
  if (tz) { const m = /([+-])(\d\d):(\d\d)/.exec(tz); if (m) h += (m[1] === "-" ? -1 : 1) * (+m[2] + (+m[3]) / 60); }
  return ((h % 24) + 24) % 24;
}
function fmtHM(x) { const h = Math.floor(x), m = Math.round((x - h) * 60); if (m === 60) return (h + 1) + ":00"; return h + ":" + String(m).padStart(2, "0"); }

async function computePlan(access) {
  const h = { Authorization: "Bearer " + access };
  const get = async (path) => { const r = await fetch(WHOOP_API + path, { headers: h }); return r.ok ? r.json() : null; };

  // Recovery (über letzten Cycle)
  let rec = 50;
  const cycles = await get("/cycle?limit=1");
  const cycle = cycles && cycles.records && cycles.records[0];
  if (cycle) { const rr = await get("/cycle/" + cycle.id + "/recovery"); if (rr && rr.score && rr.score.recovery_score != null) rec = rr.score.recovery_score; }

  // Schlaf (letzter) + Historie (Rhythmus)
  const sleeps = await get("/activity/sleep?limit=14");
  const recs = (sleeps && sleeps.records) || [];
  const sleep = recs[0];
  let sleepH = 7, sleepPerf = 70, wakeH = 7, needH = 8, tz = null, date = new Date().toISOString().slice(0, 10);
  if (sleep) {
    const s = sleep.score || {}, ss = s.stage_summary || {};
    tz = sleep.timezone_offset;
    if (ss.total_in_bed_time_milli != null) sleepH = (ss.total_in_bed_time_milli - (ss.total_awake_time_milli || 0)) / 3600000;
    else if (s.total_sleep_milli != null) sleepH = s.total_sleep_milli / 3600000;
    if (s.sleep_performance_percentage != null) sleepPerf = s.sleep_performance_percentage;
    if (sleep.end) { const wh = localHour(sleep.end, tz); if (wh != null) wakeH = wh; }
    if (s.sleep_needed && s.sleep_needed.baseline_milli != null) {
      needH = (s.sleep_needed.baseline_milli + (s.sleep_needed.need_from_sleep_debt_milli || 0) + (s.sleep_needed.need_from_recent_strain_milli || 0) + (s.sleep_needed.need_from_recent_nap_milli || 0)) / 3600000;
    }
    // lokales Datum des Aufwach-Tages
    if (sleep.end) { const d = new Date(sleep.end); if (tz) { const m = /([+-])(\d\d):(\d\d)/.exec(tz); if (m) d.setUTCMinutes(d.getUTCMinutes() + (m[1] === "-" ? -1 : 1) * (+m[2] * 60 + (+m[3]))); } date = d.toISOString().slice(0, 10); }
  }
  // Schlaf-Rhythmus: mittlere Consistency der Historie → Melatonin-Regulation
  let cSum = 0, cN = 0;
  recs.forEach(r => { const c = r.score && r.score.sleep_consistency_percentage; if (c != null) { cSum += c; cN++; } });
  const rhythm = cN ? clamp((cSum / cN) / 100, 0.35, 1) : 0.72;

  const pts = planCurve({ rec, sleepH, sleepPerf, wakeH, needH, rhythm });
  const z = planZones(pts);
  const off = tz || "+00:00";
  const iso = dec => { let h = Math.floor(dec), m = Math.round((dec - h) * 60); if (m === 60) { h++; m = 0; } return date + "T" + String(h).padStart(2, "0") + ":" + String(m).padStart(2, "0") + ":00" + off; };
  const mk = (a, b, title) => ({ start: a, end: b, startHM: fmtHM(a), endHM: fmtHM(b), startISO: iso(a), endISO: iso(b), title });
  const work = z.work.map(w => mk(w[0], w[1], "Fokus-Arbeit"));
  const gym = mk(z.train[0], z.train[1], "Training / Gym");
  return {
    date, tz,
    wake: Math.round(wakeH * 100) / 100, wakeHM: fmtHM(wakeH),
    peak: z.peak, peakHM: fmtHM(z.peak),
    recovery: Math.round(rec),
    work, gym,
    events: work.concat([gym]), // fertige Liste für Kalender/Kurzbefehl (Arbeit + Gym)
  };
}

function planCurve(w) {
  const debt = clamp((7.5 - w.sleepH) / 3, 0, 1);
  const awake = clamp(24 - w.needH, 14, 18);
  const melOnset = awake - (1.4 + w.rhythm * 1.6);
  const melSlope = 4 + w.rhythm * 5;
  const base = 42 + (w.rec - 50) * 0.55 + (w.sleepPerf - 70) * 0.14; // Ernährung neutral
  const pts = [];
  for (let h = 0; h < 24; h++) {
    const t = ((h - w.wakeH) % 24 + 24) % 24;
    let v;
    if (t > awake) { v = 12 - debt * 3; }
    else {
      const car = Math.exp(-Math.pow(t - 2.5, 2) / 6) * 22;
      const inertia = t < 1.5 ? (1.5 - t) / 1.5 * 22 * (0.6 + debt) : 0;
      const homeo = -t * 1.4;
      const afternoon = Math.exp(-Math.pow(h - 16.5, 2) / 8) * 18;
      const lunch = Math.exp(-Math.pow(h - 14.5, 2) / 3.2) * 11;
      const melatonin = (t > melOnset) ? -(t - melOnset) * melSlope : 0;
      v = base + car + afternoon - lunch - inertia + homeo + melatonin;
    }
    pts.push(clamp(Math.round(v), 5, 100));
  }
  return pts;
}

function planZones(pts) {
  const lo = 6, hi = 22;
  let max = 0; for (let h = lo; h <= hi; h++) max = Math.max(max, pts[h]);
  const thr = Math.max(58, max * 0.82);
  const at = x => { const i = Math.floor(x), f = x - i; const a = pts[i] != null ? pts[i] : 0, b = pts[i + 1] != null ? pts[i + 1] : a; return a * (1 - f) + b * f; };
  const regions = []; let stt = null;
  for (let h = lo; h <= hi; h++) { if (pts[h] >= thr) { if (stt == null) stt = h; } else { if (stt != null) { regions.push([stt, h]); stt = null; } } }
  if (stt != null) regions.push([stt, hi + 1]);
  let work = [];
  regions.forEach(([a, b]) => { let pk = a; for (let h = a; h < b; h++) if (pts[h] > pts[pk]) pk = h; const s = clamp(pk - 1, lo, hi - 3); work.push([s, s + 3]); });
  work.sort((x, y) => x[0] - y[0]); const merged = []; work.forEach(w => { const l = merged[merged.length - 1]; if (l && w[0] <= l[1] + 0.01) l[1] = Math.max(l[1], w[1]); else merged.push(w.slice()); }); work = merged;
  let peak = lo; for (let h = lo; h <= hi; h++) if (pts[h] > pts[peak]) peak = h;
  if (!work.length) { const s = clamp(peak - 1, lo, hi - 3); work = [[s, s + 3]]; }
  const scan = (a, b) => { let bs = a, bv = -1; for (let s = a; s <= b - 1.5; s += 0.5) { const v = (at(s) + at(s + 0.75) + at(s + 1.5)) / 3; if (v > bv) { bv = v; bs = s; } } return { s: bs, v: bv }; };
  let gy = scan(14.5, 18.5);
  if (gy.v < thr - 8) { const g2 = scan(lo, hi); gy = { s: g2.s, v: g2.v }; }
  const gs = gy.s, ge = gy.s + 1.5, cut = [gs - 0.5, ge + 0.5];
  const sub = w => { const out = []; if (cut[0] > w[0]) out.push([w[0], Math.min(w[1], cut[0])]); if (cut[1] < w[1]) out.push([Math.max(w[0], cut[1]), w[1]]); return out.filter(x => x[1] - x[0] >= 1); };
  work = work.reduce((a, w) => a.concat(sub(w)), []);
  if (!work.length) { let bs = lo, bv = -1; for (let sst = lo; sst <= hi - 3; sst += 0.5) { if (sst + 3 <= cut[0] || sst >= cut[1]) { const v = (at(sst) + at(sst + 1.5) + at(sst + 3)) / 3; if (v > bv) { bv = v; bs = sst; } } } work = [[bs, bs + 3]]; }
  return { work, peak, train: [gs, ge], max, thr };
}

// ---------- Sicherheit: Kontingent (gesamt pro Gerät) + globaler Budget-Deckel (pro Tag) ----------
// Gratisplan: feste Gesamt-Anzahl pro Gerät (kein Tageszähler). Premium (später) hebt das auf.
async function checkQuota(env, dev, kind, limit) {
  try {
    if (!env.WHOOP_KV || !dev) return { ok: true, used: 0, limit, key: null };
    const key = "q:" + kind + ":" + dev;
    const used = parseInt((await env.WHOOP_KV.get(key)) || "0", 10);
    if (used >= limit) return { ok: false, used, limit, key };
    return { ok: true, used, limit, key };
  } catch (e) { return { ok: true, used: 0, limit, key: null }; }
}
async function incQuota(env, key) {
  try { if (!env.WHOOP_KV || !key) return; const used = parseInt((await env.WHOOP_KV.get(key)) || "0", 10) + 1; await env.WHOOP_KV.put(key, String(used)); } catch (e) {}
}
// Anti-Missbrauch: Pro-IP-Stundenbremse. Echte Nutzer haben je eigene IP und lösen kaum aus;
// wer Geräte-IDs rotiert, sitzt meist hinter wenigen IPs und wird hier gebremst. Skaliert mit echter Nutzerzahl.
async function ipGate(env, ip, kind, perHour) {
  try {
    if (!env.WHOOP_KV || !ip || perHour <= 0) return true;
    const hour = new Date().toISOString().slice(0, 13); // YYYY-MM-DDTHH (UTC)
    const key = "ip:" + kind + ":" + ip + ":" + hour;
    const used = parseInt((await env.WHOOP_KV.get(key)) || "0", 10);
    if (used >= perHour) return false;
    await env.WHOOP_KV.put(key, String(used + 1), { expirationTtl: 7200 });
    return true;
  } catch (e) { return true; }
}
// Notaus-Sicherung (kein „Deckel für den Alltag"): nur ein hoher Schutz gegen Bug/Massen-Angriff.
// Bewusst großzügig, damit echtes Wachstum NIE blockiert wird. Euro-Umrechnung (Haiku 4.5): ~0,006 €/Aufruf → 8000 ≈ ~50 €/Tag max.
async function budgetGate(env) {
  try {
    if (!env.WHOOP_KV) return true;
    const cap = parseInt(env.DAILY_CALL_CAP || "8000", 10);
    const day = new Date().toISOString().slice(0, 10);
    const key = "budget:" + day;
    const used = parseInt((await env.WHOOP_KV.get(key)) || "0", 10);
    if (used >= cap) return false;
    await env.WHOOP_KV.put(key, String(used + 1), { expirationTtl: 172800 });
    return true;
  } catch (e) { return true; }
}

// ---------- Webhook-Signatur (HMAC-SHA256, base64) ----------
async function verifyWhoopSignature(secret, timestamp, rawBody, signature) {
  if (!secret || !timestamp || !signature) return false;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const data = new TextEncoder().encode(timestamp + rawBody);
  const mac = await crypto.subtle.sign("HMAC", key, data);
  const b64 = btoa(String.fromCharCode(...new Uint8Array(mac)));
  return b64 === signature;
}
