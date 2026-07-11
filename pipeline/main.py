import pandas as pd
import mysql.connector
from dotenv import load_dotenv
import os

# paths
FILE_PATH = './data/ecommerce_sample_clean.csv'
DOTENV_PATH = './.env'

# load the dataset
def load():

    df = pd.read_csv(FILE_PATH, parse_dates=['event_time'])

    print("Dataset loaded successfully.")

    return df

# connect to the database
def connect():

    load_dotenv(DOTENV_PATH)

    conn = mysql.connector.connect(
        host=os.getenv('DB_HOST'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        database=os.getenv('DB_NAME')
    )

    print("Connected to the database.")
    
    return conn

# cursor
def get_cursor(conn):
    
    cursor = conn.cursor()
    
    print("Cursor created.")

    return cursor

# table
def create_table(cursor):
    create_table_query = """
    CREATE TABLE IF NOT EXISTS events (
        event_time DATETIME,
        event_type VARCHAR(50),
        product_id BIGINT,
        category_id BIGINT,
        category_code VARCHAR(100),
        brand VARCHAR(100),
        price FLOAT,
        user_id VARCHAR(100),
        user_session VARCHAR(100),
        category VARCHAR(100),

        PRIMARY KEY (event_time, user_id, product_id)
    );
    """

    cursor.execute(create_table_query)
    print("Table created successfully.")

# rows
def insert_rows(cursor, df):
    insert_query = """
    INSERT INTO events
        (event_time, event_type, product_id, category_id, category_code, brand, price, user_id, user_session, category)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON DUPLICATE KEY UPDATE
        event_type=VALUES(event_type),
        category_code=VALUES(category_code),
        brand=VALUES(brand),
        price=VALUES(price),
        user_session=VALUES(user_session),
        category=VALUES(category);
    """

    print("Inserting rows into the table...")

    chunk_size = 10000
    
    for i in range(0, len(df), chunk_size):
        chunk = df.iloc[i:i+chunk_size]
        values = [tuple(row) for index, row in chunk.iterrows()]
        cursor.executemany(insert_query, values)
        print(f"Inserted rows {i} to {i + len(chunk)}")

    print(f"Rows inserted successfully. (Total: {cursor.rowcount})")

# execution function
def main():
    df = load()
    conn = connect()
    cursor = get_cursor(conn)
    create_table(cursor)
    insert_rows(cursor, df)

    conn.commit()
    cursor.close()
    conn.close()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An error occurred: {e}")