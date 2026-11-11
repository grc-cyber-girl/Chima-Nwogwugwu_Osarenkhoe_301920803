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