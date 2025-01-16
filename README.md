# Assumptions

1. The raw tables, including `store.csv`, `device.csv`, and `transaction.csv`, are stored under the `SUMUP_SOURCE` database and `SHEET` schema.
2. I created the dim_stores and dim_devices tables to represent `store.csv` and `device.csv`, respectively. These dimension tables are stored in the `SUMUP_REPORTING` database and the dim schema.
3. I created the fct_transactions table to represent `transaction.csv` and `device.csv`. These fact tables are stored in the `SUMUP_REPORTING` database and the fct schema.
4. I anticipate that the transaction table will contain billions of records in the future. Therefore, I materialized the fct_transactions table as an incremental table. An incremental table is scalable enough to handle billions of records while keeping computing costs low.
5. In the transaction table, out of 1,500 records, 1,274 have happened_at before `created_at`, and 226 have happened_at after `created_at`. I assume that happened_at represents the timestamp when the transactions occurred, while created_at represents the timestamp when the record was created in the transaction table. For the records where `happened_at` is before `created_at`, I found that the average difference between `created_at` and `happened_at` is 222 days. It is unclear why such a large difference exists.
6. I removed the card number and CVV from the data, as they are personally identifiable information (PII) and will not be used in any downstream tables.
7. The relationship between `product_sku`, `product_name`, and `category_name` is many-to-many. However, I assume that `product_sku` is the most granular dimension for each product. Therefore, I used product_sku to calculate the top 10 products. It may be worth further investigating the product_sku alongside other product information.
8. I created an intermediate table combining the transaction table, device, and store information. This intermediate table was then used to build the fact tables that answer the key business questions. The intermediate table is stored in the SUMUP_REPORTING database and the intermediate schema.
9. For analysis purposes, I assumed that only accepted or successful transactions are relevant.
10. I found that some countries with the "other" typology have high average transaction amounts. I believe that "other" is a category that groups together small product types. Therefore, I suggest removing the "other" typology for further analysis.
11. I assumed that the product_sku column contains only numerical values. Therefore, I removed any alphabetical characters from that column.
12. To determine how long it takes for a store to adopt our devices, I calculated the average time for a store to perform its first five transactions. I used the happened_at timestamp from the transaction table. The average time for a store to make its first transaction is 243 days, or approximately 8 months.
13. Descriptions and tests for all columns are provided in the `fct.yml`, `dim.yml`, and `intermediate.yml` files.


# Tables to Answer Business Questions

1. Top 10 stores per transacted amount: fct_top_10_stores_per_transacted_amount.sql
2. Top 10 products sold: fct_top_10_products_sold.sql
3. Average transaction amount per store typology and country: fct_avg_transaction_amount_per_typology_and_country.sql
4. Percentage of transactions per device type: fct_transaction_per_device_type.sql
5. Average time for a store to perform its first 5 transactions: fct_avg_first_5_transaction_time_per_store.sql