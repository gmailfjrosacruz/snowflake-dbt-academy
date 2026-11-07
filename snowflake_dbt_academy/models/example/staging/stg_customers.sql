WITH 
    source_data AS (
        SELECT *
        FROM {{source('raw_data', 'customers')}} 
    ),
    country_map AS (
        SELECT *
        FROM {{ref('country_mapping')}} 
    ),
    cleaned_data AS (
        SELECT
            c.customer_id::INTEGER AS customer_id,
            TRIM(UPPER(c.first_name)) AS first_name,
            TRIM(UPPER(c.last_name)) AS last_name,
            TRIM(LOWER(c.email)) AS email,
            COALESCE(c.phone, 'N/A') AS phone_number,
            TRIM(UPPER(c.country)) AS country_code,
            COALESCE(cm.country_code, TRIM(UPPER(c.country))) AS country_standardized,
            c.created_at::TIMESTAMPNTZ AS created_at
        FROM source_data c
        LEFT JOIN country_map cm
            ON TRIM(UPPER(c.country)) = UPPER(cm.country_raw)

        WHERE c.created_at IS NOT NULL
        AND c.email IS NOT NULL
        AND c.email LIKE '%@%'
        QUALIFY row_number() OVER (
            PARTITION BY TRIM(LOWER(c.email)) 
            ORDER BY c.created_at DESC
        ) = 1
    )

SELECT 
    * 
FROM cleaned_data
