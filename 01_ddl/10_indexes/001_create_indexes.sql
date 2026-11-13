-- Indexes of 06-data/models.md. The login lookup by e-mail is served by
-- uq_user_account_email, and the lookup of a refresh token by
-- uq_refresh_token_token_hash.
-- Foreign key column; also "revoke every token of a user" on a stolen token.
CREATE INDEX idx_refresh_token_user_id ON identity.refresh_token (user_id);
-- Foreign key column.
CREATE INDEX idx_idempotency_key_user_id ON identity.idempotency_key (user_id);
