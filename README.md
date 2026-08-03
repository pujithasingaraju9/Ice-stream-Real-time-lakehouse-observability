# IceStream - Member 1 (Kafka Producer)

## Description

This module generates fake e-commerce transaction data and streams it to Apache Kafka.

---

## Technologies Used

- Python
- Apache Kafka
- Docker
- Faker
- kafka-python

---

## Project Structure

```
Producer.py
transaction_generator.py
config.py
sample_transactions.json
requirements.txt
README.md
```

---

## Installation

Install dependencies

```bash
pip install -r requirements.txt
```

Start Kafka

```bash
docker start kafka
```

Run Producer

```bash
python Producer.py
```

---

## Kafka Configuration

Broker

```
localhost:9092
```

Topic

```
orders
```

---

## Output

The producer continuously streams fake transaction records to Kafka.

Some records intentionally contain errors such as

- Negative price
- Missing customer name
- Zero quantity

These are used for testing downstream data validation.