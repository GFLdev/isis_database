CREATE SCHEMA account;

--------------------
--- Custom Types ---
--------------------

CREATE TYPE SERVICE_NAME AS ENUM ('account', 'finance', 'drive');
COMMENT ON TYPE SERVICE_NAME IS 'Service name';

CREATE TYPE TABLE_NAME AS ENUM ('account', 'account_group', 'group_permission', 'refresh_token', 'login_attempt');
COMMENT ON TYPE TABLE_NAME IS 'Table name';

CREATE TYPE QUERY_TYPE AS ENUM ('insert', 'select' , 'update', 'delete');
COMMENT ON TYPE QUERY_TYPE IS 'Query type';

CREATE TYPE LOG_TYPE AS ENUM ('success','error');
COMMENT ON TYPE LOG_TYPE IS 'Log type';

---------------------
--- ACCOUNT_GROUP ---
---------------------

CREATE TABLE account.account_group
(
    account_group_id UUID PRIMARY KEY     DEFAULT gen_random_uuid(),
    name             VARCHAR(50) NOT NULL,
    description      VARCHAR(1000),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    modified_at      TIMESTAMPTZ
);
COMMENT ON TABLE account.account_group IS 'Account group table';
COMMENT ON COLUMN account.account_group.account_group_id IS 'Account group id';
COMMENT ON COLUMN account.account_group.name IS 'Account group''s name';
COMMENT ON COLUMN account.account_group.description IS 'Account group''s description';
COMMENT ON COLUMN account.account_group.created_at IS 'Account group''s creation date';
COMMENT ON COLUMN account.account_group.modified_at IS 'Account group''s last modification date';

---------------
--- ACCOUNT ---
---------------

CREATE TABLE account.account
(
    account_id       UUID PRIMARY KEY             DEFAULT gen_random_uuid(),
    account_group_id UUID                NOT NULL,
    username         VARCHAR(30) UNIQUE  NOT NULL,
    name             VARCHAR(100)        NOT NULL,
    surname          VARCHAR(100)        NOT NULL,
    email            VARCHAR(100) UNIQUE NOT NULL,
    password         VARCHAR(72)         NOT NULL,
    is_active        BOOLEAN             NOT NULL DEFAULT TRUE,
    login_count      INTEGER             NOT NULL DEFAULT 0,
    last_login_at    TIMESTAMPTZ,
    created_at       TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    modified_at      TIMESTAMPTZ,
    FOREIGN KEY (account_group_id) REFERENCES account.account_group (account_group_id) ON DELETE CASCADE,
    CONSTRAINT username_length CHECK (CHAR_LENGTH(username) >= 4)
);
COMMENT ON TABLE account.account IS 'Account table';
COMMENT ON COLUMN account.account.account_id IS 'Account''s id';
COMMENT ON COLUMN account.account.account_group_id IS 'Account''s group id';
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

------------------------
--- GROUP_PERMISSION ---
------------------------

CREATE TABLE account.group_permission (
    group_permission_id uuid PRIMARY KEY      DEFAULT gen_random_uuid(),
    account_group_id    uuid         NOT NULL,
    service_name        service_name NOT NULL,
    is_able             BOOLEAN      NOT NULL DEFAULT TRUE,
    is_admin            BOOLEAN      NOT NULL DEFAULT FALSE,
    FOREIGN KEY (account_group_id)
        REFERENCES account.account_group (account_group_id) ON DELETE CASCADE
);
COMMENT ON TABLE account.group_permission IS 'Group permission table';
COMMENT ON COLUMN account.group_permission.group_permission_id IS 'Group permission''s id';
COMMENT ON COLUMN account.group_permission.account_group_id IS 'Account group linked to group permission';
COMMENT ON COLUMN account.group_permission.service_name IS 'Service linked to group permission';
COMMENT ON COLUMN account.group_permission.is_able IS 'If the group permission is able to access the module';
COMMENT ON COLUMN account.group_permission.is_admin IS 'If the group permission is an admin';

---------------------
--- REFRESH_TOKEN ---
---------------------

CREATE TABLE account.refresh_token
(
    refresh_token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id       UUID        NOT NULL,
    expiration_date  TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (account_id) REFERENCES account.account (account_id) ON DELETE CASCADE
);
COMMENT ON TABLE account.refresh_token IS 'Refresh token table';
COMMENT ON COLUMN account.refresh_token.refresh_token_id IS 'Refresh token''s id, used as the token itself';
COMMENT ON COLUMN account.refresh_token.account_id IS 'Account linked to refresh token';
COMMENT ON COLUMN account.refresh_token.expiration_date IS 'Refresh token''s expiration date';

---------------------
--- LOGIN_ATTEMPT ---
---------------------

CREATE TABLE account.login_attempt
(
    login_attempt_id UUID PRIMARY KEY     DEFAULT gen_random_uuid(),
    account_id       UUID        NOT NULL,
    attempted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    success          BOOLEAN     NOT NULL,
    ip_address       VARCHAR(15) NOT NULL,
    user_agent       TEXT        NOT NULL,
    FOREIGN KEY (account_id) REFERENCES account.account (account_id) ON DELETE CASCADE
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

CREATE TABLE account.account_log
(
    log_id      UUID PRIMARY KEY       DEFAULT gen_random_uuid(),
    table_name  TABLE_NAME    NOT NULL,
    table_field VARCHAR(50)   NOT NULL,
    pk_value    VARCHAR(36)   NOT NULL,
    query_type  QUERY_TYPE    NOT NULL,
    log_type    LOG_TYPE      NOT NULL,
    message     VARCHAR(1000) NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
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