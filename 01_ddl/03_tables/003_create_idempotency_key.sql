-- The key each account was created with (POST /register). models.md: same shape
-- as booking.idempotency_key, with user_id referencing identity.user_account (id).
-- Its foreign key goes in 04_alter.
CREATE TABLE identity.idempotency_key (
  key         TEXT        PRIMARY KEY
              CONSTRAINT chk_idempotency_key_length CHECK (char_length(key) BETWEEN 8 AND 128),
  user_id     UUID        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
