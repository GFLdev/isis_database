-- Identify if there is a current refresh token in use, for an account.
-- If there is one, it deletes it, otherwise, procedes to the event.
CREATE OR REPLACE FUNCTION account.clear_accounts_refresh_token() RETURNS TRIGGER AS
$$
BEGIN
    -- If there is at least one, deletes it/them
    DELETE
    FROM account.refresh_token rt
    WHERE rt.account_id = new.account_id;

    -- Continues the event
    RETURN new;
END;
$$ LANGUAGE plpgsql;