$customerId = "f47b59f7-b1ee-4dd0-b0d9-57dbfe11d5f7"
$sharedKey = "IiSuUsi3QFQSpl7JpEPpxgJdYBV6UNAqEIdid12hMBnOZ93wwP1sYGV082UkiBq0icixxBKAfcckC554jBnA9w=="
$logType = "CowrieHoneypot"

$logContent = (docker logs --tail 10 cowrie | Out-String).Trim()

if ($logContent) {
    # Replace special characters and format data as a JSON object inside an array
    $cleanLogContent = $logContent -replace "`r`n", "`n"
    $cleanLogContent = $cleanLogContent -replace "`r", "`n"
    
    # Escape double and single quotes to prevent JSON parsing errors
    $escapedLog = $cleanLogContent -replace '"', '\"'
    $escapedLog = $escapedLog -replace "'", "\'"

    # Create an array containing a valid JSON object with the raw string
    $jsonPayload = "[{`"RawData`": `"$($escapedLog.Trim())`"}]"
    $contentLength = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload).Length
    
    $date = [System.DateTime]::UtcNow.ToString("R")
    $stringToSign = "POST`n$contentLength`napplication/json`nx-ms-date:$date`n/api/logs"
    
    try {
        $hmacsha = [System.Security.Cryptography.HMACSHA256]::new([System.Convert]::FromBase64String($sharedKey))
        $hash = $hmacsha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign))
        $signature = [System.Convert]::ToBase64String($hash)
        
        $authorization = "SharedKey ${customerId}:$signature"

        $headers = @{
            "Authorization" = $authorization
            "Log-Type"      = $logType
            "x-ms-date"     = $date
            "Content-Type"  = "application/json"
        }

        $uri = "https://$customerId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"
        
        # Send data to Log Analytics
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $jsonPayload
        Write-Host "[SUCCESS] Logs successfully sent to Azure Log Analytics Workspace!" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to connect to Azure: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[WARN] No logs found." -ForegroundColor Yellow
}
