-- Least privilege. The writer reads, inserts and updates: the login counter, the
-- role, the revocation of a refresh token and the soft delete are updates; an
-- account is never removed (deleted_at), and nobody but the runner changes
-- structure (migration-strategy.md).
-- The reader is granted to nobody: this project has no cross-domain reads
-- (ADR-008, rule 5).
GRANT USAGE ON SCHEMA identity TO identity_reader, identity_writer;
GRANT SELECT ON ALL TABLES IN SCHEMA identity TO identity_reader;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA identity TO identity_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA identity GRANT SELECT ON TABLES TO identity_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA identity GRANT SELECT, INSERT, UPDATE ON TABLES TO identity_writer;

-- The service connects as identity_app, which holds the writer role (Annex J.7).
GRANT identity_writer TO identity_app;
