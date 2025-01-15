{{ config(schema="fact", materialized="table") }}


with

intermediate as (

    select * from {{ ref('int_transaction_store_device') }}
    where 
        -- We only focuses on the accepted transaction
        transaction_status = 'accepted'

),

total_transaction_amount as (

    select 
        sum(transaction_amount) as total_transaction_amount
    from intermediate

),

sum_accepted_transaction as (

    select 
        device_type,
        sum(transaction_amount) as transaction_amount
    from intermediate
    group by
        device_type

),

percentage_transaction_per_device_type as (

    select

        sum_accepted_transaction.device_type,
        sum_accepted_transaction.transaction_amount,
        sum_accepted_transaction.transaction_amount / total_transaction_amount.total_transaction_amount as percentage_transaction

    from sum_accepted_transaction, total_transaction_amount

),

final as (

    select * from percentage_transaction_per_device_type

)

select * from final
order by percentage_transaction desc