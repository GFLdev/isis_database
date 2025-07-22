CREATE SCHEMA account;

--------------------
--- Custom Types ---
--------------------

CREATE TYPE account.module_name AS ENUM ('account', 'finance', 'drive', 'calendar', 'ai');
COMMENT ON TYPE account.module_name IS 'Module name';

CREATE TYPE account.table_name AS ENUM ('account', 'role', 'role_module', 'module','refresh_token', 'login_attempt');
COMMENT ON TYPE account.table_name IS 'Table name';

CREATE TYPE account.query_type AS ENUM ('insert', 'select' , 'update', 'delete');
COMMENT ON TYPE account.query_type IS 'Query type';

CREATE TYPE account.log_type AS ENUM ('success','error');
COMMENT ON TYPE account.log_type IS 'Log type';

------------
--- ROLE ---
------------

CREATE TABLE account.role (
    role_id     uuid PRIMARY KEY     DEFAULT gen_random_uuid(),
    name        VARCHAR(50) NOT NULL,
    description VARCHAR(1000),
    created_at  timestamptz NOT NULL DEFAULT NOW(),
    modified_at timestamptz
);
COMMENT ON TABLE account.role IS 'Role table';
COMMENT ON COLUMN account.role.role_id IS 'Role id';
COMMENT ON COLUMN account.role.name IS 'Role''s name';
COMMENT ON COLUMN account.role.description IS 'Role''s description';
COMMENT ON COLUMN account.role.created_at IS 'Role''s creation date';
COMMENT ON COLUMN account.role.modified_at IS 'Role''s last modification date';

--------------
--- MODULE ---
--------------

CREATE TABLE account.module (
    module_name account.module_name PRIMARY KEY,
    description VARCHAR(1000)
);
COMMENT ON TABLE account.module IS 'Module table';
COMMENT ON COLUMN account.module.module_name IS 'Module''s name';
COMMENT ON COLUMN account.module.description IS 'Module''s description';

-------------------
--- ROLE_MODULE ---
-------------------

CREATE TABLE account.role_module (
    role_id     uuid                NOT NULL,
    module_name account.module_name NOT NULL,
    elevated    BOOLEAN             NOT NULL DEFAULT FALSE,
    FOREIGN KEY (role_id)
        REFERENCES account.role (role_id) ON DELETE CASCADE,
    FOREIGN KEY (module_name)
        REFERENCES account.module (module_name) ON DELETE CASCADE
);
COMMENT ON TABLE account.role_module IS 'Role-Module reference table';
COMMENT ON COLUMN account.role_module.role_id IS 'Role id';
COMMENT ON COLUMN account.role_module.module_name IS 'Module name';
COMMENT ON COLUMN account.role_module.elevated IS 'Elevated (admin) permission flag';

---------------
--- ACCOUNT ---
---------------

CREATE TABLE account.account (
    account_id    uuid PRIMARY KEY             DEFAULT gen_random_uuid(),
    role_id       uuid                NOT NULL,
    username      VARCHAR(30) UNIQUE  NOT NULL,
    name          VARCHAR(100)        NOT NULL,
    surname       VARCHAR(100)        NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password      VARCHAR(72)         NOT NULL,
    is_active     BOOLEAN             NOT NULL DEFAULT TRUE,
    login_count   INTEGER             NOT NULL DEFAULT 0,
    last_login_at timestamptz,
    created_at    timestamptz         NOT NULL DEFAULT NOW(),
    modified_at   timestamptz,
    FOREIGN KEY (role_id)
        REFERENCES account.role (role_id) ON DELETE CASCADE,
    CONSTRAINT username_length CHECK (CHAR_LENGTH(username) >= 4)
);
COMMENT ON TABLE account.account IS 'Account table';
COMMENT ON COLUMN account.account.account_id IS 'Account''s id';
COMMENT ON COLUMN account.account.role_id IS 'Account''s role id';
COMMENT ON COLUMN account.account.username IS 'Account''s username';
COMMENT ON COLUMN account.account.name IS 'Account''s user first name';
COMMENT ON COLUMN account.account.surname IS 'Account''s user surname';
COMMENT ON COLUMN account.account.email IS 'Account''s user email';
COMMENT ON COLUMN account.account.password IS 'Account''s bcrypt hash';
COMMENT ON COLUMN account.account.is_active IS 'Account''s active status';
COMMENT ON COLUMN account.account.login_count IS 'Account''s login count';
COMMENT ON COLUMN account.account.last_login_at IS 'Account''s last login date';
COMMENT ON COLUMN account.account.created_at IS 'Account''s creation date';
COMMENT ON COLUMN account.account.modified_at IS 'Account''s last modification date';

---------------------
--- REFRESH_TOKEN ---
---------------------

CREATE TABLE account.refresh_token (
    refresh_token_id VARCHAR(72) PRIMARY KEY NOT NULL,
    account_id       uuid                    NOT NULL,
    expiration_date  timestamptz             NOT NULL,
    FOREIGN KEY (account_id)
        REFERENCES account.account (account_id) ON DELETE CASCADE
);
COMMENT ON TABLE account.refresh_token IS 'Refresh token table';
COMMENT ON COLUMN account.refresh_token.refresh_token_id IS 'Refresh token''s id, used as the token itself';
COMMENT ON COLUMN account.refresh_token.account_id IS 'Account linked to refresh token';
COMMENT ON COLUMN account.refresh_token.expiration_date IS 'Refresh token''s expiration date';

---------------------
--- LOGIN_ATTEMPT ---
---------------------

CREATE TABLE account.login_attempt (
    login_attempt_id uuid PRIMARY KEY     DEFAULT gen_random_uuid(),
    account_id       uuid        NOT NULL,
    attempted_at     timestamptz NOT NULL DEFAULT NOW(),
    success          BOOLEAN     NOT NULL,
    ip_address       VARCHAR(15) NOT NULL,
    user_agent       TEXT        NOT NULL,
    FOREIGN KEY (account_id)
        REFERENCES account.account (account_id) ON DELETE CASCADE
);
COMMENT ON TABLE account.login_attempt IS 'Login attempt''s log table';
COMMENT ON COLUMN account.login_attempt.login_attempt_id IS 'Login attempt''s id';
COMMENT ON COLUMN account.login_attempt.account_id IS 'Account linked to login attempt';
COMMENT ON COLUMN account.login_attempt.attempted_at IS 'Login attempt''s date';
COMMENT ON COLUMN account.login_attempt.success IS 'Login attempt''s success status';
COMMENT ON COLUMN account.login_attempt.ip_address IS 'Login attempt''s ip address';
COMMENT ON COLUMN account.login_attempt.user_agent IS 'Login attempt''s user agent';

-------------------
--- ACCOUNT_LOG ---
-------------------

CREATE TABLE account.account_log (
    log_id      uuid PRIMARY KEY            DEFAULT gen_random_uuid(),
    table_name  account.table_name NOT NULL,
    table_field VARCHAR(50)        NOT NULL,
    pk_value    VARCHAR(36)        NOT NULL,
    query_type  account.query_type NOT NULL,
    log_type    account.log_type   NOT NULL,
    message     VARCHAR(1000)      NOT NULL,
    created_at  timestamptz        NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE account.account_log IS 'Account log table';
COMMENT ON COLUMN account.account_log.log_id IS 'Account log''s id';
COMMENT ON COLUMN account.account_log.table_name IS 'Table name';
COMMENT ON COLUMN account.account_log.table_field IS 'Table field';
COMMENT ON COLUMN account.account_log.pk_value IS 'Primary key value';
COMMENT ON COLUMN account.account_log.query_type IS 'Query type';
COMMENT ON COLUMN account.account_log.log_type IS 'Log type';
COMMENT ON COLUMN account.account_log.message IS 'Log message';
COMMENT ON COLUMN account.account_log.created_at IS 'Log creation date';