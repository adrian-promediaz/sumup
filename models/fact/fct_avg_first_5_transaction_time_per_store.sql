{{ config(schema="fact", materialized="table") }}


with

intermediate as (
    select * from {{ ref('int_accepted_transaction_store_device') }}
),

store_transaction as (

    select

        store_id,
        transaction_happened_at

    from intermediate

),

first_and_fifth_transactions as (

    select
        *,
        -- Determining the time when the fifth transaction occurred.
        lead(transaction_happened_at, 4)
            over (partition by store_id order by transaction_happened_at)
            as fifth_transaction_happened_at,
        -- Calculating the difference in days between the first and the fifth transactions.
        datediff(day, transaction_happened_at, fifth_transaction_happened_at)
            as day_diff_first_five_transaction
    from store_transaction
    -- Considering only the first transaction to calculate the time difference between the first and fifth transactions.
    qualify
        rank() over (partition by store_id order by transaction_happened_at) = 1


),

final as (

    select
        avg(day_diff_first_five_transaction)
            as avg_day_diff_first_five_transaction
    from first_and_fifth_transactions
    where
    -- Removing records with null values.
        day_diff_first_five_transaction is not null

)

select * from final
