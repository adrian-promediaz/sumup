{{ config(schema="fact", materialized="table") }}


with

intermediate as (

    select * from {{ ref('int_transaction_store_device') }}
    where 
        -- We only focuses on the accepted transaction
        transaction_status = 'accepted'

),

store_transaction as (

    select

        store_id,
        transaction_happened_at,
        count (transaction_happened_at) over (partition by store_id) as number_transactions_per_store,
        rank () over (partition by store_id order by transaction_happened_at) as transaction_rank
    
    from intermediate
    
),

first_and_fifth_transactions as (

    select

        store_id,
        transaction_happened_at,
        transaction_rank

    from store_transaction
    where number_transactions_per_store >= 5
        and transaction_rank in (1,5)

),

day_diff_first_five_transaction as (
    select 
        store_id,
        transaction_happened_at  as first_transaction_happened_at,
        transaction_rank,
        lead(transaction_happened_at) over (partition by store_id order by transaction_happened_at ) as fifth_transaction_happened_at,
        datediff(day, first_transaction_happened_at, fifth_transaction_happened_at) as day_diff_first_five_transaction
    from first_and_fifth_transactions
    order by store_id, transaction_rank

),

final as (

    select 
        avg (day_diff_first_five_transaction) as avg_day_diff_first_five_transaction
    from day_diff_first_five_transaction
    where day_diff_first_five_transaction is not null

    )

select * from final