# Office 365 (Graph/Outlook) – mailärenden till databas

Du har helt rätt. Den här versionen använder **Outlook-noden i n8n** (Microsoft 365/Graph), inte IMAP-polling.

Workflow: `n8n/workflows/mail_followup_dashboard.json`

## Vad flödet gör
1. Kör var 10:e minut.
2. Hämtar mail från Office 365 via **Outlook-pluginen**:
   - `Sent Items` (utgående)
   - `Inbox` (inkommande)
3. Klassar mail till ärendetyper:
   - `question_out` (frågor du skickat)
   - `question_in` (frågor kunder ställt till dig)
   - `reply_in` (svar in från kund)
   - `fortnox_offert` (offerter/fortnox-relaterat)
4. Sparar allt i databasen med upsert.
5. Reconcilar status (t.ex. utgående fråga markeras besvarad när inkommande i samma conversation kommer in).
6. Skickar lunchmail kl 12 med öppna ärenden.

---

## Databasmodell (PostgreSQL)
Skapas automatiskt av workflow, tabell: `mail_cases`

Fält:
- `id` (PK)
- `external_message_id` (unik)
- `conversation_id`
- `direction` (`outgoing` / `incoming`)
- `case_type` (`question_out`, `question_in`, `reply_in`, `fortnox_offert`)
- `status` (`waiting_customer`, `waiting_me`, `answered_customer`)
- `customer_email`
- `owner_email`
- `subject`
- `question_excerpt`
- `sent_at`
- `received_at`
- `answered_at`
- `source_system` (default `office365_graph`)
- `created_at`, `updated_at`

---

## Nödvändiga credentials i n8n
- **Microsoft Outlook OAuth2** (din redan färdigkonfigurerade modul)
- **Postgres**

## Rekommenderade env-variabler
- `OUTLOOK_INBOX_FOLDER_ID` (default: `inbox`)
- `OUTLOOK_SENT_FOLDER_ID` (default: `sentitems`)
- `OWNER_EMAIL` (adress för lunchrapport)

---

## Import
1. Workflows → Import from file
2. Välj `n8n/workflows/mail_followup_dashboard.json`
3. Koppla Outlook + Postgres credentials
4. Kör manuellt en testkörning
5. Aktivera workflow

---

## Viktig notering
Om du vill ha 100% exakt klassning per kund/ärende rekommenderas att lägga till en separat regelmotor (ex. tabell med kunddomäner, ämnesprefix, “mitt svar saknas i tråden”-logik). Den här versionen ger en robust bas med tydlig datamodell för dashboard.
