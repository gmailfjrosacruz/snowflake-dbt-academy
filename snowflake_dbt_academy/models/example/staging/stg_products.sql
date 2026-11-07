WITH 
    source_data AS (
        SELECT *
        FROM {{source('raw_data', 'products')}} 
    ),
    product_department_map AS (
        SELECT *
        FROM {{ref('product_department_mapping')}} 
    ),
    cleaned_data AS (
        SELECT
            pr.product_name,
            pr.category AS product_category,
            pr.subcategory AS product_subcategory,
            COALESCE(pdm.product_department_code, 'Other') AS product_department
        FROM source_data pr
        LEFT JOIN product_department_map pdm
            ON TRIM(UPPER(pr.category)) = UPPER(pdm.product_department_raw)
    )

SELECT 
    * 
FROM cleaned_data