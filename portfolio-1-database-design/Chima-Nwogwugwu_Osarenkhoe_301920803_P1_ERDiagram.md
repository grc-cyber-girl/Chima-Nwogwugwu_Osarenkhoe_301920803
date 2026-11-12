
# Digital Banking Platform ER Diagram

## 1. Entity Relationship Diagram

The following ER diagram represents the five entities in the digital banking platform, their attributes, primary keys, foreign keys, unique fields and relationships.

```mermaid
erDiagram
    direction LR

    customer {
        BIGINT customer_id PK
        VARCHAR(100) first_name
        VARCHAR(100) last_name
        DATE date_of_birth
        VARCHAR(254) email UK
        VARCHAR(20) phone_number UK
        VARCHAR(11) bvn UK
        VARCHAR(20) kyc_status
        TIMESTAMPTZ created_at
    }

    account {
        BIGINT account_id PK
        BIGINT customer_id FK, UK
        VARCHAR(20) account_number UK
        VARCHAR(20) account_type
        NUMERIC(19,4) balance
        CHAR(3) currency
        VARCHAR(20) account_status
        TIMESTAMPTZ created_at
    }

    app_user {
        BIGINT app_user_id PK
        BIGINT customer_id FK, UK
        VARCHAR(50) username UK
        VARCHAR(255) password_hash
        BOOLEAN mfa_status
        TIMESTAMPTZ last_login
    }

    bank_transaction {
        BIGINT bank_transaction_id PK
        VARCHAR(50) bank_transaction_reference UK
        BIGINT sender_account_id FK
        BIGINT receiver_account_id FK
        NUMERIC(19,4) amount
        VARCHAR(20) bank_transaction_type
        VARCHAR(20) bank_transaction_status
        TIMESTAMPTZ bank_transaction_date
        VARCHAR(255) description
    }

    beneficiary {
        BIGINT beneficiary_id PK
        BIGINT customer_id FK
        VARCHAR(120) beneficiary_name
        VARCHAR(20) account_number
        VARCHAR(100) bank_name
        TIMESTAMPTZ created_at
    }

    customer ||--|| account : owns
    customer ||--|| app_user : has
    customer ||--o{ beneficiary : saves
    account ||--o{ bank_transaction : sends
    account ||--o{ bank_transaction : receives
```

## 2. Explanation of Keys

- **PK (Primary Key):** Uniquely identifies each record in a table. For example, `customer_id` uniquely identifies each customer.
- **FK (Foreign Key):** Links one table to another by referencing its primary key. For example, `customer_id` in the Account table references `customer_id` in the Customer table.
- **UK (Unique Key):** Ensures that a field does not contain duplicate values. For example, each customer must have a unique email address and BVN.

## 3. Explanation of Relationship Symbols

The symbols in the ER diagram represent the number of records that can be associated with another record.

| Symbol | Meaning |
|---|---|
| `||` | Exactly one |
| `o|` | Zero or one |
| `o{` | Zero or many |
| `|{` | One or many |

The relationships in the digital banking platform are:

1. **Customer – Account (1:1):** Each customer owns exactly one account, and each account belongs to exactly one customer.
2. **Customer – App_User (1:1):** Each customer has exactly one login profile.
3. **Customer – Beneficiary (1:M):** A customer can save zero or more beneficiaries, while each beneficiary belongs to exactly one customer.
4. **Account – Bank_Transaction (Sender) (1:M):** An account can initiate zero or more transactions.
5. **Account – Bank_Transaction (Receiver) (1:M):** An account can receive zero or more transactions.

## 4. Example

Bolaji transfers ₦5,000 to Fumto.

- Bolaji's account is recorded as the `sender_account_id`.
- Fumto's account is recorded as the `receiver_account_id`.
- The transaction receives a unique `bank_transaction_reference`.
- The transaction amount is recorded as 5,000.
- The transaction status records whether the transfer is Pending, Successful or Failed.

Both account IDs reference existing records in the Account table. This allows the database to identify the sender and receiver of the transfer.

## 5. Optional Fields

The following fields are optional and can contain `NULL` values:

| Entity | Optional field | Reason |
|---|---|---|
| app_user | last_login | A newly registered customer may not have logged in yet. |
| bank_transaction | description | A transaction may not have a description. |

All other attributes are required according to the proposed design.

## 6. Additional Constraints and Transaction Logic

Some business rules require additional validation beyond primary keys, foreign keys and unique constraints.

- **Age restriction:** `date_of_birth` must indicate that the customer is at least 18 years old. This requires application validation or a database trigger.
- **KYC verification:** An account cannot be activated until the customer's KYC status is verified.
- **Sufficient balance:** A customer must have enough available funds before a transfer is processed.
- **Positive transaction amount:** The transaction amount must be greater than zero.
- **Different accounts:** The sender and receiver account IDs must not be the same.
- **Non-negative balance:** An account balance must not fall below zero.
- **Beneficiary uniqueness:** A customer cannot register the same bank account and bank combination more than once.
- **Transaction status:** The transaction status must be Pending, Successful or Failed.
- **Successful transfers:** A transaction cannot be marked Successful unless the corresponding debit and credit are completed.
- **Customer access:** Customers can only access their own accounts and transaction history. This requires application-level authorisation and access controls.

Fund transfers require transaction logic to ensure that the sender's account is debited and the receiver's account is credited together. Both operations either succeed or fail to maintain data consistency.

## 7. Summary

The ER diagram represents five entities: Customer, Account, App_User, Bank_Transaction and Beneficiary. It shows how their attributes are structured, how primary and foreign keys connect the tables, and how the relationships support the operations of the digital banking platform.

The design provides a foundation for implementing a relational database while maintaining data integrity, uniqueness and consistency.
