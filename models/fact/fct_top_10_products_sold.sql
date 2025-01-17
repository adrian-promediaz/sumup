{{ config(schema="fact", materialized="table") }}


with

intermediate as (
    select * from {{ ref('int_accepted_transaction_store_device') }}
),

sum_accepted_transaction as (

    select 
        product_sku,
        sum(transaction_amount) as transaction_amount
    from intermediate
    group by
        product_sku

),

ordering_transaction as (

    select
        *,
        rank() over (order by transaction_amount desc) as rank
    from sum_accepted_transaction


),

final as (

    select * exclude(rank) from ordering_transaction
    where 
        -- limit the top 10
        rank <= 10

)

select * from final
order by transaction_amount desc