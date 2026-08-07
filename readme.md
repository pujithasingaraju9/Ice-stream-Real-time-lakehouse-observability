IceStream - Member 2

Role

Member 2 is responsible for Apache Flink stream processing and storing only validated records in Apache Iceberg.

Final Architecture

Member 1
Kafka Producer
    |
    v
Kafka topic: orders
    |
    v
Member 2
Apache Flink
- Read Kafka stream
- Parse JSON
- Basic transformation
    |
    v
Kafka topic: transformed-orders
    |
    v
Member 3
- Great Expectations / Validation
- Circuit Breaker
- DLQ
- Alert API
    |
    v
Valid?
 /    \
Yes    No
 |      |
 v      v
validated-orders   DLQ + Alert
 |
 v
Member 2
Apache Flink
 |
 v
Apache Iceberg
 |
 v
Member 4 Dashboard

Member 2 Responsibilities

Read raw transaction data from Kafka topic orders.

Perform basic transformation using Apache Flink.

Publish transformed records to Kafka topic transformed-orders.

Do not store unvalidated records directly in Iceberg.

Read validated records from Kafka topic validated-orders.

Store only validated records in Apache Iceberg.

Kafka Topics

orders - Member 1 to Member 2

transformed-orders - Member 2 to Member 3

validated-orders - Member 3 to Member 2

Important Fields

Member 2 preserves the fields required by Member 3 validation:

order_id

customer_name

product

price

quantity

payment_method

city

order_status

timestamp

Member 2 may also add transformation fields such as:

amount

transaction_status

Folder Structure

mem 2/
|
|-- docker-compose.yml
|-- commands.txt
|-- README.md
|-- flink/
|   `-- pipeline.sql
`-- iceberg/
    `-- warehouse/

How To Run

Open PowerShell inside the Member 2 folder.

docker compose up -d

Check containers:

docker compose ps -a

Check Kafka topics:

docker compose exec broker /opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:19092 --list

Start the Flink pipeline:

docker compose exec jobmanager ./bin/sql-client.sh -f /opt/flink/sql/pipeline.sql

Check the Flink job:

docker compose exec jobmanager ./bin/flink list

Then run Member 1 producer in another terminal.

Member 2 will read from orders, transform the data, and publish to transformed-orders.

Member 3 must then validate the records and publish valid records to validated-orders.

Member 2 reads validated-orders and stores only those valid records in Iceberg.

Check Transformed Records

docker compose exec broker /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:19092 --topic transformed-orders --from-beginning

Check Validated Records

docker compose exec broker /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server broker:19092 --topic validated-orders --from-beginning

Check Iceberg Files

docker compose exec taskmanager bash -c "find /opt/flink/warehouse -type f"

Stop Project

docker compose down

Full Reset

docker compose down -v

If old Iceberg files must be removed:

Remove-Item -Recurse -Force .\iceberg\warehouse\*

Then restart:

docker compose up -d

Important Note

Iceberg will not receive data immediately after Member 1 produces transactions.

The correct sequence is:

Member 1
  -> Member 2 transformation
  -> Member 3 validation
  -> valid records
  -> Member 2 Iceberg storage

This matches the final project architecture.