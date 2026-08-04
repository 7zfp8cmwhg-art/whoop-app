# Atlas One / Max Coach — Scoring & Tracking Logic

Extracted directly from `index.html` (~7000 lines, single-file app). This document is a
line-referenced map of every scoring formula, reference table, and tracked category in the
app, plus a comparison against the app's own built-in self-description object (`app_logik`,
`index.html:6320-6336`), which is sent to the AI coach backend so it can explain scores
consistently to the user.

All line numbers refer to `index.html` as it exists at the time of writing. All quotes from
`app_logik` are the original German text (verbatim from source), followed by an English
translation/paraphrase, followed by a comparison against the actual implementing code.

---

## 0. The `app_logik` self-description object (verbatim source)

Location: `index.html:6320-6336`. This is a single JS object of German-language strings,
apparently built to be forwarded to an LLM coach so it always describes scores the same way.
Key fields (verbatim):

- `UEBERSICHT`: "Alle Scores gehen von 0-100 (Ausnahme: Essens-Score 1-5). Es gibt EINEN Gesamtscore (atlas_tagesscore) und sieben Teilscores, die in ihn einfliessen. Der Trainings-Score ist einer dieser Teilscores und wird separat als Ring auf der Trainingsseite gezeigt."
- `atlas_tagesscore`: weights (Schlaf 20%, Ernährung 18%, Recovery 16%, Basics 16%, Training 14%, Supplements 8%, Peptide/Medikamente 8%), inactive subscores excluded from the weighted average rather than counted as 0, plus a stimulant malus of up to -12, future days = 0.
- `teilscore_schlaf`, `teilscore_ernaehrung`, `teilscore_training`, `teilscore_recovery`, `teilscore_basics`, `teilscore_supplements`, `teilscore_peptide_meds`: per-subscore descriptions (quoted in full in their respective sections below).
- `pace_of_aging`, `essens_score_1_5`, `cardio_und_zone2`, `tagesform_kurve`, `mikronaehrstoffe`, `score_arten`: auxiliary descriptions (quoted in their sections below).

Overall finding: most sub-descriptions match the code closely and precisely (the author clearly wrote this description directly from the formulas). Two clear exceptions were found — the **Training score's weighting and its rest-day/untracked-day handling** (Section 2) and the **Recovery score's hydration input** (Section 7) — documented below with exact line references.

---

## 1. Overall Daily Score — `atlas_tagesscore`

**What is tracked:** Nothing new — this is a weighted aggregate of the seven subscores below (sleep, nutrition, training, recovery, basics, supplements, peptides/meds).

**app_logik quote** (`index.html:6322`):
> "Gewichteter Mittelwert der aktiven Teilscores. GEWICHTE: Schlaf 20%, Ernaehrung 18%, Recovery 16%, Basics 16%, Training 14%, Supplements 8%, Peptide/Medikamente 8%. Ein Teilscore zaehlt nur, wenn an dem Tag Daten dazu existieren (sonst wird er aus der Gewichtung herausgerechnet, nicht als 0 gewertet). ZUSAETZLICH: direkter Malus fuer Stimulanzien (Alkohol/Nikotin) bis maximal -12 Punkte. Zukunftstage = 0."

(Translation: weighted mean of active subscores, weights as listed; a subscore only counts if the day has data for it — otherwise it's excluded from the weighting, not scored as 0; a direct stimulant malus of up to -12 applies; future days score 0.)

**Actual code** (`index.html:1893-1919`):
```js
const WEIGHTS={sleep:.20,nut:.18,rec:.16,huberman:.16,train:.14,supp:.08,meds:.08};
function dayActive(d){const dd=day(d);return{
  sleep:dd.sleep.hours>0,nut:dd.meals.length>0,train:trainActive(d),
  rec:!!(dd.recovery.hrv||dd.recovery.doms||dd.recovery.stress||dd.recovery.hydration||(dd.whoop&&dd.whoop.recoveryScore!=null)),
  huberman:(Object.keys(dd.protocol||{}).some(k=>dd.protocol[k])||cardioWeekAt(d)>0),
  supp:(S.supplements||[]).length>0,
  meds:hasHealthData()};}
function dayScore(d){
  if((d||curDate)>todayStr())return 0;
  const s=subScores(d),a=dayActive(d);let tot=0,wsum=0;
  for(const k in WEIGHTS){if(a[k]&&usageOn(k)){tot+=s[k]*WEIGHTS[k];wsum+=WEIGHTS[k];}}
  let score=wsum?tot/wsum:0;
  score-=Math.min(12,(s.pen||0)*0.4);
  return clamp(Math.round(score),0,100);
}
```
Stimulant penalty input (`stimPenalty`, `index.html:4069`): `Math.round(alcoholGrams*0.6 + nicotineMg*1.2 + (caffeineCups>4 ? (caffeineCups-4)*4 : 0))` — capped at 12 points off the final tagesscore, and also subtracted from the recovery subscore directly (Section 7).

**Match:** Exact. Weights, renormalization-when-inactive behavior, the -12 stimulant cap, and future-day=0 all match the code precisely.

**Source:** weights/aggregation `index.html:1893-1919`; `dayActive` (which subscore counts as "has data today") `index.html:1895-1900`; `usageOn` (user can disable non-locked categories in Settings) `index.html:1902-1911`; stimulant penalty `index.html:4069`.

---

## 2. Training Score — `trainings_score` / `trainScore`

**What is tracked:** Strength-training sets only (weight × reps, RIR/reps-in-reserve, per-exercise history) — day-based, no weekly rolling window in the real formula. Cardio is explicitly excluded.

**app_logik quote** (`index.html:6325`):
> "Gewicht 14%. TAGESBASIERT, nur Krafttraining. Zusammensetzung: 30% Progression (Top-Satz e1RM vs. letzte Session derselben Uebung: staerker = bis 100, gehalten = mittel, schwaecher = wenig; Volumenzuwachs gibt Bonus), 25% Intensitaet (Ø RIR ueber alle Arbeitssaetze; Optimum ca. 0,5-2,5 RIR = 85-100 Punkte, ab 2,5 RIR faellt der Wert um 22 Punkte je zusaetzlichem RIR bis minimal 40), 25% Volumen (Tagesvolumen in kg vs. deiner persoenlichen Baseline = Median der letzten 6 Trainingstage), 20% Arbeitssaetze vs. Ziel von 18 Saetzen pro Trainingstag. REST-DAY: zaehlt als 100 Punkte, aber nur 2 Rest-Tage pro Kalenderwoche sind frei - ab dem dritten gibt es Abzug. Ungetrackte Tage: 7-Tage-Mittel. CARDIO HAT KEINEN EINFLUSS auf diesen Score."

(Translation: weight 14%, day-based, strength only. Composition: 30% Progression, 25% Intensity/RIR, 25% Volume vs. personal baseline, 20% Working sets vs. target of 18/day. Rest days score 100 (2 free per calendar week, penalty from the 3rd), untracked days use a 7-day average. Cardio has no effect.)

**Actual code** (`index.html:1667-1677`, comment block at `1640-1643`):
```js
/* ===== TRAININGS-SCORE (tagesbasiert) =====
   Trainingstag: 30% Progression (...) · 25% Intensität (...)
   · 25% Volumen vs. persönliche Baseline · 20% Arbeitssätze vs. Ziel/Trainingstag.
   Rest-Day: 100 Punkte, 2 frei pro Kalenderwoche — ab dem 3. Rest-Tag Abzug. Untracked: 7-Tage-Mittel. */
const TRAIN_SETS_TARGET=18, REST_FREE=2;
function trainingDayScore(d){
  const dd=day(d);const exs=dd.training.filter(e=>e.sets.some(s=>num(s.r)>0));
  if(!exs.length)return null;
  let sets=0,vol=0;exs.forEach(e=>e.sets.forEach(s=>{if(num(s.r)>0&&!s.warm){sets++;vol+=num(s.w)*num(s.r);}}));
  let ps=0,pn=0;exs.forEach(e=>{const p=_exProgress(e,d||curDate);if(p!=null){ps+=p;pn++;}});
  const progScore=pn?clamp(Math.round(35+(ps/pn)*65),20,100):72;
  const rir=_dayAvgRir(dd),intScore=rir==null?80:_rirScore(rir);
  const vt=_volBaseline(d),volScore=vt?clamp(vol/vt,0,1)*100:100;
  const setScore=clamp(sets/TRAIN_SETS_TARGET,0,1)*100;
  return clamp(Math.round(progScore*0.40+intScore*0.25+volScore*0.20+setScore*0.15),0,100);
}
function trainScore(d){d=d||curDate;if(d>todayStr())return 0;const q=trainingDayScore(d);return q==null?0:q;}
function trainActive(d){return _workSets(day(d))>0&&(d||curDate)<=todayStr();}
```

**MISMATCH #1 — weighting.** The code (and even its own inline comment, which itself is stale) claims 30/25/25/20 for Progression/Intensity/Volume/Sets, but the actual computed line is:
```
progScore*0.40 + intScore*0.25 + volScore*0.20 + setScore*0.15
```
i.e. **40% Progression, 25% Intensity, 20% Volume, 15% Sets** — Progression is weighted 10 points higher than documented, and Volume/Sets are each 5 points lower. This is a genuine bug/drift between the code comment (and `app_logik`, which was clearly copied from that comment) and the shipped formula.

**MISMATCH #2 — rest days & untracked days.** There is **no code path** that scores a rest day as 100 or that substitutes a 7-day average for untracked days in the score that actually feeds `atlas_tagesscore` or the training-page ring. `trainingDayScore` returns `null` whenever there are no logged sets that day (rest day or otherwise), and `trainScore` turns that `null` into `0`. Meanwhile `trainActive(d)` (used to decide whether the "train" weight counts at all in `dayScore`) is `false` on any day with `_workSets==0`, which means: on rest days and untracked days the training subscore is **entirely excluded from the weighted average** (as if the user hadn't ever done training) — it is neither scored 100, nor averaged over 7 days, nor penalized after the "2 free rest days" rule. The only place the "2 free rest days / penalty from the 3rd" concept exists in code at all is a **display-only caption string** (`trainTodayCaption`, `index.html:1687-1694`) that never feeds back into any numeric score:
```js
function trainTodayCaption(){...
  if(dd.restDay&&_workSets(dd)===0){const idx=restIndexInWeek(k);
    return `... Rest-Day${idx>REST_FREE?` · #${idx} diese Woche → über die 2 freien, daher reduziert`:...}`;}
```
This caption merely *displays text* implying a reduction — it does not itself reduce any score. `REST_FREE` and `restIndexInWeek` are read nowhere else. **Conclusion: the rest-day-related behavior described in `app_logik` and in the code's own comment does not exist in the executed scoring path.**

**Internal inconsistency (bonus finding):** there are two different, disagreeing "Progression" formulas in the codebase:
- `_exProgress` (`index.html:1656-1665`) — continuous 0–1 score per exercise (top-set e1RM vs. last session, ±volume/RIR bonuses), averaged and mapped via `35 + avg*65`. **This is what actually feeds the real score.**
- `_progDayScore` (`index.html:1650`) — a *different*, discrete formula counting how many exercises improved/regressed (`62 + 40*prog/cmp - 30*reg/cmp`), used only to populate the "Progression" chip shown in the on-screen training caption (`trainTodayCaption`, `index.html:1691-1693`).

These two can and do disagree, so the number labeled "Progression" in the UI caption is not necessarily the number that was actually used in the score.

**Match (everything else):** `TRAIN_SETS_TARGET=18` sets/day ✓; RIR optimum curve `_rirScore` (`1648`: ≤2.5 RIR → 85–100 scaled, above 2.5 → −22 pts/RIR down to a floor of 40) ✓ matches "Optimum ca. 0,5-2,5 RIR = 85-100 Punkte, ab 2,5 RIR faellt der Wert um 22 Punkte..."; volume baseline = median of the last 6 training days (`_volBaseline`, `1649`) ✓; cardio has zero influence on this score (confirmed — `trainingDayScore` never reads `cardioMin`/`cardioSessions`) ✓.

**Source lines:** weights & core formula `index.html:1667-1677`; comment block (stale) `index.html:1640-1643`; RIR curve `index.html:1648`; volume baseline `index.html:1649`; progression (real) `index.html:1656-1665`; progression (display-only, disagreeing) `index.html:1650`; rest-day caption (cosmetic only) `index.html:1685-1694`; weekly set target (unrelated display metric, not used in daily score) `index.html:1636-1639`.

---

## 3. Nutrition Score — `nutritionScore` (feeds `teilscore_ernaehrung`)

**What is tracked:** Per-meal kcal/protein/carbs/fat (manual entry, photo/AI recognition, or Open Food Facts barcode/search), aggregated per day (`mealSum`).

**app_logik quote** (`index.html:6324`):
> "Gewicht 18%. Setzt sich zusammen aus 40% Kalorien-Treffgenauigkeit (Abweichung vom kcal-Ziel), 35% Makros (Protein zaehlt 1,4-fach gegenueber Carbs und Fett) und 25% Mikronaehrstoff-Abdeckung. Mikro-Abdeckung = Anteil der Naehrstoffe, die mindestens 90% der DRI erreichen ODER durch ein eingenommenes Supplement gedeckt sind. Aktiv, sobald mindestens eine Mahlzeit geloggt ist. Der Essens-Score 1-5 einzelner Lebensmittel fliesst NICHT direkt hier ein - er ist eine Qualitaetsbewertung fuer dich."

**Actual code** (`index.html:1886-1889`):
```js
function microScore(d){const mi=microIntake(d),cov=suppMicroCover(day(d));let hit=0,tot=0;
  MICROS.forEach(m=>{tot++;const a=num(mi[m.k]);if(a>=(m.dri||0)*0.9||cov.has(m.k))hit++;});
  return tot?Math.round(hit/tot*100):100;}
function nutritionScore(d){const ms=mealSum(d),g=goals();if(!ms.kcal)return 0;
  const adh=(a,t)=>t?clamp(100-Math.abs(a-t)/t*100,0,100):100;
  const kcalS=adh(ms.kcal,g.kcal),
        macroS=(adh(ms.p,g.protein)*1.4+adh(ms.c,g.carbs)+adh(ms.f,g.fat))/3.4,
        microS=microScore(d);
  return clamp(Math.round(kcalS*0.4+macroS*0.35+microS*0.25),0,100);}
```

**Match: exact.** 40/35/25 weighting ✓; protein weighted 1.4× within the macro sub-score (divisor 3.4 = 1.4+1+1) ✓; micro coverage = fraction of tracked nutrients at ≥90% DRI or covered by a logged supplement ✓; requires ≥1 logged meal (else returns 0) ✓; the 1-5 food-quality score (`foodScore`, Section 5) is confirmed **not** referenced anywhere in `nutritionScore`/`microScore` ✓.

**kcal/macro targets themselves** (`goals()`, `index.html:1000-1024`) — not described in `app_logik` at all, but a real hardcoded formula chain worth documenting:
- BMR: Katch-McArdle (`370 + 21.6 × lean mass`) if body fat % is known (4–50% range), else Mifflin-St-Jeor (`10w + 6.25h - 5a + (5 male / -161 female)`). `index.html:991`.
- Activity factor: 30% manual profile setting + 70% "tracked activity" derived from WHOOP weekly average day-strain (or logged cardio+training minutes as fallback), blended `_bmrCalc()*blendF`. `index.html:977-987, 1004-1006`.
- TDEE: WHOOP `kcalBurn` weekly average is used directly if higher than BMR; otherwise BMR×blend factor; then adaptively corrected by a 21-day linear regression of body-weight trend vs. average logged intake (`adaptiveTDEE`, `index.html:993-997, 1012-1013`), phased in via a confidence score, then smoothed day-to-day with a 25%/day EWMA (`_smoothTDEE`, `index.html:998-999`) to avoid jumps.
- Goal kcal delta: `GOAL_PCT` table (`index.html:988`) — aggressive cut −20%, cut −15%, lean cut −10%, recomp/maintain 0%, lean bulk +10%, bulk +15%.
- Protein target: `2.3 g/kg` if cutting (goalPct<0), else `2.0 g/kg`. Fat target: `0.9 g/kg`. Carbs: remainder of kcal budget. Water target: `38 ml/kg + 0.55 ml per active kcal burned`. `index.html:1019-1022`.

**Source:** `nutritionScore`/`microScore` `index.html:1886-1889`; `goals()`/TDEE chain `index.html:968-1024`; `mealSum` `index.html:1025`.

---

## 4. Micronutrients — DRI/Optimum tracking, 14-day averages

**What is tracked:** 34 micronutrients (`MICROS` array), each with a daily requirement (`dri`), an "optimal" target (`opt`), unit, an importance weight 1–5, a physiological role description, a suggested supplement + dose, linked blood markers, and linked methylation SNPs that increase need.

**app_logik quote** (`index.html:6334`):
> "Je Naehrstoff werden Zufuhr, 14-Tage-Schnitt, DRI (Minimum) und Optimum verglichen. Unter 60% der DRI gilt als Luecke. Ein Supplement kann eine Luecke decken. Methylierungs-SNPs (z.B. MTHFR, COMT, VDR) erhoehen den Bedarf einzelner Naehrstoffe."

**Actual code — three different thresholds are used in different places, which `app_logik` does not distinguish:**

1. **Nutrition subscore's "coverage" metric** (Section 3) uses **≥90% of DRI** (or supplement coverage) to count as "hit" — `index.html:1886`.
2. **Coach-reasoning / "gap" flags** shown to the user (`recoReasoning`, `index.html:6373`; `openAllMicros`, `index.html:1874-1880`) use **<60% of DRI** as the "gap" cutoff — this is what `app_logik`'s "Unter 60% der DRI gilt als Luecke" actually refers to.
3. **Coach-snapshot export's per-nutrient `status` field** (sent to the AI backend, `index.html:6261`) uses yet another scheme: `status = heute>=opt ? 'optimal' : heute>=dri ? 'ausreichend' : heute>0 ? 'zu niedrig' : 'nicht getrackt'` — i.e. exactly ≥100% of DRI counts as "ausreichend" (sufficient), not 90% or 60%.

None of these are wrong individually, but `app_logik`'s single blanket "under 60% = gap" line conflates three genuinely different thresholds used for three different purposes (score computation vs. coaching flags vs. raw data export). Worth being precise about which one is meant when asked "what counts as a nutrient gap."

**14-day average** (`dietAvg`, `index.html:1311`):
```js
function dietAvg(k){let sum=0,n=0;const now=dayDate(curDate);
  for(let i=0;i<14;i++){const d=new Date(now);d.setDate(now.getDate()-i);const ds=todayStr(d),dd=S.days[ds];
    if(dd&&dd.meals&&dd.meals.length){sum+=num(microIntake(ds)[k]);n++}}
  return n?{avg:sum/n,days:n}:null}
```
Simple mean over the last 14 calendar days, but **only over days that have at least one logged meal** (`n` = count of days with meals, not 14) — so it's an average over tracked days, not a true daily average including untracked zero-days.

**Supplement priority score** (`nutrientBenefit`, `index.html:1313-1321`) — used to rank/suggest supplements, not part of any 0-100 score: `score = importance×6`, `+round(dietGapPct×45)` if the 14-day diet average is more than 10% below DRI, `+42` flat if a linked blood marker is flagged low/high, `+boost` (15 for heterozygous, 32 for homozygous linked SNP) from methylation status. Clamped 0-100.

**Methylation SNP table** (`METHYL`, `index.html:1195-1203`): 7 SNPs tracked (MTHFR C677T, MTHFR A1298C, MTRR, COMT, VDR, CBS, MAO-A), each linked to specific micronutrients/supplements it increases the need for (used both in `nutrientBenefit` and in individual supplement match-scores, Section 9).

**Match:** DRI/Optimum/14-day-average concept ✓ matches. The "60%" threshold ✓ matches for the coaching-flag path specifically, but is not the threshold actually used inside the nutrition score itself (90%) — see caveat above. Methylation SNP linkage ✓ matches.

**Source:** `MICROS` reference table `index.html:1027-1062`; `microIntake`/`dietAvg` `index.html:1310-1311`; `nutrientBenefit` `index.html:1313-1321`; `METHYL` table `index.html:1195-1203`; gap-flag UI `index.html:1874-1880, 6373`; export status field `index.html:6258-6262`; OpenFoodFacts micronutrient field mapping (`OFF_MICRO`, converts g→mg/mcg from barcode data) `index.html:3673-3682`.

---

## 5. Food Quality Score 1-5 (`essens_score_1_5`) + NOVA

**What is tracked:** Every logged meal/food gets a 1-5 "how good is this food" score, independent of the nutrition score. Determined either by a rule-based lookup on the food name, by objective scanned/photographed data (NOVA processing level + nutrient facts + ingredient list), or by macro composition as a fallback.

**app_logik quote** (`index.html:6331`):
> "Qualitaetsbewertung EINZELNER Lebensmittel, 1 = schlecht bis 5 = optimal. Basis nach Lebensmittelgruppe: fetter Fisch, Gemuese, Beeren, Granatapfel, Eier = 5; unverarbeitetes Fleisch, ganze Fruechte, Nuesse, gute Fette, Huelsenfruechte, Milchprodukte, Vollkorn = 4; raffinierte Kohlenhydrate = 3; verarbeitetes Fleisch und Samenoele = 2; Zuckriges, Frittiertes, gehaertete Fette = 1. Gescannte oder fotografierte Produkte werden OBJEKTIV bewertet: Verarbeitungsgrad NOVA (1=5 Punkte bis 4=2 Punkte) plus Zutatenliste; der Name kann dann nur noch abwerten, nie aufwerten. MODIFIKATOREN: Alkohol -2; Gluten/Gliadin -2 (...); Suessstoffe, Emulgatoren, Zusatzstoffe, Aromen je -1; Phytinsaeure und Lektine -1 (...); Oxalate -1; fermentierte Lebensmittel (...) +2; Innereien, Weidefleisch, Knochenbruehe +1. Fertig-/Convenience-Produkte ohne Scan werden auf maximal 3 gedeckelt. Zusaetzlich wirkt die gewaehlte Ernaehrungsphilosophie (z.B. Low-Carb, Carnivore) mit +/-1 bis 2 auf passende Kategorien."

**Actual code — this matches the description almost exactly**, verified against:
- Base scores by food category, `FOOD_RULES` (`index.html:3415-3434`): fish/pomegranate/berries/vegetables/eggs = 5; unprocessed meat/fruit/nuts/good fats/legumes/dairy/whole grain = 4; refined carbs = 3; processed meat/seed oils = 2; sugary/fried/hydrogenated-fat = 1. **Exact match.**
- NOVA scoring for scanned items, `scanScore` (`index.html:3460`): `[null,5,4,3,2][nova]` i.e. NOVA 1→5, 2→4, 3→3, 4→2, **exact match**, plus small ±0.5–1.5 adjustments from sugar/saturated-fat/salt/fiber/protein per-100g values.
- Modifiers, `FOOD_MODS` (`index.html:3445-3456`): alcohol −2, gluten/gliadin −2 (sourdough exempted via separate regex logic in `ING_RULES`), sweeteners −1, emulsifiers/additives −1, phytic acid/lectins −1, oxalates −1, fermented foods +2, organ meat/grass-fed/wild +1, bone broth/collagen +1. **Exact match** to the modifier list and values in `app_logik`.
- Ready-meal cap: `READYMEAL_RE` match caps score at 3 if unscanned (`index.html:3541`). **Exact match.**
- Diet philosophy adjustment, `_philAdjust` (`index.html:3436-3443`): carnivore/low-carb/vegetarian/unprocessed each shift relevant categories by ±1–2. **Exact match.**
- "Name can only downgrade, never upgrade, once objective scan data exists": confirmed at `index.html:3521` (`if(m&&m.n100&&rule&&rule.s<=2&&rule.s<base){base=rule.s;...}` — only applies if the name-based score is *lower* than the base).

**Confirmed NOT feeding into any 0-100 score** (per Section 3) — `foodScore` is called only for display (`scoreBadge`, `openFoodScore`) and in the coach snapshot export, never in `nutritionScore`/`dayScore`.

**Source:** `scanScore` (NOVA) `index.html:3460`; `macroScore` (macro-based fallback) `index.html:3461-3471`; `ingredientAnalysis` (ingredient-text rule engine, `ING_RULES`) `index.html:3475-3505`; `foodScore` (main dispatcher) `index.html:3506-3547`; category base scores `FOOD_RULES` `index.html:3415-3434`; modifiers `FOOD_MODS` `index.html:3445-3456`; philosophy adjust `index.html:3436-3443`; processed/ready-meal regexes `index.html:3458-3459`; study citations shown to user `FOOD_CITES` `index.html:3404-3414`.

---

## 6. Sleep Score (feeds `teilscore_schlaf`)

**What is tracked:** Sleep duration (hours), optional subjective sleep quality (1-10 scale).

**app_logik quote** (`index.html:6323`):
> "Gewicht 20%. Dauer ist fuehrend: 8 h = 100 Punkte, je Stunde Abweichung nach oben oder unten -14. Ist zusaetzlich eine Schlafqualitaet erfasst, wird gemischt (60% Dauer + Qualitaet x8). Aktiv, sobald Schlafstunden eingetragen sind."

**Actual code** (`index.html:1613-1616`):
```js
const sh=dd.sleep.hours,sq=dd.sleep.quality;
let sleep=sh?clamp(100-Math.abs(8-sh)*14,0,100):0;
if(sq)sleep=Math.round(sleep*0.6+sq*8);
sleep=clamp(sleep,0,100);
```
**Match: exact.** 8h optimum, −14 pts/hour deviation either direction, quality blend = 60% duration-score + quality×8 (quality is on a 0-10 scale, so max contribution 80, roughly matching a 0-100 scale when combined with the 60% duration term) — matches precisely. Active only once sleep hours are logged (`dayActive.sleep = dd.sleep.hours>0`, `index.html:1896`) ✓.

Note: a related but separate concept — **sleep need** (how many hours you *should* sleep, not a score) — is computed by a different, more elaborate model (`sleepNeedCalc`, `index.html:2593-2608`): age/sex/weight/height baseline (7.6-9.2h) + additions for recent training strain (WHOOP day-strain or logged working sets), for low recovery/elevated resting heart rate, and for accumulated 7-day "sleep debt," clamped to 6-10h. This is not mentioned in `app_logik` at all (it's a separate recommendation feature, not part of the score), and is documented here since it's a substantial, non-trivial algorithm.

**Source:** sleep score `index.html:1612-1616`; sleep need algorithm `index.html:2582-2608`; sleep baseline table `index.html:2588-2592`.

---

## 7. Recovery Score (feeds `teilscore_recovery`)

**What is tracked:** Manual HRV/DOMS(muscle soreness)/Stress/Hydration entries (each on a 0-10 scale), OR WHOOP's own `recoveryScore` (0-100) when synced (which also auto-populates the manual HRV field as `recoveryScore/10`, `index.html:6613`).

**app_logik quote** (`index.html:6326`):
> "Gewicht 16%. Aus HRV, Muskelkater (DOMS), Stress und Hydration bzw. dem WHOOP-Recovery-Wert. Stimulanzien ausser moderatem Koffein senken diesen Score."

(Translation: from HRV, DOMS, Stress and Hydration, or the WHOOP recovery value; stimulants other than moderate caffeine lower this score.)

**Actual code** (`index.html:1621-1626`):
```js
const pen=stimPenalty(d);
const r=dd.recovery;
let rec=(r.hrv||r.doms||r.stress||r.hydration)?
  clamp(Math.round((num(r.hrv)*4)+((10-num(r.doms))*3)+((10-num(r.stress))*3)),0,100):0;
if(dd.whoop&&dd.whoop.recoveryScore!=null)rec=dd.whoop.recoveryScore;
rec=clamp(rec-pen,0,100);
```

**MISMATCH:** `app_logik` claims the recovery score is computed "from HRV, DOMS, Stress **and Hydration**." The actual arithmetic formula is `hrv×4 + (10−doms)×3 + (10−stress)×3` (max 40+30+30=100) — **hydration's numeric value is never added into the formula.** `r.hydration` is only referenced as one of four OR-conditions that decide *whether* to compute a non-zero score at all (i.e., logging only a hydration value with no HRV/DOMS/stress would make the condition true but the formula would still evaluate to `0×4 + 10×3 + 10×3 = 60` regardless of the actual hydration number, since `num(r.hrv)` would be 0/NaN→0). Hydration is tracked and displayed as its own trend metric (`index.html:6004`) but does not mathematically influence the recovery subscore.

**Match (rest):** WHOOP `recoveryScore` overrides the manual formula entirely when present ✓; stimulant penalty (`stimPenalty`, `index.html:4069`, same function used for the tagesscore-level malus) is subtracted from recovery too ✓ — moderate caffeine (≤4 cups) contributes 0 penalty, only the portion above 4 cups counts (`(caf>4?(caf-4)*4:0)`), consistent with "ausser moderatem Koffein."

**Source:** `index.html:1621-1626` (formula); `stimPenalty` `index.html:4069`; `stimAlcoholG`/`stimNicMg` (grams/mg conversion from drinks/vapes/snus/cigarettes) `index.html:4056-4064`.

---

## 8. Basics / Lifestyle Score — `hubermanScore` (feeds `teilscore_basics`, shown in-app as "Basic Score")

**What is tracked:** A checklist of 16 evidence-tagged daily habits (sleep timing, morning light, caffeine timing, sunset light exposure, screens-before-bed, cool room, darkness, sleep mask, no late food, breathwork, sauna/heat, cold exposure, hydration+electrolytes, L-theanine, NSDR/yoga nidra) plus user-defined custom "basics" plus weekly Zone-2 cardio minutes.

**app_logik quote** (`index.html:6327`):
> "Gewicht 16% (in der App 'Basic Score'). Gewichtete Erfuellung der abgehakten Grundlagen. EINZELGEWICHTE: Schlafrhythmus 10, Morgenlicht 9, Zone-2-Cardio der Woche 9, kein Bildschirm im Bett 6, kuehler Raum 6, Dunkelheit 6, Hitze/Sauna 6, kein spaetes Essen 5, Koffein-Timing 5, Hydration 5, Atemuebung 5, NSDR 5, Sonnenuntergangslicht 4, Kaelte 4, Schlafmaske 3, L-Theanin 3. Eigene Basics zaehlen mit Level x2. Der Cardio-Anteil ist anteilig erfuellt: Wochenminuten geteilt durch Ziel 175 min."

**Actual code** (`index.html:4151-4162`):
```js
const HP_WEIGHTS={sleepreg:10,light:9,nobed:6,cool:6,dark:6,heat:6,nofood:5,caffeine:5,hydrate:5,breath:5,nsdr:5,sunset:4,cold:4,mask:3,theanine:3};
const HP_CARDIO_W=9, HP_CARDIO_TARGET=175;
function hubermanScore(d){
  const dd=day(d),prot=dd.protocol||{};let num_=0,den=0;
  for(const k in HP_WEIGHTS){den+=HP_WEIGHTS[k];if(prot[k])num_+=HP_WEIGHTS[k];}
  (S.customBasics||[]).forEach(c=>{const cw=(c.level||3)*2;den+=cw;if(prot['cb_'+c.id])num_+=cw;});
  den+=HP_CARDIO_W;num_+=HP_CARDIO_W*clamp(cardioWeekAt(d)/HP_CARDIO_TARGET,0,1);
  return den?Math.round(num_/den*100):0;
}
```
**Match: exact**, including every individual weight (10/9/9/6/6/6/6/5/5/5/5/5/4/4/3/3), the "custom basics count at level×2" rule, and the cardio share = weekly minutes / 175 target.

**Source:** habit list + evidence tags `HP_ITEMS`, `index.html:4129-4147`; weights `index.html:4151`; score formula `index.html:4156-4162`; weekly cardio minutes accumulator `cardioWeekAt`, `index.html:4148`.

---

## 9. Supplements Score — `suppNeedScore` (feeds `teilscore_supplements`)

**What is tracked:** The user's active supplement stack (name, dose, timing), each matched (if recognized) against a knowledge base of ~50 supplements (`SUPP_KB`) with a personalized 1-5 "match score."

**app_logik quote** (`index.html:6328`):
> "Gewicht 8%. Nicht 'wie viele genommen', sondern BEDARFSGERECHT: jedes Supplement wird mit seinem Match-Score 1-5 gewichtet (wie gut es zu deinen Blutwerten, Mikroluecken und Zielen passt). Score = Summe der Gewichte der eingenommenen Supplements geteilt durch die Summe aller Gewichte."

**Actual code** (`index.html:1891`, match-score in `index.html:5088-5094`):
```js
function suppScore(it){
  let s=it.base||2,reasons=[];
  if(it.rule){const o=it.rule(c);s+=o.a;reasons=o.r;}
  return {score:clamp(Math.round(s),1,5),reasons};
}
function suppNeedScore(d){const dd=day(d);let wsum=0,got=0;
  (S.supplements||[]).forEach(x=>{const kb=x._kb&&SUPP_MAP[x._kb];let w=3;
    if(kb){const sc=suppScore(kb);if(sc)w=sc.score;}else if(x.imp)w=num(x.imp);
    w=clamp(w||3,1,5);wsum+=w;if(dd.supp&&dd.supp[x.id])got+=w;});
  return wsum?Math.round(got/wsum*100):0;}
```
Each `SUPP_KB` entry has a `base` (1-5) plus a `rule(context)` function that adds/subtracts points based on: flagged blood markers (`bloodStat`, via `BLOODREF`), presence of relevant methylation SNP variants (`methVar`), the user's stated goal (bulk/cut/recomp/etc.), sex, and age — e.g. Vitamin D3+K2: `base:4`, `+1` if blood Vitamin D is low, `+1` if diet is >15% below DRI, `+1` if a VDR variant is present (`index.html:4959-4960`).

**Match: exact.** Weighted-adherence formula, and the "match to blood values / nutrient gaps / goals" description both match the code's rule-based system precisely. Unrecognized custom supplements fall back to weight 3 (or the user-set `imp` importance field) rather than being excluded.

**Source:** `suppNeedScore`/`suppScore` `index.html:1891, 5088-5094`; supplement knowledge base with per-item rules `SUPP_KB` `index.html:4958-5060+` (partial read; ~50 entries covering basics, methylation, sleep/stress, cognition, sex-specific, longevity categories); personalized dosing table `SUPP_DOSE` `index.html:5097-5111`; supplement-compound elemental/bioavailability conversion table (e.g. magnesium oxide 60.3% elemental/15% bioavailable vs. glycinate 14.1%/100%) `SUPP_COMPOUNDS` `index.html:1069-1091`.

---

## 10. Peptides / Medications / Health Score — `coachScore` + `healthScore` (feeds `teilscore_peptide_meds`, shown in-app as "Gesundheit")

**What is tracked:** Peptide and medication logs (taken/not taken vs. prescribed frequency), plus manual blood-pressure readings.

**app_logik quote** (`index.html:6329`):
> "Gewicht 8% (in der App 'Gesundheit'). Mittelwert aus Medikamenten-/Peptid-Adhaerenz (genommen vs. laut Frequenz faellig; seltene Mittel werden nur positiv gewertet, nie bestraft) und Blutdruck-Optimalitaet, falls Blutdruck erfasst ist."

**Actual code:**
```js
// index.html:1603-1609 — adherence
function coachScore(d){d=d||curDate;const dd=day(d);let got=0,tot=0;
  [["peptides","pep"],["meds","med"]].forEach(([arr,key])=>{(S[arr]||[]).forEach(x=>{
    const cnt=Math.max(0,Math.floor(num(dd[key]&&dd[key][x.id])||0)),tpd=timesPerDay(x.freq);
    if(tpd>0){tot+=tpd;got+=Math.min(cnt,tpd);}       // daily-frequency items always count
    else if(cnt>0){tot+=cnt;got+=cnt;}                // rare/as-needed: only counted if taken, never penalized
  });});
  return tot?Math.round(got/tot*100):null;}

// index.html:5455-5463 — blood pressure optimality
function optimalBP(){ /* age/sex/BMI-adjusted target, sys 108-128, dia 68-84 */ }
function _bpOne(v,ideal){const dv=v-ideal;if(dv>=-6&&dv<=6)return 100;if(dv>6)return clamp(100-(dv-6)*3,0,100);return clamp(100-(-dv-6)*3.5,0,100);}
function bpScoreVal(d){ /* min(sys-score, dia-score) vs. personalized optimum */ }
function healthScore(d){const meds=coachScore(d),bp=bpScoreVal(d),parts=[];
  if(meds!=null)parts.push(meds);if(bp!=null)parts.push(bp);
  return parts.length?Math.round(parts.reduce((a,b)=>a+b,0)/parts.length):0;}
```
**Match: exact.** Daily-frequency items count fully (taken vs. due); rare/as-needed items only add to the numerator+denominator when actually taken (never penalized for not being taken) — matches "seltene Mittel werden nur positiv gewertet, nie bestraft" precisely. Final score is a simple average of whichever of {medication adherence, BP optimality} exist that day.

**BP optimum formula** (not described in `app_logik`, worth noting): personalized target BP (`optimalBP`, `index.html:5455-5458`) is `sys = 112 + 0.22×max(0,age-30) + 3(if male) + clamp((BMI-22)×0.7, -4, 10)`, clamped to 108-128; `dia` analogous with different constants, clamped 68-84. A ±6 mmHg tolerance band scores 100; outside that, penalty accelerates faster below the range (×3.5/mmHg) than above it (×3/mmHg).

**Source:** `coachScore` `index.html:1603-1609`; `optimalBP`/`_bpOne`/`bpScoreVal` `index.html:5455-5461`; `healthScore` `index.html:5463`; `hasHealthData` `index.html:5464`.

---

## 11. Pace of Aging & Bio-Age (not a `teilscore`, shown as a separate feature)

**What is tracked:** Aggregated across 5 metrics with hardcoded reference ranges: sleep consistency (WHOOP `sleepCons`, 40-95%), sleep duration (optimum 8h ±2.5h tolerance), resting heart rate (WHOOP `rhr`, 45-72bpm, lower=better), weekly Zone 1-3 cardio minutes (30-200 min/week), weekly strength-training minutes (derived as `sets×3.5min`, 20-120 min/week). A placeholder table (`AGE_PENDING`) lists Zone 4-5 minutes, steps, VO2max, and lean body mass as "coming soon" (pending Apple Health integration).

**app_logik quote** (`index.html:6330`):
> "Alterungstempo als Faktor um 1.0 (unter 1 = langsamer als normal). Vergleicht die Einflussfaktoren der letzten 30 Tage mit dem 180-Tage-Schnitt; Alkohol wirkt zusaetzlich verstaerkend. Getrennt davon gibt es ein Bio-Alter."

**Actual code** (`index.html:2483-2574`):
- Per-metric "years gained/lost" (`_metricScore`/`_agingContribs`, `index.html:2483-2498`): each metric is normalized 0-1 against its `lo`/`hi` (or `opt`±`tol`) range, then converted to a ± year contribution scaled by a per-metric weight `w` (max 0.7-1.6 years each): `years = (0.5 - normalized)*2*w`.
- **Bio-age** (`bioAge`, `index.html:2561-2565`) = chronological age (from birthday, month-precision) + sum of year-contributions computed over a **180-day** window.
- **Pace of aging** (`paceOfAging`, `index.html:2567-2573`):
```js
function paceOfAging(){
  const base=agingContribs(180), recent=agingContribs(30);
  const recAdj=recent.delta + alcoholRate(30)*0.15;
  const pace=clamp(Math.round((1+(recAdj-base.delta)*0.09)*100)/100,0.7,1.3);
  const score=clamp(Math.round(62-base.delta*7),0,100);
  return {score,pace};
}
```
**Match: confirmed.** 30-day recent window compared to a 180-day baseline window ✓; alcohol (`alcoholRate`, standard-drinks/week average) additionally inflates the "recent" aging delta by ×0.15 before comparison, i.e. makes pace look worse ✓ ("Alkohol wirkt zusaetzlich verstaerkend"); pace clamped 0.7-1.3× ✓; bio-age is a separate, additively-computed number ✓.

**Note (unreferenced by app_logik):** the metric weights, ranges, and the `0.09` pace-sensitivity constant and `62 - delta×7` score formula have no visible derivation/citation in the code or comments — these look like reasonable-but-arbitrary tuning constants rather than values sourced from a specific study, unlike the food-score modifiers (Section 5) which do carry citations (`FOOD_CITES`).

**Source:** metric reference table `AGE_META` `index.html:2464-2470`; pending-metrics placeholder `AGE_PENDING` `index.html:2472-2477`; contribution math `index.html:2483-2498`; bio-age `index.html:2561-2565`; pace of aging `index.html:2567-2573`.

---

## 12. Tagesform-Kurve / Energy Curve (informational, not a score)

**What is tracked:** Not user-input — a derived hour-by-hour "energy/focus" curve for the current day, used to suggest a deep-work window, a gym window, and a "peak hour."

**app_logik quote** (`index.html:6333`):
> "Zwei-Prozess-Modell aus Aufwachzeit, Recovery, Schlafqualitaet und Schlafrhythmus: Cortisol-Anstieg am Morgen, Schlaftraegheit direkt nach dem Aufwachen, steigender Adenosindruck ueber den Tag, Mittagstief, Kerntemperatur-Peak am spaeten Nachmittag (bestes Gym-Fenster) und Melatonin-Abfall am Abend. Daraus werden Fokus-Arbeitsfenster, Gym-Fenster und Peak-Stunde abgeleitet."

**Actual code** (`energyCurve`, `index.html:1971-2003`; `performanceZones`, `index.html:2005-2028`): a Borbély two-process circadian model. Per-hour value = `base + cortisol-awakening-bump(Gaussian around wake+2.5h) + afternoon-core-temp-peak(Gaussian around 16:30) − post-lunch-dip(Gaussian around 14:30, scaled by nutrition quality) − sleep-inertia(first ~1.5h after waking, worse with sleep debt) + homeostatic-pressure-decay(linear, −1.4/h) + melatonin-decline(linear after an onset time that shifts w/ sleep-rhythm-consistency) + nutrition-adequacy-and-fueling-today terms`. `base` itself is modulated by recovery score, WHOOP sleep-performance, and 14-day nutrition adequacy/quality (`nutritionEnergy`, `index.html:1951-1965`). Deliberately excludes caffeine (commented: "Koffein bewusst NICHT").

**Match: exact** conceptually — every named physiological driver in the `app_logik` quote (cortisol, sleep inertia, adenosine/homeostatic pressure, midday dip, core-temperature peak/best gym window, melatonin decline) is present in the code with an explicit formula term.

**Source:** `energyCurve` `index.html:1971-2003`; `performanceZones` (derives work/gym/peak windows from the curve) `index.html:2005-2028`; `nutritionEnergy` (chronic 14-day intake adequacy+quality feeding the curve's baseline) `index.html:1951-1965`; `sleepRhythm` (14-day WHOOP sleep-consistency average, feeds melatonin-onset timing) `index.html:1967`.

---

## 13. Journal / Mental & Social Habits (tracked, but NOT scored)

**What is tracked:** Free-text daily journal entry, a stress rating, up to 3 "wins" per day (general/mental-challenge/social), and a gratitude list (3 items/day).

**app_logik quote:** Not mentioned anywhere in `app_logik` — no `teilscore` or field references journal/wins/gratitude at all.

**Actual code:** confirmed these values (`journalStress`, `winsCount`, `mentalWin`, `socialWin`, `gratCount`, `index.html:5764-5771`) are **never referenced in `dayScore`, `subScores`, or any WEIGHTS table** — they are used exclusively in `journalMankos` (`index.html:6399-6407`) to generate qualitative coaching text (e.g. "lots of stress in the journal lately," "few daily wins lately") shown in the coach chat, and are included raw in the `coachSnapshot` export. This is a fully tracked category with zero effect on any numeric score — worth being explicit about, since a user might reasonably assume journaling affects their `atlas_tagesscore` the way every other tracked category does.

**Source:** `index.html:5764-5771` (accessors); `index.html:6399-6407` (`journalMankos`, coaching-text use only); `index.html:6253` (raw export field).

---

## 14. Reference Tables Reused Across Scores

- **`MICROS`** — 34-nutrient DRI/Optimum/importance/role/supplement/dose/blood-marker/methylation-SNP table. `index.html:1027-1062`.
- **`BLOODREF`** — ~55 blood markers with reference ranges (`lo`/`hi`), category, description, and "why it matters" bullet points; `SEX_F` overrides female-specific ranges for 12 of them; `refRange()` additionally age-adjusts eGFR, IGF-1, DHEA-S (men), and testosterone (men) upward/downward by age bracket. `index.html:1105-1191`.
- **`METHYL`** — 7 methylation SNPs (MTHFR C677T/A1298C, MTRR, COMT, VDR, CBS, MAO-A) each linked to the nutrients/supplements they raise demand for. `index.html:1195-1203`.
- **`SUPP_COMPOUNDS`** — elemental-content and bioavailability factors for common supplement salts (e.g. magnesium oxide vs. glycinate vs. threonate), used to normalize label doses to elemental amounts. `index.html:1069-1091`.
- **`HP_ITEMS`/`HP_WEIGHTS`** — the 16-item lifestyle-basics checklist with evidence-strength tags (`stark`/`solide`/`moderat`/`schwach`) and their score weights. `index.html:4129-4151`.
- **`GOAL_PCT`** — kcal-target percentage offsets per training goal (aggressive cut −20% … bulk +15%). `index.html:988`.
- **`FOOD_RULES`/`FOOD_MODS`/`FOOD_CITES`** — food-name category base-scores, additive modifiers, and their cited sources (WHO processed-meat classification, Harvard trans-fat page, an ultra-processed-food umbrella review, etc.). `index.html:3404-3459`.
- **`SUPP_KB`/`SUPP_DOSE`** — ~50-item supplement knowledge base with per-supplement base score, personalization rule, and dosing formula. `index.html:4958-5111`.
- **`AGE_META`/`AGE_PENDING`** — bio-age/pace-of-aging metric reference ranges and weights. `index.html:2464-2477`.

---

## Summary of Flagged Inconsistencies (for quick reference)

1. **Training score weighting is wrong in both the code comment and `app_logik`.** Documented/commented as 30% Progression / 25% Intensity / 25% Volume / 20% Sets; actual code computes 40/25/20/15. `index.html:1640-1643` (comment) vs. `1674` (real formula).
2. **Training score's rest-day (100 pts) and untracked-day (7-day average) handling described in both the code comment and `app_logik` does not exist in the live scoring path.** Rest/untracked days simply drop the "train" weight from the `atlas_tagesscore` average entirely (via `trainActive`); the "2 free rest days" concept exists only as unused display text (`index.html:1687-1694`), never as an actual score adjustment.
3. **Recovery score's hydration input is described but not implemented.** `app_logik` states recovery is computed from HRV/DOMS/Stress/Hydration; the formula (`index.html:1624`) mathematically only uses HRV/DOMS/Stress — hydration is merely one of four triggers deciding whether to compute a score at all.
4. **Two disagreeing "Progression" formulas for training** — `_exProgress` (real, feeds the score) vs. `_progDayScore` (used only for the on-screen caption chip) can show different numbers for what's labeled the same thing. `index.html:1656-1665` vs. `1650`.
5. **Three different "micronutrient gap" thresholds coexist** (90% DRI for the nutrition subscore, 60% DRI for coaching-flag text, 100% DRI/Optimum for the raw data export's `status` field) while `app_logik` states a single 60% rule — accurate only for the coaching-flag path.
6. **Several numeric constants have no visible rationale/citation in code or comments**, making them reasonable candidates for future evidence-based revision: the Pace-of-Aging sensitivity constant `0.09` and score formula `62 - delta×7` (`index.html:2571-2572`); the AGE_META per-metric year-weights (0.7-1.6) and ranges (`index.html:2464-2470`); the BP-optimum formula's BMI/age coefficients (`index.html:5456-5457`); the RIR-score penalty curve's exact −22 pts/RIR slope and 40-point floor (`index.html:1648`); the stimulant-penalty coefficients `alcohol×0.6 + nicotine×1.2 + (caffeine-4)×4` (`index.html:4069`). None of these are necessarily wrong, but none carry a study citation the way the food-score modifiers do (`FOOD_CITES`, `index.html:3404-3414`), making them good targets for external research/validation.
