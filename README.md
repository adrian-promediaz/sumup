# Implementation Details

1. The raw tables, including `store.csv`, `device.csv`, and `transaction.csv`, are stored in the `SUMUP_SOURCE` database under the `SHEET` schema in Snowflake.
2. I created the `dim_stores` and `dim_devices` tables to represent `store.csv` and `device.csv`, respectively. I also created the `fct_transactions` table to represent `transaction.csv`. These dimension tables and the fact table are stored in the `SUMUP_REPORTING` database.
3. The dimension and fact tables are organized under various mart schemas in Snowflake. The schemas `MART_DEVICES`, `MART_PRODUCTS`, `MART_STORES`, and `MART_TRANSACTIONS` contain all dimension and fact tables related to devices, products, stores, and transactions, respectively.
4. I created an intermediate table combining the transaction table, device, and store information. This intermediate table was then used to build the fact tables that answer the key business questions. The intermediate table is stored in the SUMUP_REPORTING database and the intermediate schema.
5. Images illustrating the DBT lineage and the Snowflake data structure can be found in the assets folder.
6. Descriptions and tests for all columns are provided in the `fct.yml`, `dim.yml`, and `intermediate.yml` files.

# Assumptions

1. I anticipate that the transaction table will contain billions of records in the future. Therefore, I materialized the fct_transactions table as an incremental table. Incremental tables are scalable enough to handle billions of records while keeping computing costs low. Typically, I use the updated_at column as the filter for incremental runs. However, in this case, I used the created_at column, assuming that it is updated whenever the record is modified.
2. In the transaction table, out of 1,500 records, 1,274 have happened_at before `created_at`, and 226 have happened_at after `created_at`. I assume that happened_at represents the timestamp when the transactions occurred, while created_at represents the timestamp when the record was created in the transaction table. For the records where `happened_at` is before `created_at`, I found that the average difference between `created_at` and `happened_at` is 222 days. It is unclear why such a large difference exists.
3. I removed the card number and CVV from the data, as they are personally identifiable information (PII) and will not be used in any downstream tables.
4. The relationship between `product_sku`, `product_name`, and `category_name` is many-to-many. However, I assume that `product_sku` is the most granular dimension for each product. Therefore, I used product_sku to calculate the top 10 products. It may be worth further investigating the product_sku alongside other product information.
5. For analysis purposes, I assumed that only accepted or successful transactions are relevant. I applied this filter in the intermediate table.
6. I found that some countries with the "other" typology have high average transaction amounts. I believe that "other" is a category that groups together small product types. Therefore, I suggest removing the "other" typology for further analysis.
7. I assumed that the product_sku column contains only numerical values. Therefore, I removed any alphabetical characters from that column.
8. To determine how long it takes for a store to adopt our devices, I calculated the average time for a store to perform its first five transactions. I used the happened_at timestamp from the transaction table. The average time for a store to make its first transaction is 243 days, or approximately 8 months.


# Tables to Answer Business Questions

1. Top 10 stores per transacted amount: fct_top_10_stores_per_transacted_amount.sql
2. Top 10 products sold: fct_top_10_products_sold.sql
3. Average transaction amount per store typology and country: fct_avg_transaction_amount_per_store_typology_and_country.sql
4. Percentage of transactions per device type: fct_transaction_per_device_type.sql
5. Average time for a store to perform its first 5 transactions: fct_avg_first_5_transaction_time_per_store.sql


# DBT Job Design
1. Assuming the transaction data is sourced from the database and real-time data is not required, we can schedule the DBT job to run daily. This ensures that all fact tables are updated every day.
2. Assuming the device and store data does not change frequently, we can also schedule the DBT job to run daily to ensure that all device and store data remains up-to-date.
