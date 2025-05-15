# entrypoint.ps1  ─ keeps ECR cred fresh on an interval
# -----------------------------------------------------

# Refresh interval driven by INTERVAL_SECONDS (seconds). Defauls to 8h
$interval = [int]($Env:INTERVAL_SECONDS)
if ($interval -le 0) { $interval = 28800 } # (28800s) are 8 hours

$accountId = $Env:AWS_ACCOUNT_ID

Write-Host "→ Refreshing ECR token every $interval seconds…"

while ($true) {
    try {
        if ([string]::IsNullOrWhiteSpace($accountId)) {
            & pwsh -File /scripts/refreshEcrDockerToken.ps1
        } else {
            & pwsh -File /scripts/refreshEcrDockerToken.ps1 -AccountId $accountId
        }
    }
    catch {
        Write-Warning "refreshEcrDockerToken.ps1 failed: $_"
    }

    Start-Sleep -Seconds $interval
}
