# Customer 360 Medallion Architecture

This diagram maps the repository's SQL Server pipeline to the medallion pattern. Bronze, Silver, and Gold are conceptual layers here; the project uses SQL Server databases and tables, not a separate lakehouse platform.

```mermaid
flowchart LR
    csv["data/raw/activity_extract.csv\nSingle denormalized event extract"]

    subgraph bronze["BRONZE | Raw landing"]
        raw[("stg_banking_test.dbo.activity_extract\nRaw rows retained for downstream loads")]
    end

    subgraph silver["SILVER | Cleaned staging"]
        client["dbo.dim_client\nTrimmed, deduplicated client attributes"]
        date["dbo.dim_date\nDistinct signup and event dates"]
        account["dbo.dim_account\nDistinct account identifiers and status"]
        product["dbo.dim_product\nDistinct product types"]
    end

    subgraph gold["GOLD | Dimensional warehouse"]
        dclient[("dbo.dwh_dim_client")]
        ddate[("dbo.dwh_dim_date")]
        daccount[("dbo.dwh_dim_account")]
        dproduct[("dbo.dwh_dim_product")]
        ftxn[("dbo.dwh_fact_transaction\nGrain: one transaction event")]
        fint[("dbo.dwh_fact_interaction\nGrain: one distinct CRM event")]
        fenroll[("dbo.dwh_fact_product_enrollment\nGrain: one enrollment event")]
    end

    reports["sql/business_questions.sql\nCustomer, product, transaction, and CRM analysis"]
    answers["docs/business_questions_answers.md\nDocumented query results"]

    csv --> raw
    raw -->|"trim, deduplicate"| client
    raw -->|"collect dates"| date
    raw -->|"collect accounts"| account
    raw -->|"collect product types"| product

    client --> dclient
    date --> ddate
    account --> daccount
    product --> dproduct

    raw -->|"event_type = Transaction"| ftxn
    raw -->|"event_type = CRM Interaction; deduplicate"| fint
    raw -->|"event_type = Product Enrollment"| fenroll

    dclient --> ftxn
    ddate --> ftxn
    daccount --> ftxn
    dclient --> fint
    ddate --> fint
    dclient --> fenroll
    ddate --> fenroll
    daccount --> fenroll
    dproduct --> fenroll

    ftxn --> reports
    fint --> reports
    fenroll --> reports
    dclient --> reports
    reports --> answers

    classDef source fill:#f5f0e8,stroke:#7a6852,color:#222
    classDef silver fill:#e8f3f1,stroke:#28766d,color:#173b37
    classDef gold fill:#fff0d8,stroke:#b87514,color:#4a310e
    class csv,raw source
    class client,date,account,product silver
    class dclient,ddate,daccount,dproduct,ftxn,fint,fenroll gold
```

## How to read the flow

- The raw CSV is imported into `stg_banking_test.dbo.activity_extract` as the landing source.
- The staging script trims whitespace and derives client, date, account, and product lookup tables. The client table is deduplicated by its selected source attributes.
- The warehouse loader builds dimensions from those staging tables. It builds the transaction, interaction, and enrollment facts from the landing extract, using `event_type` to select each event family and joining to warehouse dimensions for surrogate keys.
- The business-question queries use the Gold warehouse tables for analysis. Question 4 also reads the raw landing table to measure source-quality issues.

## Operational notes

The scripts in `docs/run_instructions.md` describe the execution order and verification points. `verify_stg_tables.sql` checks the landing and staging row counts; `verify_dwh_tables.sql` checks warehouse counts, duplicates, and orphan keys. The repository documents importing the CSV into the landing table before running the SQL transformations; it does not include an SSIS project/package implementing the flow.