{{
    config(schema="mart_stores", 
    materialized="table")
}}


with

intermediate as (
    select * from {{ ref('int_accepted_transaction_store_device') }}
),

sum_accepted_transaction as (

    select 
        store_id,
        store_name,
        sum(transaction_amount) as transaction_amount
    from intermediate
    group by
        store_id,
        store_name

),

ordering_transaction as (

    select
        *,
       rank() over (order by transaction_amount desc) as rank
    from sum_accepted_transaction

),

final as (

    select * exclude (rank) from ordering_transaction
    where 
        -- limit the top 10
        rank <= 10

)

select * from final
order by transaction_amount desc