# Customer 360 Data Warehouse

A SQL Server data engineering project that turns a single denormalized South African retail banking activity extract into a dimensional warehouse for customer, account, product, transaction, and CRM analysis.

## Project Overview

The source CSV combines customer details with three event types: product enrollments, transactions, and CRM interactions. The SQL pipeline lands the extract, derives staging lookup tables, builds warehouse dimensions and event facts, then queries the warehouse to answer business questions.

The architecture follows a medallion-style progression. Bronze, Silver, and Gold are conceptual names for the SQL Server landing, staging, and warehouse layers in this project.

See the [medallion architecture](docs/medallion_architecture.md) and [Customer 360 star schema](docs/customer_360_star_schema.png).

## Data Model

The warehouse is in `dwh_banking_test` and uses a star-schema design:

| Table | Purpose / grain |
|---|---|
| `dwh_dim_client` | One row per client business key, with demographic and contact attributes |
| `dwh_dim_date` | One row per calendar date used for signup or event dates |
| `dwh_dim_account` | One row per account number |
| `dwh_dim_product` | One row per product type |
| `dwh_fact_transaction` | One row per transaction event |
| `dwh_fact_interaction` | One row per distinct CRM interaction event |
| `dwh_fact_product_enrollment` | One row per product enrollment event |

The fact tables use warehouse surrogate keys for their dimension relationships. Source-event hashes are used to prevent duplicate event loads.

## Repository Contents

```text
data/raw/activity_extract.csv       Source activity extract
docs/                               Data dictionary, quality note, questions,
                                    query results, run guide, and diagrams
sql/                                Database, staging, warehouse, validation,
                                    and business-question scripts
ssis/                               SSIS workflow screenshots
```

Key documentation:

- [End-to-end run instructions](docs/run_instructions.md)
- [Data quality findings and handling](docs/data_quality.md)
- [Source data dictionary](docs/dictionary.md)
- [Business questions](docs/questions.md)
- [Business question results](docs/business_questions_answers.md)
- [Medallion architecture](docs/medallion_architecture.md)

## Requirements

- Microsoft SQL Server
- SQL Server Management Studio (SSMS) or another SQL Server client
- The source file at `data/raw/activity_extract.csv`

The repository includes SSIS screenshots in `ssis/`; it does not currently include runnable SSIS `.dtsx` packages or a Visual Studio SSIS project. The steps below use the provided SQL scripts and a manual import into the landing table.

## Run the Pipeline

Follow these steps in order. Detailed notes are in [docs/run_instructions.md](docs/run_instructions.md).

1. Run [`sql/00_create_databases.sql`](sql/00_create_databases.sql) to create `stg_banking_test` and `dwh_banking_test`.
2. Import `data/raw/activity_extract.csv` into `stg_banking_test.dbo.activity_extract`.
3. Run [`sql/create_load_stg_tables.sql`](sql/create_load_stg_tables.sql) to create and populate the staging lookup tables.
4. Run [`sql/verify_stg_tables.sql`](sql/verify_stg_tables.sql) to review staging counts and event volumes.
5. Run [`sql/create_load_dwh_tables.sql`](sql/create_load_dwh_tables.sql) to create and populate the warehouse dimensions and facts.
6. Run [`sql/verify_dwh_tables.sql`](sql/verify_dwh_tables.sql) to check counts, duplicates, and referential integrity.
7. Run [`sql/business_questions.sql`](sql/business_questions.sql) for the analysis queries.

The staging script trims values and derives client, date, account, and product tables. The warehouse loader builds dimensions from staging and loads the three event fact tables from the landing extract, filtering by `event_type`.

## Data Quality

The source includes whitespace and inconsistent casing, missing optional client attributes, mixed mobile-number formats, and repeated client data across event rows. The staging logic trims whitespace and deduplicates client attributes; optional missing values and source gender values such as `U` are retained instead of being replaced with assumptions. Dates and numeric measures are converted during the warehouse load, and event-specific blank columns are expected in the source format.

See [docs/data_quality.md](docs/data_quality.md) for the findings and handling details. The business-question answers include partial result sets where the supplied screenshots did not capture every row.
