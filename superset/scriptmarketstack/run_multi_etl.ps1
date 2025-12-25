# Script to run Multi-Symbol Marketstack ETL inside Docker

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   MARKETSTACK MULTI-SYMBOL ETL                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Copy the Python script to Docker container
Write-Host "📦 Copying script to Docker container..." -ForegroundColor Yellow
docker cp load_multiple_symbols.py superset_app:/app/

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Script copied successfully" -ForegroundColor Green
}
else {
    Write-Host "✗ Failed to copy script" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Run the script inside the container
Write-Host "🚀 Running ETL script for multiple symbols..." -ForegroundColor Yellow
Write-Host "   This will fetch: AAPL, MSFT, GOOGL, TSLA, AMZN, META, NVDA, JPM" -ForegroundColor Gray
Write-Host ""

docker exec superset_app python /app/load_multiple_symbols.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ ETL completed successfully" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "✗ ETL failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

# Verify data
Write-Host "📊 Verifying database..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Total records and symbols:" -ForegroundColor Cyan
docker exec superset_db psql -U superset -d superset -c "SELECT COUNT(*) as total_records, COUNT(DISTINCT symbol) as unique_symbols FROM marketstock_data;"

Write-Host ""
Write-Host "Records per symbol:" -ForegroundColor Cyan
docker exec superset_db psql -U superset -d superset -c "SELECT symbol, COUNT(*) as records, MAX(date)::date as latest_date FROM marketstack_data GROUP BY symbol ORDER BY symbol;"

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Done! Next steps:" -ForegroundColor Green
Write-Host "   1. Open Superset: http://localhost:8088" -ForegroundColor White
Write-Host "   2. Go to Data → Datasets → + Dataset" -ForegroundColor White
Write-Host "   3. Create dataset from 'marketstack_data' table" -ForegroundColor White
Write-Host "   4. Start creating amazing visualizations! 📈" -ForegroundColor White
Write-Host ""
