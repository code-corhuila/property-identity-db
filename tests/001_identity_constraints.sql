-- The constraints of the identity schema (06-data/models.md):
--   one account per e-mail, stored in lower case;
--   one role per account, only GUEST, HOST or ADMIN, GUEST by default;
--   a failed-login counter that never goes below zero;
--   a refresh token hash stored once; an idempotency key stored once.
-- Everything runs in one transaction that is rolled back.
BEGIN;

INSERT INTO identity.user_account (id, email, password_hash, full_name)
VALUES ('22222222-2222-4222-8222-222222222222', 'ana@example.com', '$2a$12$hash', 'Ana Pérez');
INSERT INTO identity.refresh_token (user_id, token_hash, expires_at)
VALUES ('22222222-2222-4222-8222-222222222222', 'hash-0001', now() + interval '7 days');
INSERT INTO identity.idempotency_key (key, user_id)
VALUES ('register-0001', '22222222-2222-4222-8222-222222222222');

DO $$
BEGIN
  IF (SELECT role FROM identity.user_account WHERE email = 'ana@example.com') <> 'GUEST' THEN
    RAISE EXCEPTION 'a new account is not GUEST by default';
  END IF;
  RAISE NOTICE 'a new account is GUEST by default';
END
$$;

DO $$
BEGIN
  INSERT INTO identity.user_account (email, password_hash, full_name)
  VALUES ('ana@example.com', '$2a$12$other', 'Otra Ana');
  RAISE EXCEPTION 'uq_user_account_email not enforced: a second account with the same e-mail was stored';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'uq_user_account_email: a second account with the same e-mail rejected';
END
$$;

DO $$
BEGIN
  INSERT INTO identity.user_account (email, password_hash, full_name)
  VALUES ('Luis@Example.com', '$2a$12$hash', 'Luis');
  RAISE EXCEPTION 'chk_user_account_email not enforced: an e-mail in upper case was stored';
EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'chk_user_account_email: an e-mail not in lower case rejected';
END
$$;

DO $$
BEGIN
  INSERT INTO identity.user_account (email, password_hash, full_name, role)
  VALUES ('luis@example.com', '$2a$12$hash', 'Luis', 'SUPERUSER');
  RAISE EXCEPTION 'chk_user_account_role not enforced: an unknown role was stored';
EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'chk_user_account_role: a role other than GUEST, HOST or ADMIN rejected';
END
$$;

DO $$
BEGIN
  UPDATE identity.user_account SET failed_logins = -1 WHERE email = 'ana@example.com';
  RAISE EXCEPTION 'chk_user_account_failed_logins not enforced: a negative counter was stored';
EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'chk_user_account_failed_logins: a negative counter rejected';
END
$$;

DO $$
BEGIN
  INSERT INTO identity.refresh_token (user_id, token_hash, expires_at)
  VALUES ('22222222-2222-4222-8222-222222222222', 'hash-0001', now() + interval '7 days');
  RAISE EXCEPTION 'uq_refresh_token_token_hash not enforced: a token hash was stored twice';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'uq_refresh_token_token_hash: a repeated token hash rejected';
END
$$;

DO $$
BEGIN
  INSERT INTO identity.idempotency_key (key, user_id)
  VALUES ('register-0001', '22222222-2222-4222-8222-222222222222');
  RAISE EXCEPTION 'idempotency_key not enforced: a repeated key was stored';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'idempotency_key: a repeated key rejected';
END
$$;

ROLLBACK;
