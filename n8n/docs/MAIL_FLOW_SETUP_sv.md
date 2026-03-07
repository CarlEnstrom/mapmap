# Office 365 (Graph/Outlook) – mailärenden + offertentitet till databas

Det här flödet använder **Outlook-noden i n8n** (Microsoft 365/Graph), inte IMAP.

Workflow: `n8n/workflows/mail_followup_dashboard.json`

## Hur långt bak kollar den var 10:e minut?
Kort svar: **max 30 minuter bakåt**.

- Normal lookback: `12` minuter.
- Konfigurerbar via env: `LOOKBACK_MINUTES` (intervall 5–30).
- Hård spärr i flödet: aldrig mer än 30 minuter bak även efter stopp/omstart.

## Vad som nu är tillagt för offerter
När en offertkopia (t.ex. Fortnox/offert-mail) hittas skapas den inte bara i `mail_cases` utan även i en separat offertentitet: **`quotes`**.

`quotes` lagrar:
- `quote_number` (offertnummer)
- `customer_name` / `customer_company`
- `contact_person`
- `mail_to` (vem mailet gick till)
- `quote_amount`
- `quote_description`
- `order_number` (matchar `819\d{3}`)
- tidsfält (`sent_at`, `received_at`)
- PDF-status (`pdf_expected`, `pdf_parsed`, `pdf_text_excerpt`)

## PDF-innehåll (belopp + beskrivning)
Nuvarande version markerar om PDF förväntas (`pdf_expected`) och sparar textutdrag från mailtext i `pdf_text_excerpt`.

För full PDF-tolkning (öppna bilaga och extrahera exakt belopp/beskrivning) behöver du lägga till en bilagekedja i n8n:
1. Hämta bilagor för offertmail (Outlook attachment endpoint/node).
2. Filtrera på `.pdf`.
3. Kör PDF text extraction-node.
4. Uppdatera `quotes.quote_amount`, `quotes.quote_description`, `quotes.pdf_parsed = true`.

Datamodellen är redan förberedd för detta.

## Övrig information som extraheras
Både utgående och inkommande klassning plockar ut:
- `question_text`, `question_excerpt`
- `sent_at`, `received_at`, `asked_at`
- väntande part (`waiting_for_email`, `waiting_for_company`)
- kundfält (`customer_email`, `customer_company`, `customer_contact_person`)
- `order_number`, `quote_number`, `quote_amount`


## Förfilter innan AI/analys
Flödet filtrerar nu **innan eventuell AI-analys** så att bara relevanta mail går vidare:

- Utgående: mottagare måste matcha `TARGET_DOMAINS` eller `TARGET_EMAILS` (om satta).
- Inkommande: avsändare måste matcha `TARGET_DOMAINS` eller `TARGET_EMAILS` (om satta).
- Endast frågor, offerter eller sannolika svar/trådar (`Re:/Sv:` / `conversationId`) markeras som AI-kandidater (`ai_candidate=true`).

Detta minskar token-spill och fokuserar på mail där det faktiskt kan finnas svar på dina frågor.

## Credentials i n8n
- Microsoft Outlook OAuth2
- Postgres

## Env-variabler
- `OUTLOOK_INBOX_FOLDER_ID` (default: `inbox`)
- `OUTLOOK_SENT_FOLDER_ID` (default: `sentitems`)
- `OWNER_EMAIL`
- `LOOKBACK_MINUTES` (default 12, max 30)
- `TARGET_DOMAINS` (kommaseparerat, t.ex. `kund.se,partner.com`)
- `TARGET_EMAILS` (kommaseparerat, t.ex. `anna@kund.se,info@partner.com`)


- IF-noden **"Är lunchmail aktivt?"** har nu både true/false-gren kopplad. False går till en no-op ("Ingen lunchmail (skip)") så flödet inte ser tomt ut i editorn.

## Import
1. Workflows → Import from file
2. Välj `n8n/workflows/mail_followup_dashboard.json`
3. Koppla Outlook + Postgres credentials
4. Kör manuell testkörning
5. Aktivera workflow
