-- This table contains information about stores that belong to customers.
{{ config(
    schema="mart_stores",
    materialized="table")
}}

with

source as (

    select *
    from {{ source('sheet', 'store') }}

)

select * from source