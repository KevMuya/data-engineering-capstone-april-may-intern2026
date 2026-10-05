# Customer 360 - End-to-End Run Instructions

## Prerequisites

The solution requires:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS) / SSDT
- Customer 360 source CSV file

## 1. Create the databases

Run:

`sql/00_create_databases.sql`

This creates:

- `stg_banking_test`
- `dwh_banking_test`

## 2. Load the raw source data

Import the CSV file into:

`stg_banking_test.dbo.activity_extract`

The raw activity extract contains customer information and event-level activity for:

- Product Enrollment
- Transaction
- CRM Interaction

## 3. Create and load the staging layer

Run:

`sql/create_load_stg_tables.sql`

This creates and loads:

- `stg_banking_test.dbo.dim_client`
- `stg_banking_test.dbo.dim_date`
- `stg_banking_test.dbo.dim_account`
- `stg_banking_test.dbo.dim_product`

## 4. Verify the staging layer

Run:

`sql/verify_stg_tables.sql`

This verifies the staging tables and source event distribution.

Expected source volumes:

- Transaction: 15,000
- CRM Interaction: 4,500
- Product Enrollment: 2,000

## 5. Create and load the data warehouse

Run:

`sql/create_load_dwh_tables.sql`

This creates and loads the dimensions and fact tables in:

`dwh_banking_test`

## 6. Verify the data warehouse

Run:

`sql/verify_dwh_tables.sql`

This verifies:

- Warehouse row counts
- Duplicate records
- Foreign-key/orphan records
- Date values

## 7. Run the business questions

Run:

`sql/business_questions.sql`

The corresponding results are documented in:

`docs/business_questions_answers.md`

## Execution order

Run the scripts in this order:

1. `00_create_databases.sql`
2. Import the raw CSV
3. `create_load_stg_tables.sql`
4. `verify_stg_tables.sql`
5. `create_load_dwh_tables.sql`
6. `verify_dwh_tables.sql`
7. `business_questions.sql`