-- The account of a person, as in 06-data/models.md. user_account, because user
-- is a word reserved by SQL. The only place e-mail and password hash are stored.
CREATE TABLE identity.user_account (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT        NOT NULL
                  CONSTRAINT chk_user_account_email
                  CHECK (email = lower(email) AND char_length(email) <= 255),
  password_hash   TEXT        NOT NULL,
  full_name       TEXT        NOT NULL
                  CONSTRAINT chk_user_account_full_name CHECK (char_length(full_name) BETWEEN 1 AND 200),
  role            TEXT        NOT NULL DEFAULT 'GUEST'
                  CONSTRAINT chk_user_account_role CHECK (role IN ('GUEST', 'HOST', 'ADMIN')),
  failed_logins   INTEGER     NOT NULL DEFAULT 0
                  CONSTRAINT chk_user_account_failed_logins CHECK (failed_logins >= 0),
  locked_until    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ,

  CONSTRAINT uq_user_account_email UNIQUE (email)
);
