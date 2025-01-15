{{ config(schema="fact", materialized="table") }}


with

intermediate as (

    select * from {{ ref('int_transaction_store_device') }}
    where 
        -- We only focuses on the accepted transaction
        transaction_status = 'accepted'

),

avg_accepted_transaction as (

    select 
        store_country,
        store_typology,
        avg(transaction_amount) as transaction_amount
    from intermediate
    group by
        store_country,
        store_typology

),


final as (

    select * from avg_accepted_transaction

)

select * from final
order by transaction_amount desc