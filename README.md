# E-commerce Funnel Analysis
This is a dataset that contains tracks of events from purchases/views/carts

The dataset is available at Kaggle: https://www.kaggle.com/code/mkechinov/ecommerce-data-overview/


<br>

**NOTE:** the .csv file in this contains 5GB+ of data, so it was truncated down to 500K lines. 

*******
# Project structure
```
data/
notebooks/
pipeline/
sql/
.env.example
.gitignore
README.md
```

- `data/`: contains the .csv files (the original dataset and the clean one)
- `notebooks/`: contains `.ipynb` files that clean, organize and explore the data, including visualizations using the following libraries: `pandas`, `matplotlib` and `seaborn`
- `pipeline/`: loads the clean data from the .csv file into a SQL database, using the `MySQL` DBMS, using `Python` and the following libraries: `pandas`, `mysql`, `os` and `dotenv` for `.env` files management.
- `sql/`: queries that create the database for the data load, explore, indexes, answer the business questions and for stored views.
- `.env.example`: guide for the `.env` file creation that stores your local database information such as `username` and `password`.

*****
# How to run
**Requirements:**
1. Install  `Python 3.13+`
2. Install the `Jupyter` extension on your IDE for `.ipynb` files support
3. Install the `MySQL` DBMS
4. Install the following python libraries with the command:
  `pip install pandas matplotlib seaborn mysql-connector-python python-dotenv`
5. Clone the repo:
  `git clone https://github.com/hamzahbraimo/ecommerce-funnel-analysis`
6. Setup your own `.env` based the `.env.example`
7. Run the files in the following order:
   - `notebooks/`: `00_data_cleaning.ipynb` -> `01_data_explore.ipynb`
   - `sql/`: `create-db.sql`
   - `pipeline/`: `main.py`
   - `sql/`: `schema-explore.sql` -> `indexes.sql` -> `questions.sql` -> `views.sql`

*****
# Data Cleaning
Check `notebooks/00_data_cleaning.ipynb`

<br>
Original data:

<table border="1">
  <tr>
    <th>event_time</th>
    <th>event_type</th>
    <th>product_id</th>
    <th>category_id</th>
    <th>category_code</th>
    <th>brand</th>
    <th>price</th>
    <th>user_id</th>
    <th>user_session</th>
  </tr>
  <tr>
    <td>2019-10-01 00:00:00 UTC</td>
    <td>view</td>
    <td>44600062</td>
    <td>2103807459595387724</td>
    <td>NaN</td>
    <td>shiseido</td>
    <td>35.79</td>
    <td>541312140</td>
    <td>72d76fde-8bb3-4e00-8c23-a032dfed738c</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:00 UTC</td>
    <td>view</td>
    <td>3900821</td>
    <td>2053013552326770905</td>
    <td>appliances.environment.water_heater</td>
    <td>aqua</td>
    <td>33.20</td>
    <td>554748717</td>
    <td>9333dfbd-b87a-4708-9857-6336556b0fcc</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:01 UTC</td>
    <td>view</td>
    <td>17200506</td>
    <td>2053013559792632471</td>
    <td>furniture.living_room.sofa</td>
    <td>NaN</td>
    <td>543.10</td>
    <td>519107250</td>
    <td>566511c2-e2e3-422b-b695-cf8e6e792caa8</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:01 UTC</td>
    <td>view</td>
    <td>1307067</td>
    <td>2053013558920217191</td>
    <td>computers.notebook</td>
    <td>lenovo</td>
    <td>251.74</td>
    <td>550050854</td>
    <td>7c90fc70-0e80-4590-96f3-13c0c218c713</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:04 UTC</td>
    <td>view</td>
    <td>1004237</td>
    <td>2053013555631882655</td>
    <td>electronics.smartphone</td>
    <td>apple</td>
    <td>1081.98</td>
    <td>535871217</td>
    <td>c6bd7419-2748-4c56-95b4-8cec9ff8b80d</td>
  </tr>
</table>

<br>

After cleaning the data:
```
df.isnull()
df.drop_duplicates()

df['category_code'] = df['category_code'].fillna('unknown')
df['brand'] = df['brand'].fillna('unknown').str.capitalize()

df['category'] = df['category_code'].str.split('.').str[0]

df['event_time'] = pd.to_datetime(df['event_time'].str.replace(' UTC', ''))

# removing outliers (brand and category with both values 'unknown')

df = df[
    (df['brand'] != 'unknown') &
    (df['category'] != 'unknown')
]
```

<table border="1">
  <tr>
    <th>event_time</th>
    <th>event_type</th>
    <th>product_id</th>
    <th>category_id</th>
    <th>category_code</th>
    <th>brand</th>
    <th>price</th>
    <th>user_id</th>
    <th>user_session</th>
    <th>category</th>
  </tr>
  <tr>
    <td>2019-10-01 00:00:00</td>
    <td>view</td>
    <td>3900821</td>
    <td>2053013552326770905</td>
    <td>appliances.environment.water_heater</td>
    <td>Aqua</td>
    <td>33.20</td>
    <td>554748717</td>
    <td>9333dfbd-b87a-4708-9857-6336556b0fcc</td>
    <td>appliances</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:01</td>
    <td>view</td>
    <td>17200506</td>
    <td>2053013555979232471</td>
    <td>furniture.living_room.sofa</td>
    <td>Unknown</td>
    <td>543.10</td>
    <td>519107250</td>
    <td>566511c2-e2e3-422b-b695-cf8e6e792ca8</td>
    <td>furniture</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:02</td>
    <td>view</td>
    <td>1307067</td>
    <td>20530135558920217191</td>
    <td>computers.notebook</td>
    <td>Lenovo</td>
    <td>251.74</td>
    <td>550050854</td>
    <td>7c90fc70-0e80-4590-96f3-13c02c18c713</td>
    <td>computers</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:04</td>
    <td>view</td>
    <td>1004237</td>
    <td>2053013555631882655</td>
    <td>electronics.smartphone</td>
    <td>Apple</td>
    <td>1081.98</td>
    <td>535871217</td>
    <td>c6bd7419-2748-4c56-95b4-8cec9ff8b80d</td>
    <td>electronics</td>
  </tr>
  <tr>
    <td>2019-10-01 00:00:05</td>
    <td>view</td>
    <td>1480613</td>
    <td>2053013561092866779</td>
    <td>computers.desktop</td>
    <td>Pulser</td>
    <td>908.62</td>
    <td>512742880</td>
    <td>0d0d91c2-c9c2-4e81-90a5-86594dec0db9</td>
    <td>computers</td>
  </tr>
</table>

******
# Data exploration
A few examples from `notebooks/01_data_explore.ipynb`

1. Event types:

<table>
  <tr>
    <th>event_type</th>
    <th>count</th>
  </tr>

  <tr>
    <td>cart</td>
    <td>7567</td>
  </tr>

  <tr>
    <td>purchase</td>
    <td>7644</td>
  </tr>

  <tr>
    <td>view</td>
    <td>326350</td>
  </tr>
</table>

<br>

2. Stats:  
- Minimum price: 0
- Maximum price: 2574.07
- Average price: 345.1
- Median price: 193.03

<br>

3. Price distribution:
<img width="858" height="533" alt="image" src="https://github.com/user-attachments/assets/6fb02d85-09d5-4e01-81b9-095079ac0f0d" />

<br>
<br>

4. Number of Events by hour:
<img width="1389" height="489" alt="image" src="https://github.com/user-attachments/assets/02350e9a-0161-4f5a-89e4-6cd3c9cda9b4" />

Peak hour: 8 AM

*******
# Data load pipeline
1. Creating the database (`create-db.sql`):
```
CREATE DATABASE IF NOT EXISTS ecommerce_funnel
    DEFAULT CHARACTER SET = 'utf8mb4';
```
2. Dataset loading using `pandas` (`main.py`)
3. Connect the database and create a cursor to execute queries
4. Create the table `events` with the exact same column as the .csv file
5. Insert rows, using chunks (`10000`) for a better memory management

******
# Questions answered in queries
1. The most expensive brands per category
2. The top 3 most viewed products per category
3. Top 25 users with the most expending
4. First viewed product per user in a session
5. Last event per session
6. First 10 viewed products per category
7. Consecutive views from a user
8. Current and previous price from products viewed by a user
9. Checking if a user changed categories during two consecutive events

<br>

*Views*:
1. Users who spent more than $500
2. Total views per brand (more than 1000)
3. Average price per category ranked
4. Last viewed product by user in a session
5. Total purchased per category

<br>

SQL Concepts used:
- `Window Functions` such as: `LEAD()`, `LAG()`, `RANK()`, `RANK_DENSE()` and `ROW_NUMBER()`
- `CTEs`
- `Views`
- `Indexes`

************
