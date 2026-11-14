-- This confirms the records before we start changing anything
-- Check customer login details.
SELECT
    c.first_name,
    c.last_name,
    u.username,
    u.last_login
FROM public.customer c
JOIN public.app_user u
    ON c.customer_id = u.customer_id
ORDER BY c.customer_id;

-- Check account balances.
SELECT
    account_number,
    balance,
    account_status
FROM public.account
ORDER BY account_id;

-- Start a transaction.
BEGIN;

-- Update Tunde Bello's login date only if it is currently NULL.
UPDATE public.app_user
SET last_login = TIMESTAMPTZ '2026-11-14 08:00:00+00'
WHERE username = 'tunde_bello'
  AND last_login IS NULL;

-- Save the change permanently.
COMMIT;

-- Check whether the update was made
SELECT
    username,
    last_login
FROM public.app_user
WHERE username = 'tunde_bello';

-- Attempt to update the login date again.
-- The condition prevents an existing login date from being overwritten.

UPDATE public.app_user
SET last_login = TIMESTAMPTZ '2026-11-14 09:00:00+00'
WHERE username = 'tunde_bello'
  AND last_login IS NULL;

-- Start a new transaction.
BEGIN;

-- Reduce Ada's account balance by ₦1,000.
UPDATE public.account
SET balance = balance - 1000
WHERE account_number = '2000000001';

-- Attempt to set Ada's account balance to a negative amount.
UPDATE public.account
SET balance = -500
WHERE account_number = '2000000001';

-- Undo all changes made in this transaction due to the error we got when trying to set Ada's account to negative.
ROLLBACK;

-- Confirm the committed and rolled-back changes
--Check Tunde's login date stayed after the rollback to ensure the transaction were the update was made wasn't affected by the rollback of another transaction
SELECT
    username,
    last_login
FROM public.app_user
WHERE username = 'tunde_bello';

-- Check Ada's account balance to confirm the attempted balance reduction was rolled back
SELECT
    account_number,
    balance
FROM public.account
WHERE account_number = '2000000001';