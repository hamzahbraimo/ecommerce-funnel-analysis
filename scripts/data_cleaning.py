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

# since we have only two columns with null values, replacing them with 'Unknown' value
df['category_code'] = df['category_code'].fillna('unknown')
df['brand'] = df['brand'].fillna('unknown')

# checking 
print(df.tail())

# SAVING
# saving the clean data
df.to_csv('data/ecommerce_sample_clean.csv', index=False)