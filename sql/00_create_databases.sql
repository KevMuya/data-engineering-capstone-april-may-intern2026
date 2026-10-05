/*
    Customer 360 - Database Creation
    ---------------------------------
    Creates the separate staging and data warehouse databases
    used by the Customer 360 ETL.
    
*/

IF DB_ID('stg_banking_test') IS NULL
BEGIN
    CREATE DATABASE stg_banking_test;
END;
GO

IF DB_ID('dwh_banking_test') IS NULL
BEGIN
    CREATE DATABASE dwh_banking_test;
END;
GO
