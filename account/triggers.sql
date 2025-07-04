-- Trigger that clears all active refresh token of the insertion's account
-- if it exists
CREATE OR REPLACE TRIGGER trigger_clear_refresh_tokens
    BEFORE INSERT
    ON account.refresh_token
    FOR EACH ROW
EXECUTE FUNCTION account.clear_accounts_refresh_token();