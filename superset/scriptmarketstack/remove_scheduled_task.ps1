# Script to Remove the Scheduled Task for Marketstack ETL

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   REMOVE SCHEDULED TASK                                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$TaskName = "MarketstackETL-Daily-Update"

# Check if task exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if (-not $existingTask) {
    Write-Host "ℹ️  No scheduled task found with name: $TaskName" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Found scheduled task:" -ForegroundColor Cyan
Write-Host "  Name: $($existingTask.TaskName)" -ForegroundColor White
Write-Host "  State: $($existingTask.State)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Are you sure you want to remove this task? (y/N)"

if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host ""
        Write-Host "✓ Scheduled task removed successfully!" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "✗ Failed to remove task: $_" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}
else {
    Write-Host ""
    Write-Host "❌ Cancelled" -ForegroundColor Yellow
    Write-Host ""
}
