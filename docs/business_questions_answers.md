# Customer 360 Business Questions — Answers

> **Source:** Reconstructed from the SSMS result screenshots provided for the Customer 360 business questions.
>
> **Important:** The screenshots do not show the complete result set for every question. Where only part of a result set is visible, the visible rows are recorded below rather than inventing missing values.

---

## Question 1 — Customers per province

| Province | Customer Count | Percentage of Customers |
|---|---:|---:|
| Eastern Cape | 191 | 12.87% |
| KwaZulu Natal | 187 | 12.60% |
| Mpumalanga | 176 | 11.86% |
| Western Cape | 165 | 11.12% |
| Gauteng | 164 | 11.05% |
| Free State | 164 | 11.05% |
| North West | 158 | 10.65% |
| Northern Cape | 142 | 9.57% |

---

## Question 2 — Age distribution

| Age Band | Customer Count |
|---|---:|
| 18–25 | 177 |
| 26–35 | 269 |
| 36–45 | 257 |
| 46–55 | 226 |
| 56–65 | 261 |
| 66+ | 294 |

The largest age band is **66+ with 294 customers**.

---

## Question 3 — Signups per month

| Signup Year | Signup Month | Customer Count |
|---:|---:|---:|
| 2024 | 10 | 23 |
| 2024 | 11 | 38 |
| 2024 | 12 | 30 |
| 2025 | 1 | 37 |
| 2025 | 2 | 47 |
| 2025 | 3 | 41 |
| 2025 | 4 | 37 |
| 2025 | 5 | 39 |
| 2025 | 6 | 21 |

The highest visible monthly signup count is **47 in February 2025**.

---

## Question 4 — Data quality issues

| Data Quality Issue | Issue Count |
|---|---:|
| Missing Account Number | 4,500 |
| Missing Product Type | 4,500 |
| Missing Email | 354 |
| Missing Client Number | 0 |
| Missing Event Date | 0 |
| Missing Event Type | 0 |
| Missing First Name | 0 |

The screenshot only shows the first part of this result set, so additional rows are not reproduced here.

---

## Question 5 — Customers per product / cross-holding

### Customers per product

| Product Type | Customer Count |
|---|---:|
| Savings | 678 |
| Credit Card | 673 |
| Personal Loan | 649 |

### Customers with multiple products

**593 customers** have multiple products.

---

## Question 6 — Total and average account balance by product

| Product Type | Total Account Balance | Average Account Balance |
|---|---:|---:|
| Savings | 26,100,944.34 | 38,496.968053 |
| Personal Loan | 15,446,189.02 | 23,799.983081 |
| Credit Card | 7,218,723.33 | 10,726.186225 |

---

## Question 7 — Savings but no Credit Card

**382 customers** have a Savings product but no Credit Card.

---

## Question 8 — Credit Card accounts within 90% of credit limit

**68 customers** have Credit Card accounts at or within 90% of their credit limit.

---

## Question 9 — Monthly transaction value by transaction type

The screenshot shows the following visible rows:

| Year | Month | Month Name | Transaction Type | Total Transaction Value |
|---:|---:|---|---|---:|
| 2022 | 6 | June | Debit Order | -1,454.42 |
| 2022 | 6 | June | Deposit | 3,609.06 |
| 2022 | 6 | June | EFT Payment | 5,670.12 |
| 2022 | 6 | June | Fee | -1,785.07 |
| 2022 | 6 | June | POS Purchase | -11,036.69 |
| 2022 | 6 | June | Refund | 5,477.08 |
| 2022 | 6 | June | Withdrawal | -5,106.78 |
| 2022 | 7 | July | Debit Order | -2,830.32 |

Only these rows are visible in the supplied screenshot; the complete monthly result is therefore not reconstructed here.

---

## Question 10 — Transaction channel

| Channel | Transaction Count | Total Transaction Value |
|---|---:|---:|
| POS | 4,122 | -13,419,659.15 |
| EFT | 3,281 | -5,180,451.49 |
| ATM | 2,488 | -1,919,875.34 |
| Branch | 2,472 | -1,865,968.68 |
| Online… | 1,500 | 6,011,468.17 |
| Mobile… | 1,137 | 4,527,934.54 |

**POS** has the highest transaction count at **4,122**.

---

## Question 11 — Active customers

**Active Customers: 1**

---

## Question 12 — Top 20 customers by transaction value

The supplied screenshot shows rows 10–14:

| Rank Shown | Client Number | First Name | Last Name | Total Transaction Value |
|---:|---|---|---|---:|
| 10 | CL01271 | Ilse | Smith | 23,949.50 |
| 11 | CL01237 | Grace | Botha | 22,539.74 |
| 12 | CL01413 | Ayesha | Kruger | 22,469.46 |
| 13 | CL01395 | Riaan | Nkosi | 22,367.22 |
| 14 | CL00444 | David | De Villiers | 20,611.73 |

The screenshot does not show all 20 rows, so the remaining ranks are not reproduced.

---

## Question 13 — Average CRM interactions per customer by interaction type

| Interaction Type | Average Interactions Per Customer |
|---|---:|
| Query | 1.80 |
| Product Application | 1.31 |
| Complaint | 1.31 |
| Feedback | 1.16 |
| Fraud Report | 1.10 |

**Query** has the highest average at **1.80 interactions per customer**.

---

## Question 14 — Complaint channel

| Channel | Complaint Count |
|---|---:|
| Call | 195 |
| Branch | 186 |
| Chat | 182 |
| Email | 178 |
| WhatsApp… | 159 |

**Call** has the highest visible complaint count at **195**.

---

## Question 15 — Resolution rate by channel

| Channel | Interaction Count | Resolved Count | Resolution Rate |
|---|---:|---:|---:|
| WhatsApp | 889 | 663 | 74.58% |
| Call | 888 | 664 | 74.77% |
| Email | 909 | 691 | 76.02% |
| Branch | 902 | 688 | 76.27% |
| Chat | 911 | 703 | 77.17% |

**Chat** has the highest resolution rate at **77.17%**.

**WhatsApp** has the lowest resolution rate at **74.58%**.

---

## Question 16 — Customer value tiers

| Value Tier | Customer Count | Total Value |
|---|---:|---:|
| Medium Value | 126 | 2,127,159.47 |
| Low Value | 1,127 | -13,973,711.42 |

Only the two tiers visible in the supplied screenshot are recorded.

---

## Question 17 — Customer lifecycle segmentation

| Signup Segment | Activity Segment | Customer Count |
|---|---|---:|
| Established Customer | Active | 8 |
| Established Customer | Inactive | 629 |
| Established Customer | Never Transacted | 113 |
| Long-Term Customer | Active | 12 |
| Long-Term Customer | Inactive | 604 |
| Long-Term Customer | Never Transacted | 118 |

---

## Question 18 — CRM interactions vs transaction value

| Interaction Group | Customer Count | Average Transaction Value |
|---|---:|---:|
| 0 Interactions | 53 | -10,511.76 |
| 1–5 Interactions | 1,316 | -7,886.77 |
| 6–10 Interactions | 114 | -8,011.39 |
| 11+ Interactions | 1 | 2,859.74 |

### Observation

The supplied result does not show a clear positive linear relationship between the number of CRM interactions and average transaction value. The largest customer group is the **1–5 interactions** group, with **1,316 customers** and an average transaction value of **-7,886.77**.