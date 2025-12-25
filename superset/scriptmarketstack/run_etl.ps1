# Script to run Marketstack ETL inside Docker

# Copy the Python script to Docker container
Write-Host "Copying script to Docker container..." -ForegroundColor Cyan
docker cp marketstack_etl.py superset_app:/app/

# Run the script inside the container
Write-Host "`nRunning ETL script..." -ForegroundColor Cyan
docker exec superset_app python /app/marketstack_etl.py

# Verify data
Write-Host "`nVerifying data count..." -ForegroundColor Cyan
docker exec superset_db psql -U superset -d superset -c "SELECT COUNT(*) as total_records FROM marketstack_data;"

Write-Host "`nLatest 5 records:" -ForegroundColor Cyan
docker exec superset_db psql -U superset -d superset -c "SELECT date::date, symbol, close, volume FROM marketstack_data ORDER BY date DESC LIMIT 5;"

Write-Host "`nDone! You can now create a dataset in Superset using the 'marketstack_data' table." -ForegroundColor Green
