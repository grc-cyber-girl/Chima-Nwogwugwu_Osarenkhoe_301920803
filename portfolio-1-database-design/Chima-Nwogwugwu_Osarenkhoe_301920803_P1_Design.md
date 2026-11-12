## Digital Banking Platform
Five entities were chosen for my digital banking platform:

- **Entity:** something the databse keeps tracks of. 
- **Attribute:** a describes the entity.
- **Primary key (PK):** the ID for one record.
- **Foreign key (FK):** an ID linking two tables. 
- **Relationship:** how records connect.

### Entities

| Entity | Information stored |
| --- | --- |
| customer | a registered customer|
| account | a bank account owned by a registered customer |
| app_user | a customer's loginand authentication details |
| bank_transaction | a record of a fund transfer betweeen bank accounts |
| beneficiary | a saved recipient's banking details linked to a customer  |

### Attributes and keys
An automatically generated ID is used for each record. In the tables below, **unique** means no repeated values. **Required** means the value cannot be `NULL` (missing); checking for blank text is a separate rule.

| Entity | Attributes and proposed PostgreSQL types | Keys and required values |
| --- | --- | --- |
| customer | customer_id BIGINT; first_name VARCHAR(100); last_name VARCHAR(100); date_of_birth DATE; email VARCHAR(254); phone_number VARCHAR(20); bvn VARCHAR(11); kyc_status VARCHAR(20); created_at TIMESTAMPTZ | PK: customer_id. Unique: email, phone_number and bvn separately. All required. |
| account | account_id BIGINT; customer_id BIGINT; account_number VARCHAR(20); account_type VARCHAR(20); balance NUMERIC(19,4); currency CHAR(3); account_status VARCHAR(20); created_at TIMESTAMPTZ | PK: account_id. FK: customer_id → customer.customer_id. Unique: customer_id and account_number. All required. |
| app_user | app_user_id BIGINT; customer_id BIGINT; username VARCHAR(50); password_hash VARCHAR(255); mfa_status BOOLEAN; last_login TIMESTAMPTZ |PK: app_user_id. FK: customer_id → customer.customer_id. Unique: customer_id and username. Required except last_login. |
| bank_transaction | bank_transaction_id BIGINT; bank_transaction_reference VARCHAR(50); sender_account_id BIGINT; receiver_account_id BIGINT; amount NUMERIC(19,4); bank_transaction_type VARCHAR(20); bank_transaction_status VARCHAR(20); bank_transaction_date TIMESTAMPTZ; description VARCHAR(255) | PK: bank_transaction_id. FKs: sender_account_id → account.account_id; receiver_account_id → account.account_id. Unique: bank_transaction_reference. All required except description. |
| beneficiary | beneficiary_id BIGINT; customer_id BIGINT; beneficiary_name VARCHAR(120); account_number VARCHAR(20); bank_name VARCHAR(100); created_at TIMESTAMPTZ | PK: beneficiary_id. FK: customer_id → customer.customer_id. All required. |

`BIGINT` holds whole numbers, such as automatically generated IDs. `VARCHAR(n)` holds text up to the specified number of characters. `NUMERIC(19,4)` holds precise decimal values suitable for monetary amounts. `BOOLEAN` hols true or false. `DATE` hols a calendar date, while `TIMESTAMPTZ` holds a date and time.  

**Design assumptions:**
- Each customer can own only one bank account.
- Each customer has one login profile.
- Each transaction represents a transfer between two accounts on the platform.
- A beneficiary is saved by a customer and can be used as a transfer recipient.
- Account balances are maintained in the account's specified currency.
- BVN is stored as text rather than a number because it is an identifier, not a value used for arithmetic.

### Relationships

| Tables linked | Relationship | Meaning |
| --- | --- | --- |
| customer → account | One to one (1:1) | Each customer owns exactly one account, and each account belongs to exactly one customer. |
| customer → app_user | One to one (1:1) | Each customer has one login profile, and each login profile belongs to one customer. |
| customer → beneficiary | One to many (1:M) | A customer can save zero or more beneficiaries; each beneficiary belongs to one customer. |
| account → bank_transaction (sender) | One to many (1:M) | An account can initiate multiple transfers. |
| account → bank_transaction (receiver) | One to many (1:M) | An account can receive multiple transfers. |

For example, Customer A (Bolaji) can transfer ₦5,000 to Customer B (Fumto). Bolaji's account is recorded as the sender, while Fumto's account is recorded as the receiver.

#### Business rules and constraints

- **1. Rule 1:** Every customer must have a unique customer ID, email, phone number and BVN. Account numbers and usernames must also be unique.
- **2. Rule 2:** Each customer can own only one bank account. This is enforced using a unique constraint on customer_id in the Account table.
- **3. Rule 3:** Customers must be at least 18 years old. This requires application validation or a database trigger.
- **4. Rule 4:** An account cannot be activated until the customer's KYC status is verified. This requires application or database transaction logic.
- **5. Rule 5:** A customer must have sufficient available funds before initiating a transfer. This requires transaction processing logic to validate the balance before debiting the account.
- **6. Rule 6:** Every transaction must have a unique transaction reference. This is enforced using a UNIQUE constraint.
- **7. Rule 7:** An account can have multiple transactions, whether as a sender or receiver. This is supported by the two foreign keys in the Transaction table.
- **8. Rule 8:** A customer can register multiple beneficiaries. This is supported by the foreign key in the Beneficiary table.
- **9. Rule 9:** Customers can only access their own accounts and transaction history. This requires application-level authorisation and access controls.
- **10. Rule 10:** Every transaction must have a status of Pending, Successful or Failed. This can be enforced using a CHECK constraint.

The following integrity constraints will also be introduced:
1. Transaction amount must be greater than zero.
2. Sender and receiver accounts must be different.
3. Both sender and receiver accounts must exist.
4. Account balance must not be negative.
5. A beneficiary should not be registered more than once by the same customer for the same bank account.
6. A transaction must not be marked Successful unless the corresponding debit and credit have been completed