-- Foreign keys inside the schema, as in 06-data/models.md. An account is
-- soft-deleted (deleted_at), never removed, so the keys restrict the delete.
ALTER TABLE identity.refresh_token
  ADD CONSTRAINT fk_refresh_token_user_account
  FOREIGN KEY (user_id) REFERENCES identity.user_account (id) ON DELETE RESTRICT;

ALTER TABLE identity.idempotency_key
  ADD CONSTRAINT fk_idempotency_key_user_account
  FOREIGN KEY (user_id) REFERENCES identity.user_account (id) ON DELETE RESTRICT;
