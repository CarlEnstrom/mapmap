# Office 365 (Graph/Outlook) – mailärenden till databas

Det här flödet använder **Outlook-noden i n8n** (Microsoft 365/Graph), inte IMAP.

Workflow: `n8n/workflows/mail_followup_dashboard.json`

## Hur långt bak kollar den var 10:e minut?
Kort svar: **max 30 minuter bakåt**.

- Normal lookback: `12` minuter (för att få 2 minuters säkerhetsmarginal vid 10-minuters körning).
- Konfigurerbar via env: `LOOKBACK_MINUTES` (tillåtet intervall 5–30).
- Hård spärr i flödet: även vid driftstopp/omstart klampar den lookback till max 30 minuter så att den **inte läser för långt bak**.

## Vad flödet gör
1. Kör var 10:e minut.
2. Hämtar mail från Office 365 via Outlook-pluginen:
   - `Sent Items` (utgående)
   - `Inbox` (inkommande)
3. Klassar mail till ärendetyper:
   - `question_out`
   - `question_in`
   - `reply_in`
   - `fortnox_offert` (både ut/in beroende på riktning)
4. Plockar ut relevant info till databasen:
   - vad frågan är (`question_text`)
   - när den skickades/kom in (`sent_at`, `received_at`, `asked_at`)
   - vem du väntar svar från (`waiting_for_email`)
   - vilket företag (`customer_company`, `waiting_for_company`)
   - ordernummer (`order_number`) med regex för 6 siffror som börjar med `819` (`819\d{3}`)
5. Sparar allt i Postgres med upsert.
6. Reconcilar status när svar kommer in i samma konversation.
7. Skickar lunchmail kl 12 med öppna ärenden.

## Databasmodell (PostgreSQL)
Tabell: `mail_cases`

Viktiga kolumner:
- `external_message_id` (unik)
- `conversation_id`
- `direction`, `case_type`, `status`
- `customer_email`, `customer_company`
- `waiting_for_email`, `waiting_for_company`
- `subject`, `question_text`, `question_excerpt`
- `order_number`
- `sent_at`, `received_at`, `asked_at`, `answered_at`
- `source_system`, `created_at`, `updated_at`

Se full schemafil: `n8n/docs/mail_cases_schema.sql`.

## Credentials i n8n
- Microsoft Outlook OAuth2 (din färdigkonfigurerade modul)
- Postgres

## Env-variabler
- `OUTLOOK_INBOX_FOLDER_ID` (default: `inbox`)
- `OUTLOOK_SENT_FOLDER_ID` (default: `sentitems`)
- `OWNER_EMAIL`
- `LOOKBACK_MINUTES` (default 12, max 30)

## Import
1. Workflows → Import from file
2. Välj `n8n/workflows/mail_followup_dashboard.json`
3. Koppla Outlook + Postgres credentials
4. Kör manuell testkörning
5. Aktivera workflow
