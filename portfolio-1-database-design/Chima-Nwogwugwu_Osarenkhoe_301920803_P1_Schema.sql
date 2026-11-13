
-- Digital Banking Platform

BEGIN;

-- Customer records
CREATE TABLE public.customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    bvn VARCHAR(11) NOT NULL UNIQUE,
    kyc_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

-- Bank accounts
CREATE TABLE public.account (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL UNIQUE,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL,
    balance NUMERIC(19,4) NOT NULL DEFAULT 0,
    currency CHAR(3) NOT NULL,
    account_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id),

    CONSTRAINT chk_account_balance
        CHECK (balance >= 0)
);

-- Customer login profiles
CREATE TABLE public.app_user (
    app_user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    mfa_status BOOLEAN NOT NULL,
    last_login TIMESTAMPTZ,

    CONSTRAINT fk_app_user_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id)
);

-- Saved beneficiaries
CREATE TABLE public.beneficiary (
    beneficiary_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    beneficiary_name VARCHAR(120) NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_beneficiary_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customer (customer_id),

    CONSTRAINT uq_beneficiary_customer_account
        UNIQUE (customer_id, account_number, bank_name)
);

-- Transfers between bank accounts
CREATE TABLE public.bank_transaction (
    bank_transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bank_transaction_reference VARCHAR(50) NOT NULL UNIQUE,
    sender_account_id BIGINT NOT NULL,
    receiver_account_id BIGINT NOT NULL,
    amount NUMERIC(19,4) NOT NULL,
    bank_transaction_type VARCHAR(20) NOT NULL,
    bank_transaction_status VARCHAR(20) NOT NULL,
    bank_transaction_date TIMESTAMPTZ NOT NULL,
    description VARCHAR(255),

    CONSTRAINT fk_transaction_sender
        FOREIGN KEY (sender_account_id)
        REFERENCES public.account (account_id),

    CONSTRAINT fk_transaction_receiver
        FOREIGN KEY (receiver_account_id)
        REFERENCES public.account (account_id),

    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0),

    CONSTRAINT chk_transaction_different_accounts
        CHECK (sender_account_id <> receiver_account_id),

    CONSTRAINT chk_transaction_status
        CHECK (
            bank_transaction_status IN ('Pending', 'Successful', 'Failed')
        )
);

-- Age, KYC activation, available funds and customer access require
-- application validation, database triggers or transaction logic.
-- Successful transfers must debit and credit accounts atomically.
-- The table definitions alone cannot verify that both balance updates
-- have completed before a transaction is marked Successful.

COMMIT;
