-- SampleData.sql
-- Fictional records for the Digital Banking Platform

BEGIN;

-- Insert customers
INSERT INTO public.customer
    (first_name, last_name, date_of_birth, email, phone_number, bvn, kyc_status, created_at)
VALUES
    ('Ada', 'Okafor', '1995-04-12', 'ada.okafor@example.com', '08030000001', '10000000001', 'Verified', '2026-01-10 09:00:00+01'),
    ('Tunde', 'Bello', '1990-08-21', 'tunde.bello@example.com', '08030000002', '10000000002', 'Pending', '2026-01-11 10:00:00+01'),
    ('Zuri', 'James', '2000-02-15', 'zuri.james@example.com', '08030000003', '10000000003', 'Verified', '2026-01-12 11:00:00+01'),
    ('Musa', 'Adeyemi', '1988-11-03', 'musa.adeyemi@example.com', '08030000004', '10000000004', 'Pending', '2026-01-13 12:00:00+01');

-- Insert accounts for the first three customers
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
SELECT
    c.customer_id,
    v.account_number,
    v.account_type,
    v.balance,
    v.currency,
    v.account_status,
    v.created_at
FROM (VALUES
    ('ada.okafor@example.com', '2000000001', 'Savings', 150000.00::NUMERIC(19,4), 'NGN', 'Active', '2026-01-10 09:30:00+01'::TIMESTAMPTZ),
    ('tunde.bello@example.com', '2000000002', 'Current', 75000.00::NUMERIC(19,4), 'NGN', 'Pending', '2026-01-11 10:30:00+01'::TIMESTAMPTZ),
    ('zuri.james@example.com', '2000000003', 'Savings', 200000.00::NUMERIC(19,4), 'NGN', 'Active', '2026-01-12 11:30:00+01'::TIMESTAMPTZ)
) AS v(email, account_number, account_type, balance, currency, account_status, created_at)
JOIN public.customer c ON c.email = v.email;

-- Insert login profiles
INSERT INTO public.app_user
    (customer_id, username, password_hash, mfa_status, last_login)
SELECT
    c.customer_id,
    v.username,
    v.password_hash,
    v.mfa_status,
    v.last_login
FROM (VALUES
    ('ada.okafor@example.com', 'ada_okafor', 'fictional_hash_ada', TRUE, '2026-11-10 08:00:00+01'::TIMESTAMPTZ),
    ('tunde.bello@example.com', 'tunde_bello', 'fictional_hash_tunde', FALSE, NULL::TIMESTAMPTZ),
    ('zuri.james@example.com', 'zuri_james', 'fictional_hash_zuri', TRUE, '2026-11-11 14:00:00+01'::TIMESTAMPTZ)
) AS v(email, username, password_hash, mfa_status, last_login)
JOIN public.customer c ON c.email = v.email;

-- Insert saved beneficiaries
INSERT INTO public.beneficiary
    (customer_id, beneficiary_name, account_number, bank_name, created_at)
SELECT
    c.customer_id,
    v.beneficiary_name,
    v.account_number,
    v.bank_name,
    v.created_at
FROM (VALUES
    ('ada.okafor@example.com', 'Tunde Bello', '3000000001', 'Example Bank', '2026-02-01 09:00:00+01'::TIMESTAMPTZ),
    ('ada.okafor@example.com', 'Zuri James', '3000000002', 'Sample Bank', '2026-02-02 09:00:00+01'::TIMESTAMPTZ),
    ('tunde.bello@example.com', 'Ada Okafor', '3000000003', 'Example Bank', '2026-02-03 09:00:00+01'::TIMESTAMPTZ)
) AS v(email, beneficiary_name, account_number, bank_name, created_at)
JOIN public.customer c ON c.email = v.email;

-- Insert transfers with different statuses
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount, bank_transaction_type, bank_transaction_status, bank_transaction_date, description)
SELECT
    v.reference,
    sender.account_id,
    receiver.account_id,
    v.amount,
    v.transaction_type,
    v.transaction_status,
    v.transaction_date,
    v.description
FROM (VALUES
    ('TXN-2026-0001', '2000000001', '2000000003', 5000.00::NUMERIC(19,4), 'Transfer', 'Successful', '2026-02-10 10:00:00+01'::TIMESTAMPTZ, 'Transfer to Zuri'),
    ('TXN-2026-0002', '2000000003', '2000000001', 2500.00::NUMERIC(19,4), 'Transfer', 'Pending', '2026-02-11 11:00:00+01'::TIMESTAMPTZ, 'Transfer to Ada'),
    ('TXN-2026-0003', '2000000001', '2000000003', 1000.00::NUMERIC(19,4), 'Transfer', 'Failed', '2026-02-12 12:00:00+01'::TIMESTAMPTZ, 'Failed transfer example')
) AS v(reference, sender_number, receiver_number, amount, transaction_type, transaction_status, transaction_date, description)
JOIN public.account sender ON sender.account_number = v.sender_number
JOIN public.account receiver ON receiver.account_number = v.receiver_number;

COMMIT;