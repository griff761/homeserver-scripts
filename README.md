# Home Server Scripts

A collection of utility scripts for managing a home server.

## Minecraft Server Watchdog

Located in `MinecraftServerTools/`, the `MCServerNotifyOnFail.ps1` script is designed to be used as a recovery action for your Minecraft Windows Service. When the service fails, this script will:

1.  **Capture the recent log output** from your Minecraft server log.
2.  **Send a rich Discord notification** via Webhook, including the log snippet and server details.
3.  **Attempt to restart the service** automatically.

### Setup

1.  Navigate to the `MinecraftServerTools` directory.
2.  Copy `config.example.json` to a new file named `config.json`.
3.  Open `config.json` and paste your **Discord Webhook URL**.
    ```json
    {
        "WebhookUrl": "https://discord.com/api/webhooks/..."
    }
    ```

### Usage

This script is intended to be triggered automatically when your service fails.

#### Arguments

*   `-ServiceName`: The exact name of the Windows Service (e.g., `MCServer`).
*   `-LogPath`: The absolute path to your Minecraft server's `latest.log` (or equivalent).
*   `-TestMode`: (Optional) Switch flag. If present, the script will send the webhook notification but **skip** the service restart. Useful for verifying your configuration.

#### Example Command

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\MinecraftServerTools\MCServerNotifyOnFail.ps1" -ServiceName "MyMinecraftService" -LogPath "C:\Games\Minecraft\logs\latest.log"
```

#### Testing

To test the webhook notification without actually restarting your service, use the `-TestMode` flag:

```powershell
.\MCServerNotifyOnFail.ps1 -ServiceName "MyMinecraftService" -LogPath "C:\Games\Minecraft\logs" -TestMode
```

### Integration with Windows Services (Recovery Tab)

To set this up natively in Windows:

1.  Open **Services** (`services.msc`).
2.  Right-click your Minecraft service and select **Properties**.
3.  Go to the **Recovery** tab.
4.  Set **First failure**, **Second failure**, and **Subsequent failures** to **Run a Program**.
5.  **Program**: `powershell.exe`
6.  **Command Line Parameters**:
    ```text
    -ExecutionPolicy Bypass -File "C:\Path\To\homeserver-scripts\MinecraftServerTools\MCServerNotifyOnFail.ps1" -ServiceName "YourServiceName" -LogPath "C:\Path\To\logs\latest.log"
    ```
