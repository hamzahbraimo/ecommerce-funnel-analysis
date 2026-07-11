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



# execution function
def main():
    df = load()
    conn = connect()
    cursor = get_cursor(conn)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An error occurred: {e}")