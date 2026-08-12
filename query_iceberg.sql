-- Query the final validated orders stored in Iceberg
SET 'execution.runtime-mode' = 'batch';
SET 'sql-client.execution.result-mode' = 'tableau';

CREATE CATALOG iceberg_catalog
WITH (
    'type' = 'iceberg',
    'catalog-type' = 'hadoop',
    'warehouse' = 'file:///opt/flink/warehouse'
);

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
    processed_at
FROM iceberg_catalog.icestream.orders;
