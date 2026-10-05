

USE dwh_banking_test;
GO

/* ============================================================
   1. DWH DIM CLIENT
   ============================================================ */

IF OBJECT_ID('dbo.dwh_dim_client', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_dim_client
    (
        Client_ID       INT IDENTITY(1,1) PRIMARY KEY,
        client_number   VARCHAR(50) UNIQUE NOT NULL,
        first_name      VARCHAR(100),
        last_name       VARCHAR(100),
        email           VARCHAR(255),
        mobile_number   VARCHAR(50),
        date_of_birth   DATE,
        gender          VARCHAR(20),
        province        VARCHAR(100),
        city            VARCHAR(100),
        signup_date     DATE
    );
END;
GO

INSERT INTO dbo.dwh_dim_client
(
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender,
    province,
    city,
    signup_date
)
SELECT
    client_number,
    MAX(first_name),
    MAX(last_name),
    MAX(email),
    MAX(mobile_number),
    TRY_CONVERT(DATE, MAX(date_of_birth)),
    MAX(gender),
    MAX(province),
    MAX(city),
    TRY_CONVERT(DATE, MAX(signup_date))
FROM stg_banking_test.dbo.dim_client s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_dim_client d
    WHERE d.client_number = s.client_number
)
GROUP BY client_number;
GO


/* ============================================================
   2. DWH DIM DATE
   ============================================================ */

IF OBJECT_ID('dbo.dwh_dim_date', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_dim_date
    (
        Date_ID         INT PRIMARY KEY,
        full_date       DATE UNIQUE NOT NULL,
        day_number      INT,
        month_number    INT,
        month_name      VARCHAR(20),
        quarter_number  INT,
        year_number     INT
    );
END;
GO

INSERT INTO dbo.dwh_dim_date
(
    Date_ID,
    full_date,
    day_number,
    month_number,
    month_name,
    quarter_number,
    year_number
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), x.full_date, 112)),
    x.full_date,
    DAY(x.full_date),
    MONTH(x.full_date),
    DATENAME(MONTH, x.full_date),
    DATEPART(QUARTER, x.full_date),
    YEAR(x.full_date)
FROM
(
    SELECT TRY_CONVERT(DATE, signup_date) AS full_date
    FROM stg_banking_test.dbo.dim_date
    WHERE TRY_CONVERT(DATE, signup_date) IS NOT NULL

    UNION

    SELECT TRY_CONVERT(DATE, event_date)
    FROM stg_banking_test.dbo.dim_date
    WHERE TRY_CONVERT(DATE, event_date) IS NOT NULL
) x
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_dim_date d
    WHERE d.full_date = x.full_date
);
GO


/* ============================================================
   3. DWH DIM ACCOUNT
   ============================================================ */

IF OBJECT_ID('dbo.dwh_dim_account', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_dim_account
    (
        Account_ID      INT IDENTITY(1,1) PRIMARY KEY,
        account_number  VARCHAR(50) UNIQUE NOT NULL,
        account_status  VARCHAR(50)
    );
END;
GO

INSERT INTO dbo.dwh_dim_account
(
    account_number,
    account_status
)
SELECT
    account_number,
    MAX(account_status)
FROM stg_banking_test.dbo.dim_account s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_dim_account d
    WHERE d.account_number = s.account_number
)
GROUP BY account_number;
GO


/* ============================================================
   4. DWH DIM PRODUCT
   ============================================================ */

IF OBJECT_ID('dbo.dwh_dim_product', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_dim_product
    (
        Product_ID    INT IDENTITY(1,1) PRIMARY KEY,
        product_type  VARCHAR(100) UNIQUE NOT NULL
    );
END;
GO

INSERT INTO dbo.dwh_dim_product
(
    product_type
)
SELECT DISTINCT
    product_type
FROM stg_banking_test.dbo.dim_product s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_dim_product d
    WHERE d.product_type = s.product_type
);
GO


/* ============================================================
   5. DWH FACT TRANSACTION
   ============================================================ */

IF OBJECT_ID('dbo.dwh_fact_transaction', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_fact_transaction
    (
        Fact_Transaction_ID BIGINT IDENTITY(1,1) PRIMARY KEY,
        Client_ID           INT NOT NULL,
        Date_ID             INT NOT NULL,
        Account_ID          INT NULL,
        transaction_type    VARCHAR(100),
        channel             VARCHAR(100),
        amount              DECIMAL(18,2),
        account_balance     DECIMAL(18,2),
        source_event_key    VARCHAR(64) UNIQUE NOT NULL,

        FOREIGN KEY (Client_ID) REFERENCES dbo.dwh_dim_client(Client_ID),
        FOREIGN KEY (Date_ID) REFERENCES dbo.dwh_dim_date(Date_ID),
        FOREIGN KEY (Account_ID) REFERENCES dbo.dwh_dim_account(Account_ID)
    );
END;
GO

INSERT INTO dbo.dwh_fact_transaction
(
    Client_ID,
    Date_ID,
    Account_ID,
    transaction_type,
    channel,
    amount,
    account_balance,
    source_event_key
)
SELECT
    c.Client_ID,
    d.Date_ID,
    a.Account_ID,
    s.transaction_type,
    s.channel,
    TRY_CONVERT(DECIMAL(18,2), s.amount),
    TRY_CONVERT(DECIMAL(18,2), s.account_balance),
    CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.account_number, '|',
            s.transaction_type, '|',
            s.channel, '|',
            s.amount, '|',
            s.account_balance
        )
    ), 2)
FROM stg_banking_test.dbo.activity_extract s
JOIN dbo.dwh_dim_client c
    ON c.client_number = s.client_number
JOIN dbo.dwh_dim_date d
    ON d.full_date = TRY_CONVERT(DATE, s.event_date)
LEFT JOIN dbo.dwh_dim_account a
    ON a.account_number = s.account_number
WHERE s.event_type = 'Transaction'
AND NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_fact_transaction f
    WHERE f.source_event_key = CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.account_number, '|',
            s.transaction_type, '|',
            s.channel, '|',
            s.amount, '|',
            s.account_balance
        )
    ), 2)
);
GO


/* ============================================================
   6. DWH FACT INTERACTION
   ============================================================ */

IF OBJECT_ID('dbo.dwh_fact_interaction', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_fact_interaction
    (
        Fact_Interaction_ID BIGINT IDENTITY(1,1) PRIMARY KEY,
        Client_ID           INT NOT NULL,
        Date_ID             INT NOT NULL,
        interaction_type    VARCHAR(100),
        channel             VARCHAR(100),
        resolved_flag       BIT,
        interaction_count   INT DEFAULT 1,
        source_event_key    VARCHAR(64) UNIQUE NOT NULL,

        FOREIGN KEY (Client_ID) REFERENCES dbo.dwh_dim_client(Client_ID),
        FOREIGN KEY (Date_ID) REFERENCES dbo.dwh_dim_date(Date_ID)
    );
END;
GO

INSERT INTO dbo.dwh_fact_interaction
(
    Client_ID,
    Date_ID,
    interaction_type,
    channel,
    resolved_flag,
    interaction_count,
    source_event_key
)
SELECT
    c.Client_ID,
    d.Date_ID,
    s.interaction_type,
    s.channel,
    CASE
        WHEN LOWER(s.resolved_flag) IN ('1','true','yes','y')
        THEN 1 ELSE 0
    END,
    1,
    CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.interaction_type, '|',
            s.channel, '|',
            s.resolved_flag
        )
    ), 2)
FROM
(
    SELECT DISTINCT
        client_number,
        event_date,
        interaction_type,
        channel,
        resolved_flag
    FROM stg_banking_test.dbo.activity_extract
    WHERE event_type = 'CRM Interaction'
) s
JOIN dbo.dwh_dim_client c
    ON c.client_number = s.client_number
JOIN dbo.dwh_dim_date d
    ON d.full_date = TRY_CONVERT(DATE, s.event_date)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_fact_interaction f
    WHERE f.source_event_key = CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.interaction_type, '|',
            s.channel, '|',
            s.resolved_flag
        )
    ), 2)
);
GO

/* ============================================================
   7. DWH FACT PRODUCT ENROLLMENT
   ============================================================ */

IF OBJECT_ID('dbo.dwh_fact_product_enrollment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dwh_fact_product_enrollment
    (
        Fact_Enrollment_ID BIGINT IDENTITY(1,1) PRIMARY KEY,
        Client_ID           INT NOT NULL,
        Date_ID             INT NOT NULL,
        Account_ID          INT NULL,
        Product_ID          INT NOT NULL,
        credit_limit        DECIMAL(18,2),
        loan_amount         DECIMAL(18,2),
        account_balance     DECIMAL(18,2),
        enrollment_count    INT DEFAULT 1,
        source_event_key    VARCHAR(64) UNIQUE NOT NULL,

        FOREIGN KEY (Client_ID) REFERENCES dbo.dwh_dim_client(Client_ID),
        FOREIGN KEY (Date_ID) REFERENCES dbo.dwh_dim_date(Date_ID),
        FOREIGN KEY (Account_ID) REFERENCES dbo.dwh_dim_account(Account_ID),
        FOREIGN KEY (Product_ID) REFERENCES dbo.dwh_dim_product(Product_ID)
    );
END;
GO

INSERT INTO dbo.dwh_fact_product_enrollment
(
    Client_ID,
    Date_ID,
    Account_ID,
    Product_ID,
    credit_limit,
    loan_amount,
    account_balance,
    enrollment_count,
    source_event_key
)
SELECT
    c.Client_ID,
    d.Date_ID,
    a.Account_ID,
    p.Product_ID,
    TRY_CONVERT(DECIMAL(18,2), s.credit_limit),
    TRY_CONVERT(DECIMAL(18,2), s.loan_amount),
    TRY_CONVERT(DECIMAL(18,2), s.account_balance),
    1,
    CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.account_number, '|',
            s.product_type, '|',
            s.credit_limit, '|',
            s.loan_amount, '|',
            s.account_balance
        )
    ), 2)
FROM stg_banking_test.dbo.activity_extract s
JOIN dbo.dwh_dim_client c
    ON c.client_number = s.client_number
JOIN dbo.dwh_dim_date d
    ON d.full_date = TRY_CONVERT(DATE, s.event_date)
JOIN dbo.dwh_dim_product p
    ON p.product_type = s.product_type
LEFT JOIN dbo.dwh_dim_account a
    ON a.account_number = s.account_number
WHERE s.event_type = 'Product Enrollment'
AND NOT EXISTS
(
    SELECT 1
    FROM dbo.dwh_fact_product_enrollment f
    WHERE f.source_event_key = CONVERT(VARCHAR(64), HASHBYTES(
        'SHA2_256',
        CONCAT(
            s.client_number, '|',
            s.event_date, '|',
            s.account_number, '|',
            s.product_type, '|',
            s.credit_limit, '|',
            s.loan_amount, '|',
            s.account_balance
        )
    ), 2)
);
GO