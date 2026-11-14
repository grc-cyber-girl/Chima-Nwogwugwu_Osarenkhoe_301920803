-- Identify this connection.
SET application_name = 'p3_session_b';

-- Start a transaction using READ COMMITTED isolation.
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Confirm the isolation level.
SHOW transaction_isolation;

-- Check the visible balance
SELECT
    account_number,
    balance
FROM public.account
WHERE account_number = '2000000001';

-- Attempt another withdrawal of ₦30,000.
UPDATE public.account
SET balance = balance - 30000
WHERE account_number = '2000000001'
  AND balance >= 30000;

-- Session A has updated the account row but has not committed. PostgreSQL holds a row lock while that transaction is active. Session B must wait for Session A to finish before it can complete its conflicting update.

COMMIT;

SELECT
    account_number,
    balance,
    account_status
FROM public.account
WHERE account_number = '2000000001';
-- Confirms the account balance to be ₦20,000 because one withdrawal succeeded. The second withdrawal was prevented because the account no longer had sufficient funds.