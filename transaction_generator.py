from faker import Faker
import random
from datetime import datetime

fake = Faker()

products = [
    "Laptop",
    "Smartphone",
    "Headphones",
    "Keyboard",
    "Mouse",
    "Monitor",
    "Smart Watch",
    "Camera"
]

payment_methods = [
    "UPI",
    "Credit Card",
    "Debit Card",
    "Cash on Delivery",
    "Net Banking"
]

cities = [
    "Kochi",
    "Trivandrum",
    "Bangalore",
    "Chennai",
    "Mumbai",
    "Hyderabad"
]


def generate_transaction(order_id):

    transaction = {
        "order_id": order_id,
        "customer_name": fake.name(),
        "product": random.choice(products),
        "price": random.randint(500, 100000),
        "quantity": random.randint(1, 5),
        "payment_method": random.choice(payment_methods),
        "city": random.choice(cities),
        "order_status": random.choice([
    "Placed",
    "Packed",
    "Shipped",
    "Delivered"
]),
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

    # Introduce bad records occasionally (10%)
    if random.randint(1, 10) == 1:

        error = random.choice([
            "negative_price",
            "missing_customer",
            "zero_quantity"
        ])

        if error == "negative_price":
            transaction["price"] = -random.randint(100, 5000)

        elif error == "missing_customer":
            transaction["customer_name"] = None

        elif error == "zero_quantity":
            transaction["quantity"] = 0

    return transaction