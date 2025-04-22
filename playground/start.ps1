# Configuration
$env:BACKEND_HOST = "localhost"
$env:BACKEND_PORT = 8000
$env:FRONTEND_HOST = "localhost"
$env:FRONTEND_PORT = 3000 #5173
$WAIT_TIMEOUT = 30 # seconds

# Path to npm
$NPM_PATH = "C:\nvm4w\nodejs\npm.cmd"

# Function to check if a command exists
function Command-Exists {
    param([string]$cmd)
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

# Function to wait for a port to be open
function Wait-ForPort {
    param(
        [string]$host,
        [int]$port,
        [string]$serviceName
    )
    $timeout = $WAIT_TIMEOUT
    $startTime = Get-Date
    Write-Host -NoNewline "Waiting for $serviceName on $host`:$port..."

    if (Command-Exists "Test-NetConnection") {
        while (-not (Test-NetConnection -ComputerName $host -Port $port -InformationLevel Quiet)) {
            $currentTime = Get-Date
            if (($currentTime - $startTime).TotalSeconds -ge $timeout) {
                Write-Host " Timeout!"
                Write-Host "Error: $serviceName did not start within $timeout seconds."
                Cleanup
                exit 1
            }
            Write-Host -NoNewline "."
            Start-Sleep -Seconds 1
        }
    } elseif (Command-Exists "curl") {
        while (-not (curl --silent --head --fail "http://$host`:$port" 2>$null)) {
            $currentTime = Get-Date
            if (($currentTime - $startTime).TotalSeconds -ge $timeout) {
                Write-Host " Timeout!"
                Write-Host "Error: $serviceName did not start within $timeout seconds."
                Cleanup
                exit 1
            }
            Write-Host -NoNewline "."
            Start-Sleep -Seconds 1
        }
    } else {
        Write-Host " Neither 'Test-NetConnection' nor 'curl' found. Assuming services started after a delay."
        Start-Sleep -Seconds 5
    }
    Write-Host " Ready."
}

# Check for required commands
if (-not (Command-Exists "python")) {
    Write-Host "Error: Python is not installed"
    exit 1
}
if (-not (Test-Path $NPM_PATH)) {
    Write-Host "Error: npm is not installed at $NPM_PATH"
    exit 1
}

Write-Host "Starting Semantic Kernel Demo..."
Write-Host "--------------------------------"

# Function to handle script termination
function Cleanup {
    Write-Host "Shutting down services..."
    if ($global:BACKEND_PROC -and !$global:BACKEND_PROC.HasExited) {
        $global:BACKEND_PROC.Kill()
    }
    if ($global:FRONTEND_PROC -and !$global:FRONTEND_PROC.HasExited) {
        $global:FRONTEND_PROC.Kill()
    }
    exit 0
}

# Register Ctrl+C handler
$null = Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

# Start the backend server
Write-Host "Starting backend server..."
Push-Location backend
# $global:BACKEND_PROC = Start-Process -FilePath "uv" -ArgumentList "run main.py" -RedirectStandardOutput "../backend.log" -RedirectStandardError "../backend.log" -NoNewWindow -PassThru
$global:BACKEND_PROC = Start-Process -FilePath "python" -ArgumentList "main.py" -RedirectStandardOutput "../backend.log" -RedirectStandardError "../backend_error.log" -NoNewWindow -PassThru
Pop-Location



# Start the frontend server
Write-Host "Starting frontend server..."
Push-Location frontend
$global:FRONTEND_PROC = Start-Process -FilePath $NPM_PATH -ArgumentList "run dev -- -p $env:FRONTEND_PORT" -RedirectStandardOutput "../frontend.log" -RedirectStandardError "../frontend_error.log" -NoNewWindow -PassThru
Pop-Location

# Wait for services to be ready
Wait-ForPort $env:BACKEND_HOST $env:BACKEND_PORT "Backend"
Wait-ForPort $env:FRONTEND_HOST $env:FRONTEND_PORT "Frontend"

Write-Host "--------------------------------"
Write-Host "🚀 Services are running!"
Write-Host "Frontend: http://$($env:FRONTEND_HOST):$($env:FRONTEND_PORT)"
Write-Host "Backend: http://$($env:BACKEND_HOST):$($env:BACKEND_PORT)"
Write-Host "Log files: backend.log, frontend.log"
Write-Host "Press Ctrl+C to stop all services"

# Wait for both background processes to complete (will only happen on Ctrl+C)
while ($true) {
    if ($global:BACKEND_PROC.HasExited -or $global:FRONTEND_PROC.HasExited) {
        Cleanup
    }
    Start-Sleep -Seconds 1
}
