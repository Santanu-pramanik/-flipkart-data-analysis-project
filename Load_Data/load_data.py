import pandas as pd
from sqlalchemy import create_engine

# Step 1: Read the CSV file into Python
df = pd.read_csv("flipkart.csv")   # change path if file is elsewhere, e.g. "C:/Users/YourName/Downloads/flipkart.csv"

# Step 2: Quick check - print first 5 rows and column names
print(df.head())
print(df.columns)
print("Total rows:", len(df))

# Step 3: Connect to your PostgreSQL database
# Format: postgresql://username:password@host:port/database_name
engine = create_engine("postgresql://postgres:Santanu1234@localhost:5432/flipkart_dw")

# Step 4: Push the data into the staging table
df.to_sql("staging_flipkart", engine, if_exists="append", index=False)

print("Data loaded successfully!")