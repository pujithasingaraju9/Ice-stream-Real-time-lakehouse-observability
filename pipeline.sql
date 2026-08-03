-- =====================================================
-- MEMBER 2: KAFKA -> FLINK -> ICEBERG
-- =====================================================

SET 'execution.runtime-mode' = 'streaming';
SET 'execution.checkpointing.interval' = '10 s';


-- =====================================================
-- 1. READ JSON MESSAGES FROM KAFKA TOPIC: orders
-- =====================================================

CREATE TABLE kafka_orders (
    raw_message STRING
)
WITH (
    'connector' = 'kafka',
    'topic' = 'orders',
    'properties.bootstrap.servers' = 'broker:19092',
    'properties.group.id' = 'member2-flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'raw',
    'raw.charset' = 'UTF-8'
);


-- =====================================================
-- 2. EXTRACT AND TRANSFORM JSON VALUES
-- =====================================================

CREATE TEMPORARY VIEW transformed_orders AS
SELECT
    COALESCE(
        JSON_VALUE(raw_message, '$.transaction_id'),
        JSON_VALUE(raw_message, '$.order_id')
    ) AS transaction_id,

    JSON_VALUE(
        raw_message,
        '$.customer_id'
    ) AS customer_id,

    COALESCE(
        JSON_VALUE(raw_message, '$.product'),
        JSON_VALUE(raw_message, '$.product_name'),
        JSON_VALUE(raw_message, '$.product_id')
    ) AS product,

    COALESCE(
        TRY_CAST(
            JSON_VALUE(raw_message, '$.quantity')
            AS INT
        ),
        1
    ) AS quantity,

    COALESCE(
        TRY_CAST(
            JSON_VALUE(raw_message, '$.total_amount')
            AS DOUBLE
        ),

        TRY_CAST(
            JSON_VALUE(raw_message, '$.amount')
            AS DOUBLE
        ),

        TRY_CAST(
            JSON_VALUE(raw_message, '$.price')
            AS DOUBLE
        )
        *
        COALESCE(
            TRY_CAST(
                JSON_VALUE(raw_message, '$.quantity')
                AS INT
            ),
            1
        )
    ) AS transaction_amount,

    COALESCE(
        JSON_VALUE(raw_message, '$.timestamp'),
        JSON_VALUE(raw_message, '$.event_time')
    ) AS event_time,

    raw_message

FROM kafka_orders;


-- =====================================================
-- 3. CREATE ICEBERG CATALOG
-- =====================================================

CREATE CATALOG iceberg_catalog
WITH (
    'type' = 'iceberg',
    'catalog-type' = 'hadoop',
    'warehouse' = 'file:///opt/flink/warehouse'
);


-- =====================================================
-- 4. CREATE ICEBERG DATABASE
-- =====================================================

CREATE DATABASE IF NOT EXISTS
iceberg_catalog.icestream;


-- =====================================================
-- 5. CREATE ICEBERG TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS
iceberg_catalog.icestream.orders (
    transaction_id STRING,
    customer_id STRING,
    product STRING,
    quantity INT,
    amount DOUBLE,
    transaction_status STRING,
    event_time STRING,
    raw_json STRING,
    processed_at TIMESTAMP(3)
);


-- =====================================================
-- 6. SAVE TRANSFORMED DATA TO ICEBERG
-- =====================================================

INSERT INTO iceberg_catalog.icestream.orders
SELECT
    transaction_id,
    customer_id,
    product,
    quantity,

    ROUND(
        transaction_amount,
        2
    ) AS amount,

    CASE
        WHEN transaction_amount >= 50000 THEN 'HIGH'
        WHEN transaction_amount >= 10000 THEN 'NORMAL'
        ELSE 'LOW'
    END AS transaction_status,

    event_time,
    raw_message AS raw_json,

    CAST(
        CURRENT_TIMESTAMP
        AS TIMESTAMP(3)
    ) AS processed_at

FROM transformed_orders

WHERE transaction_id IS NOT NULL
  AND transaction_amount IS NOT NULL
  AND transaction_amount >= 0;