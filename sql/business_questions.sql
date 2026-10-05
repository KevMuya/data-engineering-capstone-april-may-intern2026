USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 1
   How many customers are there in each province, and what
   percentage of the total customer base does each province
   represent?
   ============================================================ */

SELECT
    province,
    COUNT(*) AS CustomerCount,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS PercentageOfCustomers
FROM dbo.dwh_dim_client
GROUP BY province
ORDER BY CustomerCount DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 2
   What are the different customer age bands, and how many
   customers fall into each age band?
   ============================================================ */

WITH CustomerAge AS
(
    SELECT
        client_number,
        DATEDIFF(YEAR, date_of_birth, GETDATE())
        - CASE
            WHEN DATEADD(
                YEAR,
                DATEDIFF(YEAR, date_of_birth, GETDATE()),
                date_of_birth
              ) > GETDATE()
            THEN 1
            ELSE 0
          END AS Age
    FROM dbo.dwh_dim_client
    WHERE date_of_birth IS NOT NULL
)
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        WHEN Age BETWEEN 56 AND 65 THEN '56-65'
        ELSE '66+'
    END AS AgeBand,
    COUNT(*) AS CustomerCount
FROM CustomerAge
GROUP BY
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        WHEN Age BETWEEN 56 AND 65 THEN '56-65'
        ELSE '66+'
    END
ORDER BY
    MIN(Age);
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 3
   How many customers signed up each month over the last two
   years, and what does the signup trend look like?
   ============================================================ */

SELECT
    YEAR(signup_date) AS SignupYear,
    MONTH(signup_date) AS SignupMonth,
    COUNT(*) AS CustomerCount
FROM dbo.dwh_dim_client
WHERE signup_date >= DATEADD(YEAR, -2, CAST(GETDATE() AS DATE))
GROUP BY
    YEAR(signup_date),
    MONTH(signup_date)
ORDER BY
    SignupYear,
    SignupMonth;
GO


USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 4
   What data quality issues exist in the customer and event data?
   ============================================================ */

SELECT
    'Missing Client Number' AS DataQualityIssue,
    COUNT(*) AS IssueCount
FROM stg_banking_test.dbo.activity_extract
WHERE client_number IS NULL
   OR LTRIM(RTRIM(client_number)) = ''

UNION ALL

SELECT
    'Missing First Name',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE first_name IS NULL
   OR LTRIM(RTRIM(first_name)) = ''

UNION ALL

SELECT
    'Missing Last Name',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE last_name IS NULL
   OR LTRIM(RTRIM(last_name)) = ''

UNION ALL

SELECT
    'Missing Email',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE email IS NULL
   OR LTRIM(RTRIM(email)) = ''

UNION ALL

SELECT
    'Missing Event Type',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE event_type IS NULL
   OR LTRIM(RTRIM(event_type)) = ''

UNION ALL

SELECT
    'Missing Event Date',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE event_date IS NULL

UNION ALL

SELECT
    'Missing Account Number',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE account_number IS NULL
   OR LTRIM(RTRIM(account_number)) = ''

UNION ALL

SELECT
    'Missing Product Type',
    COUNT(*)
FROM stg_banking_test.dbo.activity_extract
WHERE product_type IS NULL
   OR LTRIM(RTRIM(product_type)) = ''
ORDER BY IssueCount DESC;
GO

USE dwh_banking_test;
GO


USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 5
   How many customers have each product, and how many customers
   hold multiple products?
   ============================================================ */

-- Customers per product
SELECT
    p.product_type,
    COUNT(DISTINCT e.Client_ID) AS CustomerCount
FROM dbo.dwh_fact_product_enrollment e
JOIN dbo.dwh_dim_product p
    ON e.Product_ID = p.Product_ID
GROUP BY
    p.product_type
ORDER BY
    CustomerCount DESC;


-- Customers holding multiple products
SELECT
    COUNT(*) AS CustomersWithMultipleProducts
FROM
(
    SELECT
        Client_ID
    FROM dbo.dwh_fact_product_enrollment
    GROUP BY
        Client_ID
    HAVING COUNT(DISTINCT Product_ID) > 1
) x;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 6
   What is the total and average account balance for each
   product type?
   ============================================================ */

SELECT
    p.product_type,
    SUM(e.account_balance) AS TotalAccountBalance,
    AVG(e.account_balance) AS AverageAccountBalance
FROM dbo.dwh_fact_product_enrollment e
JOIN dbo.dwh_dim_product p
    ON e.Product_ID = p.Product_ID
WHERE e.account_balance IS NOT NULL
GROUP BY
    p.product_type
ORDER BY
    TotalAccountBalance DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 7
   How many customers have a Savings product but do not have
   a Credit Card?
   ============================================================ */

SELECT
    COUNT(*) AS CustomersWithSavingsButNoCreditCard
FROM
(
    SELECT
        e.Client_ID
    FROM dbo.dwh_fact_product_enrollment e
    JOIN dbo.dwh_dim_product p
        ON e.Product_ID = p.Product_ID
    GROUP BY
        e.Client_ID
    HAVING
        SUM(CASE WHEN p.product_type = 'Savings' THEN 1 ELSE 0 END) > 0
        AND
        SUM(CASE WHEN p.product_type = 'Credit Card' THEN 1 ELSE 0 END) = 0
) x;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 8
   How many Credit Card customers are using at least 90% of
   their credit limit?
   ============================================================ */

SELECT
    COUNT(DISTINCT e.Client_ID) AS CreditCardCustomersAt90Percent
FROM dbo.dwh_fact_product_enrollment e
JOIN dbo.dwh_dim_product p
    ON e.Product_ID = p.Product_ID
WHERE p.product_type = 'Credit Card'
  AND e.credit_limit > 0
  AND e.account_balance >= e.credit_limit * 0.90;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 9
   What is the monthly transaction value by transaction type,
   and are there any seasonal patterns?
   ============================================================ */

SELECT
    d.year_number AS TransactionYear,
    d.month_number AS TransactionMonth,
    d.month_name AS MonthName,
    f.transaction_type,
    SUM(f.amount) AS TotalTransactionValue
FROM dbo.dwh_fact_transaction f
JOIN dbo.dwh_dim_date d
    ON f.Date_ID = d.Date_ID
GROUP BY
    d.year_number,
    d.month_number,
    d.month_name,
    f.transaction_type
ORDER BY
    TransactionYear,
    TransactionMonth,
    f.transaction_type;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 10
   Which transaction channel is used most frequently, and
   which channel has the highest total transaction value?
   ============================================================ */

SELECT
    channel,
    COUNT(*) AS TransactionCount,
    SUM(amount) AS TotalTransactionValue
FROM dbo.dwh_fact_transaction
GROUP BY
    channel
ORDER BY
    TransactionCount DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 11
   How many active customers are there, based on transaction
   activity, as of the latest available date?
   ============================================================ */

SELECT
    COUNT(DISTINCT f.Client_ID) AS ActiveCustomers
FROM dbo.dwh_fact_transaction f
JOIN dbo.dwh_dim_date d
    ON f.Date_ID = d.Date_ID
WHERE d.full_date =
(
    SELECT MAX(full_date)
    FROM dbo.dwh_dim_date
    WHERE Date_ID IN
    (
        SELECT Date_ID
        FROM dbo.dwh_fact_transaction
    )
);
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 12
   Who are the top 20 customers by transaction value over the
   last 12 months?
   ============================================================ */

SELECT TOP 20
    c.client_number,
    c.first_name,
    c.last_name,
    SUM(f.amount) AS TotalTransactionValue
FROM dbo.dwh_fact_transaction f
JOIN dbo.dwh_dim_client c
    ON f.Client_ID = c.Client_ID
JOIN dbo.dwh_dim_date d
    ON f.Date_ID = d.Date_ID
WHERE d.full_date >= DATEADD(
    MONTH,
    -12,
    (
        SELECT MAX(full_date)
        FROM dbo.dwh_dim_date
        WHERE Date_ID IN
        (
            SELECT Date_ID
            FROM dbo.dwh_fact_transaction
        )
    )
)
GROUP BY
    c.client_number,
    c.first_name,
    c.last_name
ORDER BY
    TotalTransactionValue DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 13
   What is the average number of CRM interactions per customer
   by interaction type?
   ============================================================ */

SELECT
    interaction_type,
    CAST(
        COUNT(*) * 1.0 / COUNT(DISTINCT Client_ID)
        AS DECIMAL(10,2)
    ) AS AverageInteractionsPerCustomer
FROM dbo.dwh_fact_interaction
GROUP BY
    interaction_type
ORDER BY
    AverageInteractionsPerCustomer DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 14
   Which channel receives the most complaints compared with
   other interaction types?
   ============================================================ */

SELECT
    channel,
    COUNT(*) AS ComplaintCount
FROM dbo.dwh_fact_interaction
WHERE LOWER(interaction_type) = 'complaint'
GROUP BY
    channel
ORDER BY
    ComplaintCount DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 15
   What is the interaction resolution rate by channel, which
   channel has the lowest resolution rate, and how reliable is
   that comparison based on sample size?
   ============================================================ */

SELECT
    channel,
    COUNT(*) AS InteractionCount,
    SUM(CASE WHEN resolved_flag = 1 THEN 1 ELSE 0 END) AS ResolvedCount,
    CAST(
        SUM(CASE WHEN resolved_flag = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS ResolutionRate
FROM dbo.dwh_fact_interaction
GROUP BY
    channel
ORDER BY
    ResolutionRate ASC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 16
   How can customers be grouped into value tiers based on
   their transaction activity?
   ============================================================ */

WITH CustomerValue AS
(
    SELECT
        Client_ID,
        SUM(amount) AS TotalTransactionValue
    FROM dbo.dwh_fact_transaction
    GROUP BY
        Client_ID
)
SELECT
    CASE
        WHEN TotalTransactionValue < 10000 THEN 'Low Value'
        WHEN TotalTransactionValue < 50000 THEN 'Medium Value'
        WHEN TotalTransactionValue < 100000 THEN 'High Value'
        ELSE 'Very High Value'
    END AS ValueTier,
    COUNT(*) AS CustomerCount,
    SUM(TotalTransactionValue) AS TotalValue
FROM CustomerValue
GROUP BY
    CASE
        WHEN TotalTransactionValue < 10000 THEN 'Low Value'
        WHEN TotalTransactionValue < 50000 THEN 'Medium Value'
        WHEN TotalTransactionValue < 100000 THEN 'High Value'
        ELSE 'Very High Value'
    END
ORDER BY
    TotalValue DESC;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 17
   How can customers be segmented based on their signup date
   and how recently they have been active?
   ============================================================ */

WITH CustomerActivity AS
(
    SELECT
        c.Client_ID,
        c.client_number,
        c.signup_date,
        MAX(d.full_date) AS LastTransactionDate
    FROM dbo.dwh_dim_client c
    LEFT JOIN dbo.dwh_fact_transaction f
        ON c.Client_ID = f.Client_ID
    LEFT JOIN dbo.dwh_dim_date d
        ON f.Date_ID = d.Date_ID
    GROUP BY
        c.Client_ID,
        c.client_number,
        c.signup_date
)
SELECT
    CASE
        WHEN signup_date >= DATEADD(YEAR, -1, GETDATE())
            THEN 'New Customer'
        WHEN signup_date >= DATEADD(YEAR, -3, GETDATE())
            THEN 'Established Customer'
        ELSE 'Long-Term Customer'
    END AS SignupSegment,
    CASE
        WHEN LastTransactionDate IS NULL
            THEN 'Never Transacted'
        WHEN LastTransactionDate >= DATEADD(MONTH, -3, GETDATE())
            THEN 'Recently Active'
        WHEN LastTransactionDate >= DATEADD(MONTH, -12, GETDATE())
            THEN 'Active'
        ELSE 'Inactive'
    END AS ActivitySegment,
    COUNT(*) AS CustomerCount
FROM CustomerActivity
GROUP BY
    CASE
        WHEN signup_date >= DATEADD(YEAR, -1, GETDATE())
            THEN 'New Customer'
        WHEN signup_date >= DATEADD(YEAR, -3, GETDATE())
            THEN 'Established Customer'
        ELSE 'Long-Term Customer'
    END,
    CASE
        WHEN LastTransactionDate IS NULL
            THEN 'Never Transacted'
        WHEN LastTransactionDate >= DATEADD(MONTH, -3, GETDATE())
            THEN 'Recently Active'
        WHEN LastTransactionDate >= DATEADD(MONTH, -12, GETDATE())
            THEN 'Active'
        ELSE 'Inactive'
    END
ORDER BY
    SignupSegment,
    ActivitySegment;
GO

USE dwh_banking_test;
GO

USE dwh_banking_test;
GO

/* ============================================================
   QUESTION 18
   Is there a relationship between the number of CRM
   interactions a customer has and their total transaction value?
   ============================================================ */

WITH InteractionSummary AS
(
    SELECT
        Client_ID,
        COUNT(*) AS InteractionCount
    FROM dbo.dwh_fact_interaction
    GROUP BY
        Client_ID
),
TransactionSummary AS
(
    SELECT
        Client_ID,
        SUM(amount) AS TotalTransactionValue
    FROM dbo.dwh_fact_transaction
    GROUP BY
        Client_ID
),
CustomerActivity AS
(
    SELECT
        c.Client_ID,
        COALESCE(i.InteractionCount, 0) AS InteractionCount,
        COALESCE(t.TotalTransactionValue, 0) AS TotalTransactionValue
    FROM dbo.dwh_dim_client c
    LEFT JOIN InteractionSummary i
        ON c.Client_ID = i.Client_ID
    LEFT JOIN TransactionSummary t
        ON c.Client_ID = t.Client_ID
)
SELECT
    CASE
        WHEN InteractionCount = 0 THEN '0 Interactions'
        WHEN InteractionCount BETWEEN 1 AND 5 THEN '1-5 Interactions'
        WHEN InteractionCount BETWEEN 6 AND 10 THEN '6-10 Interactions'
        ELSE '11+ Interactions'
    END AS InteractionGroup,
    COUNT(*) AS CustomerCount,
    CAST(
        AVG(TotalTransactionValue) AS DECIMAL(18,2)
    ) AS AverageTransactionValue
FROM CustomerActivity
GROUP BY
    CASE
        WHEN InteractionCount = 0 THEN '0 Interactions'
        WHEN InteractionCount BETWEEN 1 AND 5 THEN '1-5 Interactions'
        WHEN InteractionCount BETWEEN 6 AND 10 THEN '6-10 Interactions'
        ELSE '11+ Interactions'
    END
ORDER BY
    CASE
        WHEN MIN(InteractionCount) = 0 THEN 1
        WHEN MIN(InteractionCount) BETWEEN 1 AND 5 THEN 2
        WHEN MIN(InteractionCount) BETWEEN 6 AND 10 THEN 3
        ELSE 4
    END;
GO