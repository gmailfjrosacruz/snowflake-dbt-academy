WITH 
    source_data AS (
        SELECT *
        FROM {{source('raw_data', 'orders')}} 
    ),
    order_status_map AS (
        SELECT *
        FROM {{ref('order_status_mapping')}} 
    ),
    cleaned_data AS (
        SELECT
            o.order_id::INTEGER AS order_id,
            o.customer_id::INTEGER AS customer_id,
            o.order_date::DATE AS order_date,
            TRIM(UPPER(o.status)) AS order_status,
            TRIM(UPPER(o.shipping_method)) AS shipping_method,
            COALESCE(om.order_status_code, 'other') AS order_status_clean
        FROM source_data o
        LEFT JOIN order_status_map om
            ON TRIM(UPPER(o.status)) = UPPER(om.order_status_raw)
        WHERE o.order_date >= '2020-01-01' AND o.order_date < DATEADD('month', 1, DATE_TRUNC('month', CURRENT_DATE()))
    ) 

SELECT 
    * 
FROM cleaned_data
