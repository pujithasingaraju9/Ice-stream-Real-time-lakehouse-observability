ICESTREAM MEMBER 2
Apache Flink + Kafka + Apache Iceberg


========================================
IMPORTANT MEMBER 1 SETTINGS
========================================

Member 1 config.py must contain:

KAFKA_BROKER = "localhost:9092"
TOPIC_NAME = "transactions"

The producer sends messages using:

producer.send(TOPIC_NAME, transaction)


========================================
STEP 1: START DOCKER DESKTOP
========================================

Open Docker Desktop.

Wait until Docker Desktop shows:

Engine running


========================================
STEP 2: OPEN POWERSHELL
========================================

Open PowerShell inside the IceStream_Member2 folder.


========================================
STEP 3: START KAFKA AND FLINK
========================================

Run:

docker compose up -d


Check containers:

docker compose ps


The following containers should be running:

icestream-kafka
icestream-jobmanager
icestream-taskmanager


========================================
STEP 4: OPEN FLINK DASHBOARD
========================================

Open this address in the browser:

http://localhost:8081


========================================
STEP 5: START THE FLINK PIPELINE
========================================

Run:

docker compose exec jobmanager ./bin/sql-client.sh -f /opt/flink/sql/pipeline.sql


The Flink job will:

1. Read JSON messages from Kafka
2. Extract transaction information
3. Remove invalid transactions
4. Add HIGH, NORMAL or LOW status
5. Save the transactions into Iceberg


========================================
STEP 6: RUN MEMBER 1 PRODUCER
========================================

Open another PowerShell window.

Go to the Member 1 folder.

Run:

python producer.py


Example Member 1 output:

Starting Kafka Producer...

{
    "order_id": 1,
    "customer_id": "C101",
    "product": "Laptop",
    "quantity": 1,
    "amount": 60000
}


========================================
TRANSACTION STATUS RULES
========================================

Amount 50000 or above:

HIGH


Amount from 10000 to 49999:

NORMAL


Amount below 10000:

LOW


========================================
STEP 7: CHECK FLINK JOB
========================================

Open:

http://localhost:8081

Select:

Running Jobs

The Kafka to Iceberg job should be visible.


========================================
STEP 8: CHECK ICEBERG DATA
========================================

Run:

docker compose exec jobmanager ./bin/sql-client.sh


Paste the following SQL commands:


CREATE CATALOG iceberg_catalog
WITH (
    'type' = 'iceberg',
    'catalog-type' = 'hadoop',
    'warehouse' = 'file:///opt/flink/warehouse'
);


SET 'execution.runtime-mode' = 'batch';


SELECT *
FROM iceberg_catalog.icestream.transactions;


The saved transactions will be displayed.


========================================
STEP 9: EXIT SQL CLIENT
========================================

Run:

QUIT;


========================================
STEP 10: STOP THE PROJECT
========================================

Run:

docker compose down


To delete everything, including Kafka data:

docker compose down -v


========================================
MEMBER 2 TASKS COMPLETED
========================================

1. Read Kafka messages using Flink

2. Transform transaction data

3. Remove invalid transactions

4. Add HIGH, NORMAL or LOW status

5. Save processed data into Apache Iceberg