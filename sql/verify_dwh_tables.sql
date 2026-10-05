
USE dwh_banking_test;
GO

-----------------------------------------------------------
-- 1. CHECK ROW COUNTS
-----------------------------------------------------------

SELECT 'dwh_dim_client' AS TableName, COUNT(*) AS TotalRows
FROM dbo.dwh_dim_client

UNION ALL

SELECT 'dwh_dim_date', COUNT(*)
FROM dbo.dwh_dim_date

UNION ALL

SELECT 'dwh_dim_account', COUNT(*)
FROM dbo.dwh_dim_account

UNION ALL

SELECT 'dwh_dim_product', COUNT(*)
FROM dbo.dwh_dim_product

UNION ALL

SELECT 'dwh_fact_transaction', COUNT(*)
FROM dbo.dwh_fact_transaction

UNION ALL

SELECT 'dwh_fact_interaction', COUNT(*)
FROM dbo.dwh_fact_interaction

UNION ALL

SELECT 'dwh_fact_product_enrollment', COUNT(*)
FROM dbo.dwh_fact_product_enrollment;


-----------------------------------------------------------
-- 2. CHECK DUPLICATES IN DIMENSIONS
-----------------------------------------------------------

SELECT client_number, COUNT(*) AS DuplicateCount
FROM dbo.dwh_dim_client
GROUP BY client_number
HAVING COUNT(*) > 1;

SELECT full_date, COUNT(*) AS DuplicateCount
FROM dbo.dwh_dim_date
GROUP BY full_date
HAVING COUNT(*) > 1;

SELECT account_number, COUNT(*) AS DuplicateCount
FROM dbo.dwh_dim_account
GROUP BY account_number
HAVING COUNT(*) > 1;

SELECT product_type, COUNT(*) AS DuplicateCount
FROM dbo.dwh_dim_product
GROUP BY product_type
HAVING COUNT(*) > 1;


-----------------------------------------------------------
-- 3. CHECK DUPLICATES IN FACT TABLES
-----------------------------------------------------------

SELECT source_event_key, COUNT(*) AS DuplicateCount
FROM dbo.dwh_fact_transaction
GROUP BY source_event_key
HAVING COUNT(*) > 1;

SELECT source_event_key, COUNT(*) AS DuplicateCount
FROM dbo.dwh_fact_interaction
GROUP BY source_event_key
HAVING COUNT(*) > 1;

SELECT source_event_key, COUNT(*) AS DuplicateCount
FROM dbo.dwh_fact_product_enrollment
GROUP BY source_event_key
HAVING COUNT(*) > 1;


-----------------------------------------------------------
-- 4. FINAL FACT COUNTS
-----------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM dbo.dwh_fact_transaction) AS Transactions,
    (SELECT COUNT(*) FROM dbo.dwh_fact_interaction) AS Interactions,
    (SELECT COUNT(*) FROM dbo.dwh_fact_product_enrollment) AS ProductEnrollments;
GO