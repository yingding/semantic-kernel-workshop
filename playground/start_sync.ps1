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
$BackendJob = Start-Job -ScriptBlock {
    python main.py
}
Pop-Location

# Wait a bit for the backend to initialize
Start-Sleep -Seconds 2

# Start the frontend development server
Write-Host "Starting frontend server..."
Push-Location frontend
$FrontendJob = Start-Job -ScriptBlock {
    & npm.cmd run dev
}
Pop-Location

# Function to handle script termination
function Cleanup {
    Write-Host "Shutting down services..."
    if ($BackendJob -ne $null) {
        Stop-Job -Job $BackendJob -Force
    }
    if ($FrontendJob -ne $null) {
        Stop-Job -Job $FrontendJob -Force
    }
    exit 0
}

# Set up trap to catch termination signals
Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

Write-Host "--------------------------------"
Write-Host "🚀 Services are running!"
Write-Host "Frontend: http://localhost:3000"
Write-Host "Backend: http://localhost:8000"
Write-Host "Press Ctrl+C to stop all services"

# Wait for both jobs
while ($true) {
    if ($BackendJob.State -eq "Completed" -or $FrontendJob.State -eq "Completed") {
        Cleanup
    }
    Start-Sleep -Seconds 1
}
