# Refresh interval driven by INTERVAL_SECONDS (seconds). Default 3 h.

$interval = [int]($Env:INTERVAL_SECONDS)
if ($interval -le 0) { $interval = 10800 }

Write-Host "→ Refreshing ECR token every $interval seconds..."

while ($true) {
    try {
        & pwsh -File /scripts/refreshEcrDockerToken.ps1
    }
    catch {
        Write-Warning "refreshEcrDockerToken.ps1 failed: $_"
    }
    Start-Sleep -Seconds $interval
}
