-- This table contains the information of the Devices
{{ config(
    schema='dim',
    materialized='table')
}}

with

source as (

    select *
    from {{ source('sheet', 'device') }}

)

select * from source