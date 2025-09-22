# PowerShell script to filter out MESA logs
Write-Host "Starting filtered logcat (excluding MESA logs)..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

adb logcat | Where-Object { $_ -notmatch "MESA|on_vkCreateFence" }
