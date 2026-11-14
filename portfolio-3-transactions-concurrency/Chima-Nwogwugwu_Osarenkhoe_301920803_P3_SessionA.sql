-- Identify this connection.
SET application_name = 'p3_session_a';

-- Start a transaction using READ COMMITTED isolation.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Confirm the isolation level.
SHOW transaction_isolation;

-- Attempt to withdraw ₦30,000.
UPDATE public.account
SET balance = balance - 30000
WHERE account_number = '2000000001'
  AND balance >= 30000;

-- Check whether Session B is waiting for a database lock.
SELECT
    application_name,
    wait_event_type,
    state
FROM pg_stat_activity
WHERE application_name = 'p3_session_b';

-- Expected: p3_session_b | Lock. 
COMMIT;
-- Switch to Session B, its waiting update now finishes.

SELECT
    account_number,
    balance,
    account_status
FROM public.account
WHERE account_number = '2000000001';
-- Confirms the account balance to be ₦20,000 because one withdrawal succeeded. The second withdrawal was prevented because the account no longer had sufficient funds.