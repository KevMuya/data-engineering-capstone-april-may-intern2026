USE stg_banking_test;
GO

SELECT COUNT(*) AS activity_extract_rows
FROM dbo.activity_extract;

USE stg_banking_test;
GO

/* ============================================================
   1. STAGING DIM_CLIENT
   ============================================================ */

IF OBJECT_ID('dbo.dim_client', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_client
    (
        client_number   VARCHAR(50),
        first_name      VARCHAR(100),
        last_name       VARCHAR(100),
        email           VARCHAR(255),
        mobile_number   VARCHAR(50),
        date_of_birth   VARCHAR(20),
        gender          VARCHAR(20),
        province        VARCHAR(100),
        city            VARCHAR(100),
        signup_date     VARCHAR(20)
    );
END;
GO

TRUNCATE TABLE dbo.dim_client;
GO

INSERT INTO dbo.dim_client
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
SELECT DISTINCT
    LTRIM(RTRIM(client_number)),
    LTRIM(RTRIM(first_name)),
    LTRIM(RTRIM(last_name)),
    LTRIM(RTRIM(email)),
    LTRIM(RTRIM(mobile_number)),
    LTRIM(RTRIM(date_of_birth)),
    LTRIM(RTRIM(gender)),
    LTRIM(RTRIM(province)),
    LTRIM(RTRIM(city)),
    LTRIM(RTRIM(signup_date))
FROM dbo.activity_extract
WHERE client_number IS NOT NULL
  AND LTRIM(RTRIM(client_number)) <> '';
GO


/* ============================================================
   2. STAGING DIM_DATE
   ============================================================ */

IF OBJECT_ID('dbo.dim_date', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_date
    (
        signup_date VARCHAR(20),
        event_date  VARCHAR(20)
    );
END;
GO

TRUNCATE TABLE dbo.dim_date;
GO

INSERT INTO dbo.dim_date
(
    signup_date,
    event_date
)
SELECT DISTINCT
    LTRIM(RTRIM(signup_date)),
    LTRIM(RTRIM(event_date))
FROM dbo.activity_extract;
GO


/* ============================================================
   3. STAGING DIM_ACCOUNT
   ============================================================ */

IF OBJECT_ID('dbo.dim_account', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_account
    (
        account_number VARCHAR(50),
        account_status VARCHAR(50)
    );
END;
GO

TRUNCATE TABLE dbo.dim_account;
GO

INSERT INTO dbo.dim_account
(
    account_number,
    account_status
)
SELECT DISTINCT
    LTRIM(RTRIM(account_number)),
    LTRIM(RTRIM(account_status))
FROM dbo.activity_extract
WHERE account_number IS NOT NULL
  AND LTRIM(RTRIM(account_number)) <> '';
GO


/* ============================================================
   4. STAGING DIM_PRODUCT
   ============================================================ */

IF OBJECT_ID('dbo.dim_product', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dim_product
    (
        product_type VARCHAR(100)
    );
END;
GO

TRUNCATE TABLE dbo.dim_product;
GO

INSERT INTO dbo.dim_product
(
    product_type
)
SELECT DISTINCT
    LTRIM(RTRIM(product_type))
FROM dbo.activity_extract
WHERE product_type IS NOT NULL
  AND LTRIM(RTRIM(product_type)) <> '';
GO