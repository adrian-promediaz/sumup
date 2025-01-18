-- A table containing the IDs of devices, their types, and associated stores.
{{ config(
    schema="mart_devices",
    materialized="table")
}}

with

source as (

    select *
    from {{ source('sheet', 'device') }}

)

select * from source