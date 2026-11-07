WITH 
    source_data AS (
        SELECT *
        FROM {{source('raw_data', 'line_items')}} 
    ),
    cleaned_data AS (        
        SELECT
            li.order_id::INTEGER AS order_id,
            li.product_id::INTEGER AS product_id,
            li.quantity::numeric(10,2) AS quantity,
            li.unit_price::numeric(10,2) AS unit_price,
            li.quantity::numeric(10,2) * li.unit_price::numeric(10,2) AS line_total,
            li.discount_pct::numeric(10,2) AS discount_pct,
            li.quantity::numeric(10,2) * li.unit_price::numeric(10,2) * (1 - COALESCE(li.discount_pct::numeric(10,2), 0) / 100) AS line_total_after_discount
        FROM source_data li
    )

SELECT 
    * 
FROM cleaned_data
            
