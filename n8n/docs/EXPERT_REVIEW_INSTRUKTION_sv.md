# Instruktion för expertgranskning – Office365 mailuppföljning (n8n)

## Syfte
Detta script/workflow ska automatisera uppföljning av kunddialoger i Office 365 genom att:
1. läsa inkommande/utgående mail,
2. klassificera ärenden (fråga, svar, offert),
3. spara strukturerad data i Postgres,
4. hålla en separat offertentitet,
5. skicka daglig lunchsammanfattning av öppna ärenden.

Målet är att ge en pålitlig datagrund för dashboard och operativ uppföljning.

---

## Omfattning (filer att granska)
- Workflow: `n8n/workflows/mail_followup_dashboard.json`
- Setup: `n8n/docs/MAIL_FLOW_SETUP_sv.md`
- Schema: `n8n/docs/mail_cases_schema.sql`

---

## Förväntat beteende i workflow

### 1) Trigger och tidsfönster
- Körning var 10:e minut.
- Lookback styrs av `LOOKBACK_MINUTES` (default 12, min 5, max 30).
- Tidsfönster får aldrig bli äldre än 30 minuter bakåt även efter driftstopp.

### 2) Datakällor (Office 365 / Graph)
- Hämtar från Outlook Sent Items + Inbox via n8n Outlook-nod.
- Inga IMAP-anrop ska användas i denna version.

### 3) Förfilter innan tyngre analys
- Filter på `TARGET_DOMAINS`/`TARGET_EMAILS` (om satta).
- Auto/systemsvar ignoreras.
- Endast relevanta kandidater går vidare (`ai_candidate`).

### 4) Klassificering och extraktion
Scriptet ska extrahera och spara:
- Ärendefält: riktning, status, ämne, fråga/svar-excerpt, tidsfält.
- Affärsfält: ordernummer (`819\d{3}`), offertnummer, offertbelopp, offertbeskrivning.
- Partsfält: kundmail, kunddomän/bolag, kontaktperson, mottagare, väntad part.

Klassificering:
- `question_out`, `question_in`, `reply_in`, `fortnox_offert`.

### 5) Databaspersistens
- Upsert till `mail_cases` på `external_message_id`.
- Separat upsert till `quotes` för `fortnox_offert`.
- Reconciliation: utgående fråga markeras besvarad vid inkommande i samma `conversation_id`.

### 6) Lunchmail
- Lunchguard aktiverar utskick kl 12, max en gång per dag.
- IF-noden ska ha både true/false-gren (false = explicit no-op).

---

## Datamodell (intent)

### `mail_cases`
Operativ huvudtabell för all mailuppföljning.
- Primärnyckel: `id`
- Unik nyckel: `external_message_id`
- Kärnfält: status, direction, case_type, subject, tidsfält
- Affärsfält: order/offert, pdf-flaggor, ai-candidate

### `quotes`
Renodlad offertentitet för offertöversikt/dashboard.
- Primärnyckel: `id`
- Unik nyckel: `external_message_id`
- Kärnfält: quote_number, customer/contact, amount/description, pdf-status

---

## Icke-funktionella krav för granskning
- Idempotens: upprepade körningar får inte skapa dubbletter.
- Stabilitet: ofullständig maildata får inte krascha flödet.
- Prestanda: lookback + förfilter ska begränsa datamängd.
- Spårbarhet: fält ska vara tillräckliga för felsökning och dashboard.

---

## Öppna punkter att verifiera särskilt
1. Outlook-nodens exakta fältnamn i aktuell n8n-version (sent/inbox payload).
2. SQL-injektion-/escaping-risk i templateuttryck i raw SQL-noder.
3. Regex-precision för offertnummer/belopp på verklig data.
4. Mapping av kundbolag från domän (subdomäner, delade domäner).
5. Hur PDF-bilagor ska hämtas och tolkas i nästa steg (nu endast förberett med flaggor).

---

## Acceptanskriterier (expert sign-off)
- [ ] Workflow importeras och körs i n8n utan valideringsfel.
- [ ] Outlook-hämtning returnerar rätt fält från både sent/inbox.
- [ ] Förfilter på domän/person fungerar enligt env-variabler.
- [ ] `mail_cases` upsert fungerar idempotent.
- [ ] `quotes` fylls endast för offertrelaterade mail.
- [ ] Reconciliation uppdaterar status korrekt i verkliga trådar.
- [ ] Lunchmail triggas endast i lunchfönster och false-gren är explicit.
- [ ] Schema/index stödjer planerade dashboard-frågor.

---

## Rekommenderad nästa tekniska iteration
- Lägg till dedikerad bilagekedja för PDF (download → text extraction → parser → update `quotes`).
- Flytta SQL till parametriserade queries eller mellanliggande safe mapping node.
- Lägg till testdataset och replay-flöde för regressionstest.
