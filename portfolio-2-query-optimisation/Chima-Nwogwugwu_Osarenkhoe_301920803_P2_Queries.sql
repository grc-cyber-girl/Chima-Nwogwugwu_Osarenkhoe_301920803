-- P2 Queries
-- These queries answer questions about how customers use their bank accounts

--Q1: Find all pending transactions
--Purpose: This query helps the bank identify transactions that have not yet been completed.
SELECT
    bank_transaction_reference,
    bank_transaction_type,
    amount,
    bank_transaction_status,
    bank_transaction_date
FROM public.bank_transaction
WHERE bank_transaction_status = 'Pending'
ORDER BY bank_transaction_date DESC;

--Q2: Finds accounts that have never been used for transactions
--Purpose: This query identifies bank accounts that have neither sent nor received a transaction.
SELECT
    a.account_number,
    a.account_type,
    a.balance,
    a.currency,
    c.first_name,
    c.last_name
FROM public.account a
JOIN public.customer c
    ON a.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.bank_transaction bt
    WHERE bt.sender_account_id = a.account_id
       OR bt.receiver_account_id = a.account_id
)
ORDER BY a.account_number;

--Q3: Count the total number of transaction for each customer
--Purpose: This query helps the bank understand how many transactions each customer has been involved in.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT bt.bank_transaction_id) AS total_transactions
FROM public.customer c
LEFT JOIN public.account a
    ON c.customer_id = a.customer_id
LEFT JOIN public.bank_transaction bt
    ON a.account_id = bt.sender_account_id
    OR a.account_id = bt.receiver_account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY c.last_name, c.first_name;