-- "A fact table of containing all transactions with the following assumption:
--  A payment made using the provided devices, currently our devices only handle payments made by card and in euros. 
-- Those transactions are made to pay for products sold inside the store, each product has a name and a SKU (stock keeping unit) which is unique."

{{ config(
       materialized='incremental',
       schema='fact',
       incremental_strategy='merge',
       unique_key = 'id'
   )
}}

with

source as (

    select
    -- We remove the card number and CVV as they are PII data and would not be used in any downstream tables
        * exclude (card_number, cvv)
    from {{ source('sheet', 'transaction') }}

)


select * from source

{% if is_incremental() %}


-- this filter will only be applied on an incremental run
-- (uses >= to include records arriving later on the same day as the last run of this model)
where created_at >= (select max(created_at) from {{ this }})

{% endif %}
