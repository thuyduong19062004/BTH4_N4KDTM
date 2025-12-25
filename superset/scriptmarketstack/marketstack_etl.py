import requests
import pandas as pd
from sqlalchemy import create_engine
import datetime

# --- CONFIGURATION ---
# Replace with your actual Marketstack API Key
API_KEY = 'a40d384acbd4d54e604cd681f3c3c3a5'
BASE_URL = 'http://api.marketstack.com/v1/eod'

# Database Connection (Superset PostgreSQL)
# Running script inside Docker, so use container name as host
DB_USER = 'superset'
DB_PASSWORD = 'superset'
DB_HOST = 'superset_db'  # Docker container name
DB_PORT = '5432'
DB_NAME = 'superset'

# SQLAlchemy Engine
DATABASE_URI = f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
engine = create_engine(DATABASE_URI)

def fetch_market_data(symbol):
    """Fetches End-of-Day data for a specific symbol from Marketstack."""
    params = {
        'access_key': API_KEY,
        'symbols': symbol,
        'limit': 100 # Fetch last 100 days
    }
    
    print(f"Fetching data for {symbol}...")
    response = requests.get(BASE_URL, params=params)
    
    if response.status_code == 200:
        json_data = response.json()
        if 'data' in json_data:
            df = pd.DataFrame(json_data['data'])
            # Clean/Transform data if necessary
            # Keep relevant columns
            cols_to_keep = ['date', 'symbol', 'open', 'high', 'low', 'close', 'volume']
            df = df[cols_to_keep]
            df['date'] = pd.to_datetime(df['date'])
            print(f"Fetched {len(df)} records for {symbol}.")
            return df
        else:
            print("No data found in response.")
            return None
    else:
        print(f"Error fetching data: {response.status_code} - {response.text}")
        return None

def load_to_postgres(df, table_name='marketstack_data'):
    """Loads DataFrame into PostgreSQL."""
    if df is not None and not df.empty:
        try:
            print(f"Loading data into table '{table_name}'...")
            df.to_sql(table_name, engine, if_exists='append', index=False)
            print("Data loaded successfully.")
        except Exception as e:
            print(f"Error loading to database: {e}")
    else:
        print("No data to load.")

if __name__ == "__main__":
    if API_KEY == 'YOUR_MARKETSTACK_API_KEY':
        print("Please update the API_KEY variable in the script with your actual Marketstack API key.")
    else:
        # Example: Fetch data for Apple (AAPL)
        symbol = 'AAPL' 
        df = fetch_market_data(symbol)
        load_to_postgres(df)
