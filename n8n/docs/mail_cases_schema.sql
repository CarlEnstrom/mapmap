CREATE TABLE IF NOT EXISTS mail_cases (
  id BIGSERIAL PRIMARY KEY,
  external_message_id TEXT NOT NULL,
  conversation_id TEXT,
  direction TEXT NOT NULL,
  case_type TEXT NOT NULL,
  status TEXT NOT NULL,
  customer_email TEXT,
  customer_company TEXT,
  owner_email TEXT,
  waiting_for_email TEXT,
  waiting_for_company TEXT,
  subject TEXT,
  question_text TEXT,
  question_excerpt TEXT,
  order_number TEXT,
  sent_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  asked_at TIMESTAMPTZ,
  answered_at TIMESTAMPTZ,
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
