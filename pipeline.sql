-- =============================================================
-- ICESTREAM - MEMBER 2
-- NEW ARCHITECTURE
--
-- Member 1 orders
--      -> Member 2 Flink transformation
--      -> transformed-orders
--      -> Member 3 validation
--      -> validated-orders (VALID records only)
--      -> Member 2 Flink
--      -> Apache Iceberg
-- =============================================================

SET 'execution.runtime-mode' = 'streaming';
SET 'execution.checkpointing.interval' = '10 s';


-- =============================================================
-- 1. MEMBER 1 -> MEMBER 2
-- Read raw JSON messages from Kafka topic: orders
-- =============================================================
CREATE TABLE kafka_orders (
    raw_message STRING
)
WITH (
    'connector' = 'kafka',
    'topic' = 'orders',
    'properties.bootstrap.servers' = 'broker:19092',
    'properties.group.id' = 'member2-orders-reader',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'raw',
    'raw.charset' = 'UTF-8'
);


-- =============================================================
-- 2. BASIC TRANSFORMATION
-- Preserve Member 3's required field names exactly.
-- Also add amount and transaction_status as Member 2 fields.
-- =============================================================
CREATE TEMPORARY VIEW transformed_orders AS
SELECT
    JSON_VALUE(raw_message, '$.order_id') AS order_id,
    JSON_VALUE(raw_message, '$.customer_name') AS customer_name,
    JSON_VALUE(raw_message, '$.product') AS product,

    TRY_CAST(
        JSON_VALUE(raw_message, '$.price') AS DOUBLE
    ) AS price,

    TRY_CAST(
        JSON_VALUE(raw_message, '$.quantity') AS INT
    ) AS quantity,

    JSON_VALUE(raw_message, '$.payment_method') AS payment_method,
    JSON_VALUE(raw_message, '$.city') AS city,
    JSON_VALUE(raw_message, '$.order_status') AS order_status,
    JSON_VALUE(raw_message, '$.timestamp') AS `timestamp`,

    ROUND(
        TRY_CAST(JSON_VALUE(raw_message, '$.price') AS DOUBLE)
        *
        TRY_CAST(JSON_VALUE(raw_message, '$.quantity') AS INT),
        2
    ) AS amount,

    CASE
        WHEN
            TRY_CAST(JSON_VALUE(raw_message, '$.price') AS DOUBLE)
            * TRY_CAST(JSON_VALUE(raw_message, '$.quantity') AS INT)
            >= 50000
        THEN 'HIGH'

        WHEN
            TRY_CAST(JSON_VALUE(raw_message, '$.price') AS DOUBLE)
            * TRY_CAST(JSON_VALUE(raw_message, '$.quantity') AS INT)
            >= 10000
        THEN 'NORMAL'

        ELSE 'LOW'
    END AS transaction_status

FROM kafka_orders;


-- =============================================================
-- 3. MEMBER 2 -> MEMBER 3
-- Kafka sink containing transformed records that Member 3 validates.
-- =============================================================
CREATE TABLE transformed_orders_sink (
    order_id STRING,
    customer_name STRING,
    product STRING,
    price DOUBLE,
    quantity INT,
    payment_method STRING,
    city STRING,
    order_status STRING,
    `timestamp` STRING,
    amount DOUBLE,
    transaction_status STRING
)
WITH (
    'connector' = 'kafka',
    'topic' = 'transformed-orders',
    'properties.bootstrap.servers' = 'broker:19092',
    'format' = 'json'
);


-- =============================================================
-- 4. MEMBER 3 -> MEMBER 2
-- Member 3 must publish ONLY VALID records to validated-orders.
-- =============================================================
CREATE TABLE validated_orders_source (
    order_id STRING,
    customer_name STRING,
    product STRING,
    price DOUBLE,
    quantity INT,
    payment_method STRING,
    city STRING,
    order_status STRING,
    `timestamp` STRING,
    amount DOUBLE,
    transaction_status STRING
)
WITH (
    'connector' = 'kafka',
    'topic' = 'validated-orders',
    'properties.bootstrap.servers' = 'broker:19092',
    'properties.group.id' = 'member2-validated-reader',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);


-- =============================================================
-- 5. CREATE ICEBERG CATALOG
-- =============================================================
CREATE CATALOG iceberg_catalog
WITH (
    'type' = 'iceberg',
    'catalog-type' = 'hadoop',
    'warehouse' = 'file:///opt/flink/warehouse'
);


-- =============================================================
-- 6. CREATE ICEBERG DATABASE
-- =============================================================
CREATE DATABASE IF NOT EXISTS iceberg_catalog.icestream;


-- =============================================================
-- 7. CREATE ICEBERG TABLE
-- Only VALID records from Member 3 are stored here.
-- =============================================================
CREATE TABLE IF NOT EXISTS iceberg_catalog.icestream.orders (
    order_id STRING,
    customer_name STRING,
    product STRING,
    price DOUBLE,
    quantity INT,
    payment_method STRING,
    city STRING,
    order_status STRING,
    `timestamp` STRING,
    amount DOUBLE,
    transaction_status STRING,
    processed_at TIMESTAMP(3)
);


-- =============================================================
-- 8. START BOTH MEMBER 2 STREAMING JOBS
--
-- Job A: orders -> transform -> transformed-orders
-- Job B: validated-orders -> Iceberg
-- =============================================================
EXECUTE STATEMENT SET
BEGIN

    INSERT INTO transformed_orders_sink
    SELECT
        order_id,
        customer_name,
        product,
        price,
        quantity,
        payment_method,
        city,
        order_status,
        `timestamp`,
        amount,
        transaction_status
    FROM transformed_orders;

    INSERT INTO iceberg_catalog.icestream.orders
    SELECT
        order_id,
        customer_name,
        product,
        price,
        quantity,
        payment_method,
        city,
        order_status,
        `timestamp`,
        amount,
        transaction_status,
        CAST(CURRENT_TIMESTAMP AS TIMESTAMP(3)) AS processed_at
    FROM validated_orders_source;

END;
