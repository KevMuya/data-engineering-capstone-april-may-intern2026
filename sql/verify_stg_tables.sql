
USE stg_banking_test;
GO

SELECT 'activity_extract' AS TableName, COUNT(*) AS TotalRows
FROM dbo.activity_extract

UNION ALL

SELECT 'dim_client', COUNT(*)
FROM dbo.dim_client

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dbo.dim_date

UNION ALL

SELECT 'dim_account', COUNT(*)
FROM dbo.dim_account

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dbo.dim_product;

SELECT
    event_type,
    COUNT(*) AS TotalRows
FROM dbo.activity_extract
GROUP BY event_type
ORDER BY event_type;