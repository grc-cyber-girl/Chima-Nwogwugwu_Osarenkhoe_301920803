
# Portfolio 2 Query Processing and Optimisation

## Queries and results

Three SQL queries were executed against the digital banking platform database:

1. **Pending transactions:** Retrieved transactions with a Pending status. One record was returned: transaction `TXN-2026-0002`, a Transfer of ₦2,500.
2. **Accounts without transactions:** Identified accounts that have neither sent nor received transactions. One record was returned: account `2000000002`, a Current account belonging to Tunde Bello, with a balance of ₦75,000.
3. **Transactions per customer:** Counted the transactions associated with each customer. Four customers were returned: Musa Adeyemi (0), Tunde Bello (0), Zuri James (3) and Ada Okafor (3).

## Index comparison

A separate benchmark table, `p2_benchmark.transaction_history`, was created with 100,000 synthetic transaction records. The same date-range count query was executed before and after adding an index to the `transaction_date` column.

The index created was `transaction_history_date_idx`.

| Measurement | Before index | After index |
| --- | --- | --- |
| Scan type | Sequential Scan | Index Only Scan |
| Three execution times (ms) | 6.880, 6.942, 8.795 | 0.047, 0.060, 0.047 |
| Median time (ms) | 6.942 | 0.047 |
| Shared buffer hits, third run | 896 | 3 |

## Performance analysis

Before indexing, PostgreSQL used a Sequential Scan, checking all 100,000 records and removing 99,976 records that did not match the date filter. After creating the index, PostgreSQL used an Index Only Scan with `transaction_history_date_idx`. The median execution time decreased from 6.942 ms to 0.047 ms, while shared buffer hits decreased from 896 to 3 in the third measured run. This demonstrates improved performance for this particular test query. However, the benchmark uses synthetic data in a specific environment, so the results may differ with larger production workloads, different hardware or cache conditions. Indexes also require additional storage and can increase the time needed to insert, update or delete records because the index must be maintained.

## Files

| File | Description |
| --- | --- |
| [P2_Queries.sql](P2_Queries.sql) | SQL queries for the digital banking database. |
| [Chima-Nwogwugwu_Osarenkhoe_301920803_P2_Optimisation.sql](Chima-Nwogwugwu_Osarenkhoe_301920803_P2_Optimisation.sql) | Benchmark setup, transaction count query, execution plans and index creation. |
| [screenshots/](screenshots/) | Folder containing query results and before-and-after execution plan screenshots. |

Screenshots:
- [Query Result 1](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P2_QueryResult1.png)
- [Query Result 2](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P2_QueryResult2.png)
- [Before Index](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P2_BeforeIndex.png)
- [After Index](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P2_AfterIndex.png)

## Reference
- [PostgreSQL Documentation – Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html) – Understanding execution plans and EXPLAIN ANALYZE.
- [PostgreSQL Documentation – ANALYZE](https://www.postgresql.org/docs/current/sql-analyze.html) – Collecting table statistics to help PostgreSQL choose execution plans.
- [PostgreSQL Documentation – Index-Only Scans and Covering Indexes](https://www.postgresql.org/docs/current/indexes-index-only-scans.html) – Understanding index-only scans.