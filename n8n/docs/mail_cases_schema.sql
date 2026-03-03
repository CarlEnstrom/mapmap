CREATE TABLE IF NOT EXISTS mail_cases (
  id BIGSERIAL PRIMARY KEY,
  external_message_id TEXT NOT NULL,
  conversation_id TEXT,
  direction TEXT NOT NULL,
  case_type TEXT NOT NULL,
  status TEXT NOT NULL,
  customer_email TEXT,
  customer_company TEXT,
  customer_contact_person TEXT,
  owner_email TEXT,
  waiting_for_email TEXT,
  waiting_for_company TEXT,
  subject TEXT,
  question_text TEXT,
  question_excerpt TEXT,
  order_number TEXT,
  quote_number TEXT,
  quote_amount TEXT,
  quote_description TEXT,
  mail_to TEXT,
  pdf_expected BOOLEAN DEFAULT FALSE,
  pdf_parsed BOOLEAN DEFAULT FALSE,
  ai_candidate BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  asked_at TIMESTAMPTZ,
  answered_at TIMESTAMPTZ,
  source_system TEXT DEFAULT 'office365_graph',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (external_message_id)
);

CREATE TABLE IF NOT EXISTS quotes (
  id BIGSERIAL PRIMARY KEY,
  quote_number TEXT,
  external_message_id TEXT NOT NULL,
  conversation_id TEXT,
  customer_name TEXT,
  customer_company TEXT,
  contact_person TEXT,
  mail_to TEXT,
  quote_amount TEXT,
  quote_description TEXT,
  order_number TEXT,
  sent_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  pdf_expected BOOLEAN DEFAULT FALSE,
  pdf_parsed BOOLEAN DEFAULT FALSE,
  ai_candidate BOOLEAN DEFAULT FALSE,
  pdf_text_excerpt TEXT,
  source_system TEXT DEFAULT 'office365_graph',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (external_message_id)
);

CREATE INDEX IF NOT EXISTS idx_mail_cases_conversation_id ON mail_cases(conversation_id);
CREATE INDEX IF NOT EXISTS idx_mail_cases_status ON mail_cases(status);
CREATE INDEX IF NOT EXISTS idx_mail_cases_case_type ON mail_cases(case_type);
CREATE INDEX IF NOT EXISTS idx_mail_cases_customer_email ON mail_cases(customer_email);
CREATE INDEX IF NOT EXISTS idx_mail_cases_waiting_for_email ON mail_cases(waiting_for_email);
CREATE INDEX IF NOT EXISTS idx_mail_cases_order_number ON mail_cases(order_number);
CREATE INDEX IF NOT EXISTS idx_mail_cases_quote_number ON mail_cases(quote_number);

CREATE INDEX IF NOT EXISTS idx_quotes_quote_number ON quotes(quote_number);
CREATE INDEX IF NOT EXISTS idx_quotes_customer_company ON quotes(customer_company);
CREATE INDEX IF NOT EXISTS idx_quotes_order_number ON quotes(order_number);
CREATE INDEX IF NOT EXISTS idx_quotes_sent_at ON quotes(sent_at);
