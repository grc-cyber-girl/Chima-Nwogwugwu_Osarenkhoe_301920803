# Portfolio 3 Transactions and Concurrency

## Commit and rollback

A transaction was used to update Tunde Bello's `last_login` value. The update affected one row and was saved using `COMMIT`. A repeated update returned `UPDATE 0` because the login date was no longer NULL. For the rollback test, Ada Okafor's account balance was reduced by ₦1,000 before an attempt to set it to a negative value was rejected by the `chk_account_balance` constraint. `ROLLBACK` undid the earlier balance reduction. The final checks confirmed that Tunde's committed login date remained saved and Ada's balance was restored to ₦150,000.

## Isolation and concurrency control

Two independent PostgreSQL sessions were used to test concurrent withdrawals from account `2000000001`, with both sessions using `READ COMMITTED` isolation. Session A attempted to withdraw ₦30,000 and held the account row lock while its transaction was uncommitted. Session B attempted the same withdrawal and waited for Session A to finish. After Session A committed, Session B's update returned `UPDATE 0` because the remaining balance was only ₦20,000. The final balance was ₦20,000, confirming that only one withdrawal succeeded. The conditional balance update and PostgreSQL row locking controlled the competing updates; this exercise did not implement a complete transfer between accounts.

## Conclusion

The exercises demonstrated how PostgreSQL transactions can save valid changes using `COMMIT` and undo unsuccessful operations using `ROLLBACK`. The two-session test also showed how `READ COMMITTED`, row locking and a conditional update help prevent concurrent withdrawals from exceeding the available account balance. These tests demonstrate basic transaction control and concurrency handling, but a complete banking transfer would also require the debit, credit and transaction record to be handled atomically.

## Files

| File | Description |
|---|---|
| [Chima-Nwogwugwu_Osarenkhoe_301920803_P3_Transactions.sql](Chima-Nwogwugwu_Osarenkhoe_301920803_P3_Transactions.sql) | Starting-data checks, commit and rollback exercises, and final verification queries. |
| [Chima-Nwogwugwu_Osarenkhoe_301920803_P3_SessionA.sql](Chima-Nwogwugwu_Osarenkhoe_301920803_P3_SessionA.sql) | Two-session concurrency test using READ COMMITTED isolation. |
| [Chima-Nwogwugwu_Osarenkhoe_301920803_P3_SessionB.sql](Chima-Nwogwugwu_Osarenkhoe_301920803_P3_SessionB.sql) | Two-session concurrency test using READ COMMITTED isolation. |
| [screenshots/](screenshots/) | Screenshots showing the transaction and concurrency test results. |

Screenshots:
- [Commit and rollback](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P3_CommitRollback.png)
- [Final commit and rollback checks](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P3_TestCommitRollback.png)
- [SessionB Waiting](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P3_SessionBWaiting.png)
- [Concurrency test result](screenshots/Chima-Nwogwugwu_Osarenkhoe_301920803_P3_ConcurrencyResult.png)


## References

- [PostgreSQL Documentation – Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html)
- [PostgreSQL Documentation – Transaction Isolation](https://www.postgresql.org/docs/current/transaction-iso.html)
- [PostgreSQL Documentation – Explicit Locking](https://www.postgresql.org/docs/current/explicit-locking.html)
- [PostgreSQL Documentation – Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)