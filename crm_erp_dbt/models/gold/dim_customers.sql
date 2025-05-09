{{ config(materialized='view') }}

SELECT * FROM "master"."gold"."dim_products"
LIMIT 20