# Portfolio 1 Database Design and Modelling

## Case study
A Digital banking Platform that enables customers to open accounts, manage their bank accounts, transfer funds to other accounts, save beneficiaries and view transaction history.

## Users
Customers create accounts, login to their account, manage accounts, transfer funds, save beneficiary and view transaction history. The bank can manage customer accounts and monitor transactions.

## Main operations
Create a customer account, login to account, transfer funds, make payment, view transaction history, save, view or remove beneficiary.

## Business rules
1. Each customer must have a unique customer ID, bank account number and username
2. A customer can have only one bank account
3. A customer must be of age 18 years to create an account.
4. Customer must complete identity verification before their account is activated
5. A customer must have sufficient funds (funds greater than proposed transfer) before initiating a transfer.
6. Every transaction must have a unique transaction reference
7. Every account can have multiple transactions.
8. A customer can register multiple beneficiaries.
9. A customer can only access their account and transaction history.
10. Every transaction must have a defined status of either Pending, Successful or Failed.

## Scope
In-scope: customer creation and account management, customer authentication, funds transfer between bank accounts, beneficiary management, transaction recording and history.
Out-of-scope: bill/airtime payment, transaction reversal.

## Design and implementation files

| File | Contents |
| --- | --- |
| [Design](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_Design.md) | Entities, attributes, keys and relationships. |
| [ER diagram](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_ERDiagram.md) | The five tables and their relationships. |
| [Normalisation](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_Normalisation.md) | Example tables showing 1NF, 2NF and 3NF. |
| [Schema](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_Schema.sql) | Table definitions, keys and constraints. |
| [Sample records](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_SampleData.sql) | Fictional customers, accounts, app user, beneficiary and bank transactions] |
| [Constraint tests](Chima-Nwogwugwu_Osarenkhoe_301920803_P1_ConstraintTest.sql) | Invalid inserts and the final count query. |
| [Screenshots](screenshots/) | Saved commands and results. |


## Implementation

The database runs on PostgreSQL in GitHub Codespaces. Its name is digital_banking_portfolio. It contains customers, accounts, app user, beneficiary and bank transactions. Each table has a primary key. Foreign keys connect accounts to customers and app users, app users to beneficiary and bank transactions.

Customer IDs, email addresses, phone numbers and BVNs are unique. Account numbers, usernames and transaction references are also unique. The database constraints reject invalid records, including transactions with non-positive amounts and accounts with negative balances. Foreign key constraints ensure that accounts, customers and transactions reference existing records. The schema and sample records were committed before the invalid records were tested separately.

## Test results

The invalid records tested included duplicate customer details, duplicate account numbers, duplicate usernames and transaction references, references to nonexistent customers or accounts, and transactions with invalid amounts. These were rejected by the database constraints where the corresponding checks had been implemented.

The final record counts should reflect the customer, account, app_user, beneficiary and bank_transaction records successfully inserted. The failed inserts will not have added any rows.

Some business rules, such as verifying that a customer has completed KYC before account activation, checking that a customer is at least 18, ensuring sufficient funds before a transfer, and completing transfers atomically, require additional application or transaction logic. 

Reference: [PostgreSQL constraints](https://www.postgresql.org/docs/16/ddl-constraints.html).