# Function to check if a command exists
function CommandExists {
    param (
        [string]$Command
    )
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check for required commands
if (-not (CommandExists "python")) {
    Write-Host "Error: Python is not installed" -ForegroundColor Red
    exit 1
}

if (-not (CommandExists "npm")) {
    Write-Host "Error: npm is not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Semantic Kernel Demo..."
Write-Host "--------------------------------"

# Start the backend server
Write-Host "Starting backend server..."
Push-Location backend
Start-Process -NoNewWindow -FilePath "python" -ArgumentList "main.py" -PassThru | ForEach-Object { $BackendProcess = $_ }
Pop-Location

# Wait a bit for the backend to initialize
Start-Sleep -Seconds 2

# Start the frontend development server
Write-Host "Starting frontend server..."
Push-Location frontend
Start-Process -NoNewWindow -FilePath "C:\nvm4w\nodejs\npm.cmd" -ArgumentList "run dev" -PassThru | ForEach-Object { $FrontendProcess = $_ }
Pop-Location

# Function to handle script termination
function Cleanup {
    Write-Host "Shutting down services..."
    if ($BackendProcess -ne $null) {
        Stop-Process -Id $BackendProcess.Id -Force
    }
    if ($FrontendProcess -ne $null) {
        Stop-Process -Id $FrontendProcess.Id -Force
    }
    exit 0
}

# Set up trap to catch termination signals
Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

Write-Host "--------------------------------"
Write-Host "🚀 Services are running!"
Write-Host "Frontend: http://localhost:5173"
Write-Host "Backend: http://localhost:8000"
Write-Host "Press Ctrl+C to stop all services"

# Wait for both processes
while ($true) {
    Start-Sleep -Seconds 1
}
