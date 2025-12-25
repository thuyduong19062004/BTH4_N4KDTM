# Scheduled ETL Script - Auto Update Market Data
# This script runs the multi-symbol ETL and logs the results

# Configuration
$LogDir = "$PSScriptRoot\logs"
$LogFile = "$LogDir\etl_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$MaxLogFiles = 30  # Keep last 30 days of logs

# Create logs directory if it doesn't exist
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Start logging
Start-Transcript -Path $LogFile

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SCHEDULED MARKETSTACK ETL                                ║" -ForegroundColor Cyan
Write-Host "║   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "🔍 Checking Docker status..." -ForegroundColor Yellow
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Docker is not running!" -ForegroundColor Red
        Write-Host "  Please start Docker Desktop and try again." -ForegroundColor Yellow
        Stop-Transcript
        exit 1
    }
    Write-Host "✓ Docker is running" -ForegroundColor Green
}
catch {
    Write-Host "✗ Docker command failed: $_" -ForegroundColor Red
    Stop-Transcript
    exit 1
}

Write-Host ""

# Check if Superset containers are running
Write-Host "🔍 Checking Superset containers..." -ForegroundColor Yellow
$supersetApp = docker ps --filter "name=superset_app" --format "{{.Names}}"
$supersetDb = docker ps --filter "name=superset_db" --format "{{.Names}}"

if (-not $supersetApp) {
    Write-Host "✗ Superset app container is not running!" -ForegroundColor Red
    Stop-Transcript
    exit 1
}

if (-not $supersetDb) {
    Write-Host "✗ Superset database container is not running!" -ForegroundColor Red
    Stop-Transcript
    exit 1
}

Write-Host "✓ All required containers are running" -ForegroundColor Green
Write-Host ""

# Run the ETL script
Write-Host "🚀 Starting ETL process..." -ForegroundColor Yellow
Write-Host ""

# Change to script directory
Set-Location $PSScriptRoot

# Run the multi-symbol ETL script
& "$PSScriptRoot\run_multi_etl.ps1"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "✅ SCHEDULED ETL COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
    $exitCode = 0
}
else {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "❌ SCHEDULED ETL FAILED" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Red
    $exitCode = 1
}

Write-Host ""
Write-Host "📁 Log saved to: $LogFile" -ForegroundColor Cyan
Write-Host ""

# Cleanup old log files
Write-Host "🧹 Cleaning up old logs..." -ForegroundColor Yellow
$logFiles = Get-ChildItem -Path $LogDir -Filter "etl_*.log" | Sort-Object LastWriteTime -Descending
if ($logFiles.Count -gt $MaxLogFiles) {
    $filesToDelete = $logFiles | Select-Object -Skip $MaxLogFiles
    foreach ($file in $filesToDelete) {
        Remove-Item $file.FullName -Force
        Write-Host "  Deleted: $($file.Name)" -ForegroundColor Gray
    }
    Write-Host "✓ Cleaned up $($filesToDelete.Count) old log files" -ForegroundColor Green
}
else {
    Write-Host "✓ No old logs to clean up" -ForegroundColor Green
}

Write-Host ""

Stop-Transcript
exit $exitCode
