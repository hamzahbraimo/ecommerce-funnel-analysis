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
   - `pipeline/`: `main.py`
   - `sql/`: `create-db.sql` -> `schema-explore.sql` -> `indexes.sql` -> `questions.sql` -> `views.sql`

*****
# Data Cleaning
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
