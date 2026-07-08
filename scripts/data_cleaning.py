import pandas as pd

# reading the csv file
df = pd.read_csv('data/ecommerce_sample.csv')

# details of the dataset
print(df.info())

# columns containing null values
print(df.isnull())

# DATA CLEANING
# dropping duplicates
df.drop_duplicates()

# since there are only two columns with null values, replacing them with 'unknown' value
df['category_code'] = df['category_code'].fillna('unknown')
df['brand'] = df['brand'].fillna('unknown').str.capitalize()

# adding a new column for category
df['category'] = df['category_code'].str.split('.').str[0]

# converting the date column to datetime format
df['event_time'] = pd.to_datetime(df['event_time'].str.replace(' UTC', ''))

# checking 
print(df.tail())

# SAVING
# saving the clean data
df.to_csv('data/ecommerce_sample_clean.csv', index=False)