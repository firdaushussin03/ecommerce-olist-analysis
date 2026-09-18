import pandas as pd
from getpass import getpass
from sqlalchemy import create_engine, URL

engine = create_engine(
    URL.create(
        drivername="mysql+pymysql",
        username="root",
        password=getpass("Enter your MySQL password: "),
        host="localhost",
        port=3306,
        database="olist_project",
    )
)

files = {
    "orders": "dataset/olist_orders_dataset.csv",
    "order_items": "dataset/olist_order_items_dataset.csv",
    "customers": "dataset/olist_customers_dataset.csv",
    "products": "dataset/olist_products_dataset.csv",
    "payments": "dataset/olist_order_payments_dataset.csv",
    "reviews": "dataset/olist_order_reviews_dataset.csv",
    "sellers": "dataset/olist_sellers_dataset.csv",
    "category_translation": "dataset/product_category_name_translation.csv"
}

date_columns = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ],
    "reviews": [
        "review_creation_date",
        "review_answer_timestamp"
    ]
}

for table_name, file_path in files.items():
    df = pd.read_csv(file_path)

    if table_name in date_columns:
        for col in date_columns[table_name]:
            df[col] = pd.to_datetime(df[col], errors="coerce")

    df.to_sql(table_name, con=engine, if_exists="replace", index=False)
    print(f"{table_name} imported successfully")
