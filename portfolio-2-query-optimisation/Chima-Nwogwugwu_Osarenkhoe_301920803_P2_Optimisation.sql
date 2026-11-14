-- Create a separate schema for the performance experiment.
-- This keeps the benchmark data separate from the original banking tables.

CREATE SCHEMA p2_benchmark;

-- Generate 100,000 fictional banking transaction records.
-- These records are only for testing query performance.

CREATE TABLE p2_benchmark.transaction_history AS
SELECT
    g AS transaction_id,
    'TXN' || LPAD(g::TEXT, 8, '0') AS transaction_reference,
    1000.00 + (g % 50000) AS amount,
    CASE
        WHEN g % 3 = 0 THEN 'Pending'
        WHEN g % 3 = 1 THEN 'Successful'
        ELSE 'Failed'
    END AS transaction_status,
    TIMESTAMPTZ '2000-01-01 00:00:00+00'
        + g * INTERVAL '1 hour' AS transaction_date
FROM generate_series(1, 100000) AS g;

-- Collect table statistics to help PostgreSQL choose an execution plan.
ANALYZE p2_benchmark.transaction_history;

-- Confirm that 100,000 records were created. Result is 100000
SELECT COUNT(*) AS total_test_transactions
FROM p2_benchmark.transaction_history;


-- Count transactions recorded on 1 January 2005.
-- The query includes the start of the day but excludes the next day. Result is 24

SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE transaction_date >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND transaction_date < TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- BEFORE INDEX: Check how PostgreSQL executes the date-range query.
-- EXPLAIN ANALYZE executes the query and reports its actual performance.
-- BUFFERS shows information about database blocks accessed.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE transaction_date >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND transaction_date < TIMESTAMPTZ '2005-01-02 00:00:00+00';

-- Create an index on transaction_date.
-- This may help PostgreSQL locate transactions within a date range
-- without scanning every record in the table.

CREATE INDEX transaction_history_date_idx
ON p2_benchmark.transaction_history (transaction_date);

-- Update the table statistics after creating the index.
ANALYZE p2_benchmark.transaction_history;

-- AFTER INDEX: Run exactly the same query used before creating the index.
-- This allows us to compare the execution plans fairly.

EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) AS transactions_on_day
FROM p2_benchmark.transaction_history
WHERE transaction_date >= TIMESTAMPTZ '2005-01-01 00:00:00+00'
  AND transaction_date < TIMESTAMPTZ '2005-01-02 00:00:00+00';

