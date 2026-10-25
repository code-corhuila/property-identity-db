-- identity_app, through identity_writer, reads, inserts and updates in identity,
-- and can neither delete nor change structure (migration-strategy.md). The
-- check of Annex J.10: it writes only in its own schema.
-- Everything runs in one transaction that is rolled back.
BEGIN;
SET LOCAL ROLE identity_app;

INSERT INTO identity.user_account (id, email, password_hash, full_name)
VALUES ('22222222-2222-4222-8222-222222222222', 'ana@example.com', '$2a$12$hash', 'Ana Pérez');
INSERT INTO identity.idempotency_key (key, user_id)
VALUES ('register-0001', '22222222-2222-4222-8222-222222222222');
INSERT INTO identity.refresh_token (user_id, token_hash, expires_at)
VALUES ('22222222-2222-4222-8222-222222222222', 'hash-0001', now() + interval '7 days');
UPDATE identity.user_account SET failed_logins = failed_logins + 1
WHERE id = '22222222-2222-4222-8222-222222222222';
UPDATE identity.refresh_token SET revoked_at = now() WHERE token_hash = 'hash-0001';
SELECT count(*) AS visible_accounts FROM identity.user_account;

DO $$
BEGIN
  DELETE FROM identity.refresh_token;
  RAISE EXCEPTION 'identity_app could delete';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'identity_app cannot delete';
END
$$;

DO $$
BEGIN
  CREATE TABLE identity.not_allowed (id int);
  RAISE EXCEPTION 'identity_app could create a table';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'identity_app cannot change structure';
END
$$;

RESET ROLE;

-- Annex J.10: the schemas where identity_app can write.
DO $$
DECLARE
  schemas text;
BEGIN
  SELECT string_agg(DISTINCT n.nspname, ', ') INTO schemas
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
    AND n.nspname NOT LIKE 'pg\_%' AND n.nspname <> 'information_schema'
    AND has_schema_privilege('identity_app', n.nspname, 'USAGE')
    AND (has_table_privilege('identity_app', c.oid, 'INSERT')
         OR has_table_privilege('identity_app', c.oid, 'UPDATE')
         OR has_table_privilege('identity_app', c.oid, 'DELETE'));
  IF schemas IS DISTINCT FROM 'identity' THEN
    RAISE EXCEPTION 'identity_app writes in: %', schemas;
  END IF;
  RAISE NOTICE 'Annex J.10: identity_app writes only in identity';
END
$$;

ROLLBACK;
