-- The refresh tokens of each session, stored hashed, as in 06-data/models.md.
-- Its foreign key goes in 04_alter.
CREATE TABLE identity.refresh_token (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL,
  token_hash  TEXT        NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked_at  TIMESTAMPTZ,              -- filled when the token is used, replaced or revoked
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_refresh_token_token_hash UNIQUE (token_hash)
);
