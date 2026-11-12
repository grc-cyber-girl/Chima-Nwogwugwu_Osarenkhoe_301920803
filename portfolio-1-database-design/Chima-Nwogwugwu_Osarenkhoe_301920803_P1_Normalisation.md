
# Digital Banking Platform Normalisation

Normalisation separates information into related tables to reduce repeated details and avoid inconsistent updates. It helps ensure that each piece of information is stored in the appropriate table.

The digital banking platform uses five entities: customer, account, app_user, bank_transaction and beneficiary.

The same two fictional customers, Bolaji and Fumto, are used throughout the examples. Only the fields needed to explain normalisation are shown; the final design retains all the attributes from the database design document.

## Starting customer and banking records

The starting table combines customer details, account information, login details and transaction records.

| customer_id | customer_name | email | account_number | username | transactions |
|---|---|---|---|---|---|
| 1 | Bolaji | bolaji@example.com | 0123456789 | bolaji01 | TR001: ₦5,000 sent to Fumto; TR002: ₦2,000 sent to Fumto |
| 2 | Fumto | fumto@example.com | 0987654321 | fumto01 | TR003: ₦3,000 received from Bolaji |

The transactions column contains multiple values in one cell. This makes it difficult to find an individual transaction, update its status or retrieve transaction history.

## 1NF: One value per cell

First Normal Form (1NF) requires each column to contain one value per cell. Repeating lists are removed, and each record represents one transaction.

### Customer transaction records

| transaction_id | customer_id | customer_name | email | account_number | username | amount | transaction_type |
|---|---|---|---|---|---|---|---|
| TR001 | 1 | Bolaji | bolaji@example.com | 0123456789 | bolaji01 | ₦5,000 | Transfer |
| TR002 | 1 | Bolaji | bolaji@example.com | 0123456789 | bolaji01 | ₦2,000 | Transfer |
| TR003 | 2 | Fumto | fumto@example.com | 0987654321 | fumto01 | ₦3,000 | Transfer |

**Key:** transaction_id uniquely identifies each transaction.

Each transaction now has its own row, so individual transactions can be recorded and retrieved.

However, customer details, email addresses and account numbers are repeated across transaction records. If Bolaji changes his email address, multiple rows may need updating.

This creates an **update anomaly**, which occurs when the same information must be changed in several places.

## 2NF: Remove partial dependencies

Second Normal Form (2NF) includes 1NF. It requires every non-key attribute to depend on the whole primary key, not just part of a combined key.

For this example, assume the starting transaction table uses a combined key of **(customer_id, transaction_id)**.

The following dependencies exist:

- customer_id determines customer_name, email, account_number and username.
- transaction_id determines amount and transaction_type.

The customer details depend only on customer_id, which is part of the combined key. They do not depend on the whole key.

These customer details therefore move into a separate Customer Details table.

### Customer details

Key: **customer_id**.

| customer_id | customer_name | email | account_number | username |
|---|---|---|---|---|
| 1 | Bolaji | bolaji@example.com | 0123456789 | bolaji01 |
| 2 | Fumto | fumto@example.com | 0987654321 | fumto01 |

### Transaction details

Key: **transaction_id**. customer_id is a foreign key referencing Customer Details.

| transaction_id | customer_id | amount | transaction_type |
|---|---|---|---|
| TR001 | 1 | ₦5,000 | Transfer |
| TR002 | 1 | ₦2,000 | Transfer |
| TR003 | 2 | ₦3,000 | Transfer |

The customer details are no longer repeated for every transaction. Updating Bolaji's email address now requires changing only one record.

However, customer information, account information and login information still sit together in the Customer Details table. These details describe different entities and are separated further in 3NF.

## 3NF: Remove transitive dependencies

Third Normal Form (3NF) includes 2NF. It requires non-key attributes to depend only on the primary key, not on another non-key attribute.

A **transitive dependency** occurs when one non-key field determines another non-key field.

In the Customer Details table:

- customer_id determines account_number and username.
- Account information belongs to the account entity.
- Login information belongs to the app_user entity.

These details move into separate tables.

### customer

Key: **customer_id**.

| customer_id | first_name | last_name | email |
|---|---|---|---|
| 1 | Bolaji | Adebayo | bolaji@example.com |
| 2 | Fumto | Okafor | fumto@example.com |

### account

Key: **account_id**. customer_id is a unique foreign key referencing customer.

| account_id | customer_id | account_number | balance |
|---|---|---|---|
| 101 | 1 | 0123456789 | ₦43,000 |
| 102 | 2 | 0987654321 | ₦28,000 |

### app_user

Key: **app_user_id**. customer_id is a unique foreign key referencing customer.

| app_user_id | customer_id | username | password_hash |
|---|---|---|---|
| 201 | 1 | bolaji01 | [hashed value] |
| 202 | 2 | fumto01 | [hashed value] |

### bank_transaction

Key: **bank_transaction_id**. sender_account_id and receiver_account_id are foreign keys referencing account.

| bank_transaction_id | reference | sender_account_id | receiver_account_id | amount | status |
|---|---|---|---|---|---|
| 301 | TR001 | 101 | 102 | ₦5,000 | Successful |
| 302 | TR002 | 101 | 102 | ₦2,000 | Successful |
| 303 | TR003 | 102 | 101 | ₦3,000 | Successful |

### beneficiary

Key: **beneficiary_id**. customer_id is a foreign key referencing customer.

| beneficiary_id | customer_id | beneficiary_name | account_number | bank_name |
|---|---|---|---|---|
| 401 | 1 | Fumto Okafor | 0987654321 | Example Bank |
| 402 | 2 | Bolaji Adebayo | 0123456789 | Example Bank |

Customer details, account information and login credentials now reside in their respective tables. The beneficiary table also keeps saved recipient details separately from customer records.

The foreign keys preserve the relationships between the tables. For example, account.customer_id links an account to its owner, while bank_transaction.sender_account_id and receiver_account_id link a transfer to the two accounts involved.

## Final normalised structure

The final database design contains five entities:

| Entity | Primary key | Foreign keys |
|---|---|---|
| customer | customer_id | None |
| account | account_id | customer_id |
| app_user | app_user_id | customer_id |
| bank_transaction | bank_transaction_id | sender_account_id, receiver_account_id |
| beneficiary | beneficiary_id | customer_id |

The final design uses automatically generated IDs as primary keys rather than the combined example key used during the 2NF explanation.

For example, bank_transaction_id uniquely identifies each transaction, while sender_account_id and receiver_account_id connect it to the relevant accounts.

Using an automatically generated ID is a design choice. An ID alone does not make a table 3NF; the non-key attributes must still depend on the key and not on other non-key attributes.

The complete design also retains the following fields, which are omitted from the example tables for readability:

| Entity | Additional fields retained |
|---|---|
| customer | date_of_birth, phone_number, bvn, kyc_status, created_at |
| account | account_type, currency, account_status, created_at |
| app_user | mfa_status, last_login |
| bank_transaction | bank_transaction_type, bank_transaction_date, description |
| beneficiary | created_at |

The final design retains the unique constraints, foreign keys and business rules from the database design document.

**Important:** Normalisation reduces unnecessary duplication and update problems, but it does not automatically enforce all business rules. For example, the platform still requires transaction logic to prevent negative balances, ensure sufficient funds and process transfers atomically. Unique constraints, CHECK constraints and application-level validation also remain necessary.

Overall, the database is organised into five related tables, with each entity holding information that belongs to it. This reduces repeated customer and account details while allowing the platform to retrieve connected information through primary and foreign keys.
