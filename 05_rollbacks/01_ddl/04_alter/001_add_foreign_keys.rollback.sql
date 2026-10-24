ALTER TABLE identity.idempotency_key DROP CONSTRAINT IF EXISTS fk_idempotency_key_user_account;
ALTER TABLE identity.refresh_token   DROP CONSTRAINT IF EXISTS fk_refresh_token_user_account;
