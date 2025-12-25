import requests
import pandas as pd
from sqlalchemy import create_engine
import time

# --- CONFIGURATION ---
API_KEY = 'a40d384acbd4d54e604cd681f3c3c3a5'
BASE_URL = 'http://api.marketstack.com/v1/eod'

# Database Connection (Superset PostgreSQL)
DB_USER = 'superset'
DB_PASSWORD = 'superset'
DB_HOST = 'superset_db'  # Docker container name
DB_PORT = '5432'
DB_NAME = 'superset'

# SQLAlchemy Engine
DATABASE_URI = f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
engine = create_engine(DATABASE_URI)

# List of stock symbols to fetch
SYMBOLS = ['AAPL', 'MSFT', 'GOOGL', 'TSLA', 'AMZN', 'META', 'NVDA', 'JPM']

def fetch_market_data(symbol, limit=100):
    """Fetches End-of-Day data for a specific symbol from Marketstack."""
    params = {
        'access_key': API_KEY,
        'symbols': symbol,
        'limit': limit
    }
    
    print(f"Fetching data for {symbol}...")
    try:
        response = requests.get(BASE_URL, params=params, timeout=30)
        
        if response.status_code == 200:
            json_data = response.json()
            if 'data' in json_data and json_data['data']:
                df = pd.DataFrame(json_data['data'])
                # Keep relevant columns
                cols_to_keep = ['date', 'symbol', 'open', 'high', 'low', 'close', 'volume']
                df = df[cols_to_keep]
                df['date'] = pd.to_datetime(df['date'])
                print(f"✓ Fetched {len(df)} records for {symbol}")
                return df
            else:
                print(f"✗ No data found for {symbol}")
                return None
        else:
            print(f"✗ Error fetching {symbol}: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"✗ Exception fetching {symbol}: {e}")
        return None

def load_to_postgres(df, table_name='marketstack_data'):
    """Loads DataFrame into PostgreSQL."""
    if df is not None and not df.empty:
        try:
            print(f"  Loading {len(df)} records into '{table_name}'...")
            df.to_sql(table_name, engine, if_exists='append', index=False)
            print(f"  ✓ Data loaded successfully")
            return True
        except Exception as e:
            print(f"  ✗ Error loading to database: {e}")
            return False
    return False

def clear_existing_data(symbol=None):
    """Optional: Clear existing data for a symbol before reloading."""
    try:
        if symbol:
            query = f"DELETE FROM marketstack_data WHERE symbol = '{symbol}'"
            engine.execute(query)
            print(f"✓ Cleared existing data for {symbol}")
        else:
            query = "DELETE FROM marketstack_data"
            engine.execute(query)
            print("✓ Cleared all existing data")
    except Exception as e:
        print(f"✗ Error clearing data: {e}")

if __name__ == "__main__":
    print("="*60)
    print("MARKETSTACK MULTI-SYMBOL ETL")
    print("="*60)
    print(f"Symbols to fetch: {', '.join(SYMBOLS)}")
    print(f"Records per symbol: 100")
    print("="*60)
    
    success_count = 0
    failed_symbols = []
    
    for i, symbol in enumerate(SYMBOLS, 1):
        print(f"\n[{i}/{len(SYMBOLS)}] Processing {symbol}...")
        
        # Fetch data
        df = fetch_market_data(symbol, limit=100)
        
        # Load to database
        if df is not None:
            if load_to_postgres(df):
                success_count += 1
            else:
                failed_symbols.append(symbol)
        else:
            failed_symbols.append(symbol)
        
        # Rate limiting - wait between requests to avoid API limits
        if i < len(SYMBOLS):
            print("  Waiting 2 seconds before next request...")
            time.sleep(2)
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"✓ Successfully loaded: {success_count}/{len(SYMBOLS)} symbols")
    if failed_symbols:
        print(f"✗ Failed symbols: {', '.join(failed_symbols)}")
    else:
        print("✓ All symbols loaded successfully!")
    
    # Verify total records
    try:
        from sqlalchemy import text
        with engine.connect() as conn:
            result = conn.execute(text("SELECT COUNT(*) as total, COUNT(DISTINCT symbol) as symbols FROM marketstack_data"))
            row = result.fetchone()
            print(f"\nDatabase stats:")
            print(f"  Total records: {row[0]}")
            print(f"  Unique symbols: {row[1]}")
    except Exception as e:
        print(f"Could not fetch stats: {e}")
    
    print("="*60)
    print("ETL Complete! You can now create visualizations in Superset.")
    print("="*60)
