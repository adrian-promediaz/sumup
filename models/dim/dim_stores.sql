-- This table contains the information of the Stores belong to customers
{{ config(
    schema='dim',
    materialized='table')
}}

with

source as (

    select *
    from {{ source('sheet', 'store') }}

)

select * from source