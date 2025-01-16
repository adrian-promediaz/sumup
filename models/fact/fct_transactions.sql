-- "A fact table of containing all transactions with the following assumption:
--  A payment made using the provided devices, currently our devices only handle payments made by card and in euros. 
-- Those transactions are made to pay for products sold inside the store, each product has a name and a SKU (stock keeping unit) which is unique."
-- We materialize this object incrementally, as an incremental table is scalable enough to handle billions of records while keeping computing costs low.
{{ config(
       materialized='incremental',
       schema='fact',
       incremental_strategy='merge',
       unique_key = 'id'
   )
}}

with

source_and_transformed as (

    select
    -- We remove the card number and CVV as they are personally identifiable information (PII) and will not be used in any downstream tables.
    -- The product stock-keeping unit (SKU) of the product is assumed to contain only numerical values.
        * exclude (card_number, cvv, product_sku),
        regexp_replace(product_sku, '[^\\d]*', '') as product_sku
    from {{ source('sheet', 'transaction') }}

)

select * from source_and_transformed

{% if is_incremental() %}


-- this filter will only be applied on an incremental run
-- (uses >= to include records arriving later on the same day as the last run of this model)
where created_at >= (select max(created_at) from {{ this }})

{% endif %}
