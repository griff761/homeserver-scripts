param (
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,

    [Parameter(Mandatory = $true)]
    [string]$LogPath
)

# --- CONFIGURATION ---
# Load configuration from config.json
$ConfigPath = Join-Path $PSScriptRoot "config.json"

if (Test-Path $ConfigPath) {
    try {
        $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        $WebhookUrl = $Config.WebhookUrl
    }
    catch {
        Write-Warning "Failed to parse config.json. Ensure it is valid JSON."
        $WebhookUrl = $null
    }
}
else {
    Write-Warning "Configuration file not found at $ConfigPath."
    Write-Warning "Please copy 'config.example.json' to 'config.json' and add your Webhook URL."
    $WebhookUrl = $null
}
# ---------------------

# 1. Grab the log
if (Test-Path $LogPath) {
    $LogContent = Get-Content $LogPath -Tail 15
    $LogSnippet = $LogContent -join "`n"
}
else {
    $LogSnippet = "Log file not found at $LogPath"
}

# 2. Build the Message Safely
# FIX: Use single quotes here so the backticks are treated as text, not escape codes
$Fence = '```' 
$LogMessage = "{0}text`n{1}`n{0}" -f $Fence, $LogSnippet

$Payload = @{
    username = "Server Watchdog"
    embeds   = @(
        @{
            title       = "⚠️ Service Failure Detected"
            description = "The Minecraft Service failed to start or crashed unexpectedly."
            color       = 16711680 # Red
            fields      = @(
                @{
                    name   = "Service Name"
                    value  = $ServiceName
                    inline = $true
                },
                @{
                    name   = "Host Machine"
                    value  = $env:COMPUTERNAME
                    inline = $true
                },
                @{
                    name  = "Recent Log Output"
                    value = $LogMessage
                }
            )
            footer      = @{
                text = "Attempting to restart service via Watchdog script..."
            }
            timestamp   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
    )
}

# 3. Send Webhook
if ($WebhookUrl) {
    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType 'application/json' -Body ($Payload | ConvertTo-Json -Depth 4)
    }
    catch {
        Write-Output "Failed to send webhook. Continuing to restart logic."
    }
}
else {
    Write-Output "Webhook URL not configured. Skipping webhook notification."
}

# 4. Attempt to Restart
Write-Output "Restarting Service: $ServiceName"
Start-Sleep -Seconds 10
Start-Service -Name $ServiceName