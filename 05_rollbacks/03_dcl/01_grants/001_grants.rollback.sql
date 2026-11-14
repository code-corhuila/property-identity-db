REVOKE identity_writer FROM identity_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA identity REVOKE ALL ON TABLES FROM identity_reader, identity_writer;
REVOKE ALL ON ALL TABLES IN SCHEMA identity FROM identity_reader, identity_writer;
REVOKE USAGE ON SCHEMA identity FROM identity_reader, identity_writer;
