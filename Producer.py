from kafka import KafkaProducer
from transaction_generator import generate_transaction
from config import KAFKA_BROKER, TOPIC_NAME, STREAM_DELAY

import json
import time

# Create Kafka Producer
producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

order_id = 1

print("🚀 Starting Kafka Producer...")

try:
    while True:
        transaction = generate_transaction(order_id)

        producer.send(TOPIC_NAME, transaction)
        producer.flush()   # Send immediately

        print(transaction)

        order_id += 1
        time.sleep(STREAM_DELAY)

except KeyboardInterrupt:
    print("\n🛑 Producer stopped.")

finally:
    producer.close()