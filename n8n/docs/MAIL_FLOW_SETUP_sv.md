# n8n-flöde: mailbevakning för frågor/svar + lunchrapport (Office 365)

Ja – den här versionen är anpassad för att du kör **Office 365 / Exchange Online**.

Workflow-filen (`n8n/workflows/mail_followup_dashboard.json`) gör följande:

1. Kör var 10:e minut.
2. Läser **utgående mail (Sent Items)** och plockar ut mail där du ställt en fråga.
3. Läser **inkommande mail (INBOX)** och:
   - markerar när kunden har svarat på en tidigare fråga från dig,
   - identifierar frågor från kunder som väntar på svar från dig.
4. Håller **Fortnox/offert-mail** i separat kategori (`fortnox_offert`).
5. Skriver två filer:
   - `/data/mail-followup/todo.txt` (textlista)
   - `/data/mail-followup/dashboard.json` (för framtida webb-dashboard)
6. Skickar **en lunchrapport kl 12** till din egen mail (`OWNER_EMAIL`) med:
   - vad du väntar svar på,
   - vad kunder väntar på från dig.

## Viktigt filter (spam + fokus)
Flödet exkluderar auto/systemsvar (`noreply`, `mailer-daemon`, `out of office`, m.m.) och fokuserar på mail med frågemönster.

## Office 365-konfiguration
Använd dessa standardvärden:

- IMAP host: `outlook.office365.com`
- IMAP port: `993` (SSL/TLS)
- SMTP host: `smtp.office365.com`
- SMTP port: `587` (STARTTLS)
- Standardmapp för skickat: `Sent Items`

> Om din tenant har IMAP avstängt, aktivera IMAP för kontot eller byt till Microsoft Graph-baserad lösning.

## Konfiguration i n8n
Sätt följande i n8n (env eller expressions):

- `IMAP_SENT_FOLDER` (default i flödet är `Sent Items`)
- `OWNER_EMAIL` (din egen e-postadress)
- `SMTP_FROM` (avsändaradress för lunchrapport)

Samt credentials i noderna:

- **IMAP konto (Office 365)**
- **SMTP konto (Office 365)**

## Import i n8n
1. Gå till **Workflows → Import from file**.
2. Välj `n8n/workflows/mail_followup_dashboard.json`.
3. Koppla credentials.
4. Kör manuellt en testkörning.
5. Aktivera workflow.

## Nästa steg: Dashboard på hemsida
Använd `/data/mail-followup/dashboard.json` som datakälla i en webbsida (t.ex. via enkel API-endpoint eller server-side rendering). JSON innehåller två tydliga listor:

- `pendingFromCustomer` (du väntar på svar)
- `pendingFromMe` (kunden väntar på dig)
