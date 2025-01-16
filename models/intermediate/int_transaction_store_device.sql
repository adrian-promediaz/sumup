{{ config(
       materialized='incremental',
       schema='intermediate',
       incremental_strategy='merge',
       unique_key = 'transaction_id'
   )
}}


with

transactions as (
    select * from {{ ref("fct_transactions") }}
),

devices as (
    select * from {{ ref("dim_devices") }}
),

stores as (
    select * from {{ ref("dim_stores") }}
),

final as (

    select

        transactions.id as transaction_id,
        transactions.amount as transaction_amount,
        transactions.status as transaction_status,
        transactions.created_at as transaction_created_at,
        transactions.happened_at as transaction_happened_at,
        transactions.product_name,
        transactions.product_sku,
        stores.country as store_country,
        stores.typology as store_typology,
        devices.type as device_type,
        stores.id as store_id,
        stores.name as store_name

    from transactions
    join devices
        on transactions.device_id = devices.id
    join stores
        on devices.store_id = stores.id

)

select * from final

{% if is_incremental() %}


-- this filter will only be applied on an incremental run
-- (uses >= to include records arriving later on the same day as the last run of this model)
where transaction_created_at >= (select max(transaction_created_at) from {{ this }})

{% endif %}
