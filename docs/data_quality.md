# Customer 360 Data Quality Note

## Data quality findings

The raw activity extract contains several data-quality issues identified during source profiling.

### 1. Leading and trailing whitespace

Some values contain unnecessary spaces.

Examples include email addresses such as:

- ` sam.de villiers82@webmail.co.za `
- other email values with leading or trailing whitespace

### 2. Inconsistent email casing

Email addresses are not consistently stored using the same casing.

For example, the source contains values such as:

- `AYESHA.NKOSI66@TELKOMSA.NET`

alongside lower-case email addresses.

### 3. Missing customer attributes

Some customer records have missing optional attributes.

Examples include:

- Missing mobile number for `CL00111`
- Missing gender for `CL00453`

Missing values were retained rather than replaced with invented values.

### 4. Unknown gender values

The source contains gender values outside the expected `M` / `F` values.

For example:

- `CL00564` has gender value `U`

This value was retained because it represents the value provided by the source.

### 5. Inconsistent mobile-number formatting

Mobile numbers appear in different formats, including:

- `27745498258`
- `079-233-1937`
- `685 723 173`

Mobile numbers were treated as character data rather than numeric data so that formatting and leading zeroes are not lost.

### 6. Repeated customer information

The source is an event-level activity extract, so customer information is repeated across multiple events for the same client.

This is expected for the source structure and was not treated as separate customer records.

The client dimension uses `client_number` as the business key and keeps one customer record per client.

### 7. Event-specific missing values

Some fields are blank because they are not applicable to a particular event type.

For example:

- CRM interaction records do not contain transaction-specific values.
- Transaction records do not contain CRM interaction-specific attributes.
- Product enrollment records contain product and account information that is not applicable to other event types.

These values were retained as `NULL`/blank where the attribute is not applicable.

## Handling applied

The ETL applies the following handling:

- Leading and trailing whitespace is removed during staging.
- Blank client business keys are excluded from dimension loading.
- Repeated client information is deduplicated using the client business key.
- Missing optional attributes are retained rather than replaced with assumed values.
- Mobile numbers are stored as strings.
- Date and numeric values are converted during the warehouse load using conversion logic that can safely handle invalid values.
- Warehouse business keys and source event keys are protected by uniqueness constraints and duplicate checks to support rerunnable loads.

## Data quality approach

The objective was to clean values where the issue could be safely corrected without changing the meaning of the source data.

Values that were missing, unknown, or event-specific were not artificially populated. This preserves the original information while allowing the warehouse model to separate customer attributes from event-level activity.