-- ConstraintTests.sql

-- TEST 1: Required customer field
-- Expected error: NOT NULL violation on first_name.
INSERT INTO public.customer
    (first_name, last_name, date_of_birth, email, phone_number, bvn, kyc_status, created_at)
VALUES
    (NULL, 'Test', '1995-05-10', 'required.test@example.com', '08039990001', '90000000001', 'Verified', CURRENT_TIMESTAMP);

-- TEST 2: Unique customer email
-- Expected error: Duplicate email violates the UNIQUE constraint.
INSERT INTO public.customer
    (first_name, last_name, date_of_birth, email, phone_number, bvn, kyc_status, created_at)
VALUES
    ('Test', 'Email', '1995-05-10', 'ada.okafor@example.com', '08039990002', '90000000002', 'Verified', CURRENT_TIMESTAMP);

-- TEST 3: Unique customer phone number
-- Expected error: Duplicate phone_number violates the UNIQUE constraint.
INSERT INTO public.customer
    (first_name, last_name, date_of_birth, email, phone_number, bvn, kyc_status, created_at)
VALUES
    ('Test', 'Phone', '1995-05-10', 'phone.test@example.com', '08030000001', '90000000003', 'Verified', CURRENT_TIMESTAMP);

-- TEST 4: Unique customer BVN
-- Expected error: Duplicate BVN violates the UNIQUE constraint.
INSERT INTO public.customer
    (first_name, last_name, date_of_birth, email, phone_number, bvn, kyc_status, created_at)
VALUES
    ('Test', 'BVN', '1995-05-10', 'bvn.test@example.com', '08039990004', '10000000001', 'Verified', CURRENT_TIMESTAMP);

-- TEST 5: Account customer_id must be unique
-- Expected error: Duplicate customer_id violates the UNIQUE constraint.
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'ada.okafor@example.com'),
     '2999999001', 'Savings', 1000.00, 'NGN', 'Active', CURRENT_TIMESTAMP);

-- TEST 6: Unique account number
-- Expected error: Duplicate account_number violates the UNIQUE constraint.
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     '2000000001', 'Savings', 1000.00, 'NGN', 'Active', CURRENT_TIMESTAMP);

-- TEST 7: Account foreign key
-- Expected error: Foreign key violation because the customer does not exist.
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
VALUES
    (-999999, '2999999002', 'Savings', 1000.00, 'NGN', 'Active', CURRENT_TIMESTAMP);

-- TEST 8: Account balance cannot be negative
-- Expected error: CHECK constraint violation on chk_account_balance.
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     '2999999003', 'Savings', -100.00, 'NGN', 'Active', CURRENT_TIMESTAMP);

-- TEST 9: Required account field
-- Expected error: NOT NULL violation on currency.
INSERT INTO public.account
    (customer_id, account_number, account_type, balance, currency, account_status, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     '2999999004', 'Savings', 1000.00, NULL, 'Active', CURRENT_TIMESTAMP);

-- TEST 10: app_user customer_id must be unique
-- Expected error: Duplicate customer_id violates the UNIQUE constraint.
INSERT INTO public.app_user
    (customer_id, username, password_hash, mfa_status)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'ada.okafor@example.com'),
     'ada_second_login', 'fictional_test_hash', TRUE);

-- TEST 11: Unique username
-- Expected error: Duplicate username violates the UNIQUE constraint.
INSERT INTO public.app_user
    (customer_id, username, password_hash, mfa_status)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     'ada_okafor', 'fictional_test_hash', TRUE);

-- TEST 12: app_user foreign key
-- Expected error: Foreign key violation because the customer does not exist.
INSERT INTO public.app_user
    (customer_id, username, password_hash, mfa_status)
VALUES
    (-999999, 'missing_customer_user', 'fictional_test_hash', TRUE);

-- TEST 13: Required app_user field
-- Expected error: NOT NULL violation on password_hash.
INSERT INTO public.app_user
    (customer_id, username, password_hash, mfa_status)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     'musa_test_user', NULL, TRUE);

-- TEST 14: Beneficiary foreign key
-- Expected error: Foreign key violation because the customer does not exist.
INSERT INTO public.beneficiary
    (customer_id, beneficiary_name, account_number, bank_name, created_at)
VALUES
    (-999999, 'Test Recipient', '3999999001', 'Test Bank', CURRENT_TIMESTAMP);

-- TEST 15: Required beneficiary field
-- Expected error: NOT NULL violation on bank_name.
INSERT INTO public.beneficiary
    (customer_id, beneficiary_name, account_number, bank_name, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'musa.adeyemi@example.com'),
     'Test Recipient', '3999999002', NULL, CURRENT_TIMESTAMP);

-- TEST 16: Duplicate beneficiary for the same customer and bank account
-- Expected error: UNIQUE violation on uq_beneficiary_customer_account.
INSERT INTO public.beneficiary
    (customer_id, beneficiary_name, account_number, bank_name, created_at)
VALUES
    ((SELECT customer_id FROM public.customer WHERE email = 'ada.okafor@example.com'),
     'Tunde Bello', '3000000001', 'Example Bank', CURRENT_TIMESTAMP);

-- TEST 17: Transaction reference must be unique
-- Expected error: Duplicate reference violates the UNIQUE constraint.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-2026-0001',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     (SELECT account_id FROM public.account WHERE account_number = '2000000003'),
     1000.00, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- TEST 18: Sender account foreign key
-- Expected error: Foreign key violation because the sender account does not exist.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-001', -999999,
     (SELECT account_id FROM public.account WHERE account_number = '2000000003'),
     1000.00, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- TEST 19: Receiver account foreign key
-- Expected error: Foreign key violation because the receiver account does not exist.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-002',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     -999999, 1000.00, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- TEST 20: Transaction amount must be greater than zero
-- Expected error: CHECK constraint violation on chk_transaction_amount.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-003',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     (SELECT account_id FROM public.account WHERE account_number = '2000000003'),
     0.00, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- TEST 21: Sender and receiver must be different
-- Expected error: CHECK constraint violation on chk_transaction_different_accounts.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-004',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     1000.00, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- TEST 22: Transaction status must be valid
-- Expected error: CHECK constraint violation on chk_transaction_status.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-005',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     (SELECT account_id FROM public.account WHERE account_number = '2000000003'),
     1000.00, 'Transfer', 'Processing', CURRENT_TIMESTAMP);

-- TEST 23: Required transaction field
-- Expected error: NOT NULL violation on amount.
INSERT INTO public.bank_transaction
    (bank_transaction_reference, sender_account_id, receiver_account_id, amount,
     bank_transaction_type, bank_transaction_status, bank_transaction_date)
VALUES
    ('TXN-TEST-006',
     (SELECT account_id FROM public.account WHERE account_number = '2000000001'),
     (SELECT account_id FROM public.account WHERE account_number = '2000000003'),
     NULL, 'Transfer', 'Pending', CURRENT_TIMESTAMP);

-- To check the final row counts after all invalid inserts fail.
-- Expected counts: customer 4, account 3, app_user 3,
-- beneficiary 3, bank_transaction 3.

SELECT 'customer' AS table_name, COUNT(*) AS row_count
FROM public.customer

UNION ALL

SELECT 'account', COUNT(*)
FROM public.account

UNION ALL

SELECT 'app_user', COUNT(*)
FROM public.app_user

UNION ALL

SELECT 'beneficiary', COUNT(*)
FROM public.beneficiary

UNION ALL

SELECT 'bank_transaction', COUNT(*)
FROM public.bank_transaction

ORDER BY table_name;
