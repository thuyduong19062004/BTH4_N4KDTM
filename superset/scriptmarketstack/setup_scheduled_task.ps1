# Script to Setup Windows Scheduled Task for Marketstack ETL
# Run this script with Administrator privileges

param(
    [Parameter(Mandatory = $false)]
    [string]$Time = "08:00"  # Default time: 8:00 AM
)

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SETUP SCHEDULED TASK FOR MARKETSTACK ETL                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  WARNING: This script should be run as Administrator" -ForegroundColor Yellow
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Scheduled Time: $Time" -ForegroundColor White
Write-Host "  Script Path: $PSScriptRoot\scheduled_etl.ps1" -ForegroundColor White
Write-Host ""

# Task Configuration
$TaskName = "MarketstackETL-Daily-Update"
$TaskDescription = "Tự động cập nhật dữ liệu chứng khoán từ Marketstack API vào database Superset hàng ngày"
$ScriptPath = "$PSScriptRoot\scheduled_etl.ps1"
$WorkingDirectory = $PSScriptRoot

# Check if script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Host "✗ Error: Script not found at $ScriptPath" -ForegroundColor Red
    exit 1
}

# Remove existing task if it exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "🗑️  Removing existing scheduled task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "✓ Existing task removed" -ForegroundColor Green
    Write-Host ""
}

# Create the action
Write-Host "📝 Creating scheduled task..." -ForegroundColor Yellow
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`"" `
    -WorkingDirectory $WorkingDirectory

# Create the trigger (daily at specified time)
$Trigger = New-ScheduledTaskTrigger -Daily -At $Time

# Create settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

# Create principal (run with highest privileges)
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

# Register the task
try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Description $TaskDescription `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -Principal $Principal `
        -Force | Out-Null
    
    Write-Host "✓ Scheduled task created successfully!" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to create scheduled task: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ SETUP COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Task Details:" -ForegroundColor Cyan
Write-Host "  Name: $TaskName" -ForegroundColor White
Write-Host "  Schedule: Daily at $Time" -ForegroundColor White
Write-Host "  Script: $ScriptPath" -ForegroundColor White
Write-Host "  Logs: $PSScriptRoot\logs\" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open Task Scheduler to verify:" -ForegroundColor White
Write-Host "     Press Win+R, type 'taskschd.msc', press Enter" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Test the task manually:" -ForegroundColor White
Write-Host "     Right-click task → Run" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. To change the schedule time, run:" -ForegroundColor White
Write-Host "     .\setup_scheduled_task.ps1 -Time `"HH:MM`"" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. To remove the task:" -ForegroundColor White
Write-Host "     .\remove_scheduled_task.ps1" -ForegroundColor Gray
Write-Host ""

# Ask if user wants to test now
$testNow = Read-Host "Would you like to test the task now? (y/N)"
if ($testNow -eq 'y' -or $testNow -eq 'Y') {
    Write-Host ""
    Write-Host "🧪 Running test..." -ForegroundColor Yellow
    Write-Host ""
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "✓ Task started! Check the logs folder for results." -ForegroundColor Green
}

Write-Host ""
