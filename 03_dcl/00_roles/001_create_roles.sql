-- Roles are NOLOGIN: they carry permissions. Roles belong to the whole instance,
-- so their names start with the domain (Annex J.4). The login user identity_app
-- is created by property-infra-postgres from a secret; no password is ever
-- versioned in this repository.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'identity_reader') THEN
        CREATE ROLE identity_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'identity_writer') THEN
        CREATE ROLE identity_writer NOLOGIN;
    END IF;
END
$$;
