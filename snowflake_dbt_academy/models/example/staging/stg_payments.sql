WITH 
    source_data AS (
        SELECT *
        FROM {{source('raw_data', 'payments')}} 
    ),  
    payment_method_map AS (
        SELECT *
        FROM {{ref('payment_method_mapping')}} 
    ),  
    cleaned_data AS (
        SELECT
            p.payment_id::INTEGER AS payment_id,
            TRIM(UPPER(p.payment_method)) AS payment_method,
            COALESCE(p.amount::numeric(10,2), 0.00) AS payment_amount,
            COALESCE(pm.payment_method_code, 'other') AS payment_method_clean,
            TRIM(UPPER(p.status)) AS payment_status
    FROM source_data p
        LEFT JOIN payment_method_map pm
            ON TRIM(UPPER(p.payment_method)) = UPPER(pm.payment_method_raw)
    ) 

SELECT 
    * 
FROM cleaned_data