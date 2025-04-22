# Configuration
$env:BACKEND_HOST = "localhost"
$env:BACKEND_PORT = 8000
$env:FRONTEND_HOST = "localhost"
$env:FRONTEND_PORT = 3000 #5173
$WAIT_TIMEOUT = 60 # seconds
$LOGS_DIR = "logs"
$BACKEND_PROC_FILE = "$LOGS_DIR/backend_process.txt"
$FRONTEND_PROC_FILE = "$LOGS_DIR/frontend_process.txt"

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
        [string]$targetHost,
        [int]$port,
        [string]$serviceName
    )
    $timeout = $WAIT_TIMEOUT
    $startTime = Get-Date
    Write-Host -NoNewline "Waiting for $serviceName on $targetHost`:$port..."

    if (Command-Exists "Test-NetConnection") {
        while (-not (Test-NetConnection -ComputerName $targetHost -Port $port -InformationLevel Quiet)) {
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
        while (-not (curl --silent --head --fail "http://$targetHost`:$port" 2>$null)) {
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

# if LOG_DIR does not exist, create it
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR | Out-Null
}

Write-Host "Starting Semantic Kernel Demo..."
Write-Host "--------------------------------"

# Function to handle script termination
function Cleanup {
    Write-Host "Shutting down services..."
    # if the backend process and frontend process file exists, read the process id from the file and assign it to the global variables
    
    # get the node process
    $nodeProcess = Get-Process -Name node -ErrorAction SilentlyContinue
    if ($nodeProcess) {
        $nodeProcess | Stop-Process -Force
        Write-Output "Node.js server stopped."
        Remove-Item -Path $FRONTEND_PROC_FILE -ErrorAction SilentlyContinue
    } else {
        Write-Output "No Node.js server is running."
    }

    # get the node process
    # Get-Process with process name contains "python" prefix
    $pythonProcesses = Get-Process -Name python* -ErrorAction SilentlyContinue
    if ($pythonProcesses) {
        # $pythonProcess | Stop-Process -Force
        # Stop all Python processes
        $pythonProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
        Write-Output "Python server stopped."
        Remove-Item -Path $BACKEND_PROC_FILE -ErrorAction SilentlyContinue
    } else {
        Write-Output "No Python server is running."
    }
    
    # Read process IDs from files if they exist
    if (Test-Path $BACKEND_PROC_FILE) {
        $backendProcId = Get-Content -Path $BACKEND_PROC_FILE -Raw
        try {
            $process = Get-Process -Id $backendProcId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Stopping backend process (PID: $backendProcId)..."
                # $process.Kill()
                # kill the subprocess if it is not responding
                # force kill the process if it is not responding
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                # $process | Stop-Process -Force -ErrorAction SilentlyContinue
                # waiting for the process to exit
                # $process.WaitForExit()
                if ($process.HasExited) {
                    Write-Host "Backend process terminated successfully."
                    Remove-Item -Path $BACKEND_PROC_FILE -ErrorAction SilentlyContinue

                } else {
                    Write-Host "Failed to terminate backend process." -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "Could not terminate backend process: $_" -ForegroundColor Yellow
        } 
        # finally {
        #     Remove-Item -Path $BACKEND_PROC_FILE -ErrorAction SilentlyContinue
        # }
    }
    
    if (Test-Path $FRONTEND_PROC_FILE) {
        $frontendProcId = Get-Content -Path $FRONTEND_PROC_FILE -Raw
        try {
            $process = Get-Process -Id $frontendProcId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Stopping frontend process (PID: $frontendProcId)..."
                # force kill the process if it is not responding
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                # $process | Stop-Process -Force -ErrorAction SilentlyContinue
                # $process.Kill()
                # waiting for the process to exit
                $process.WaitForExit()
                if ($process.HasExited) {
                    Write-Host "Frontend process terminated successfully."
                    Remove-Item -Path $FRONTEND_PROC_FILE -ErrorAction SilentlyContinue
                } else {
                    Write-Host "Failed to terminate frontend process." -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "Could not terminate frontend process: $_" -ForegroundColor Yellow
        } 
        # finally {
        #     Remove-Item -Path $FRONTEND_PROC_FILE -ErrorAction SilentlyContinue
        # }
    }

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
$global:BACKEND_PROC = Start-Process -FilePath "python" -ArgumentList "main.py" -RedirectStandardOutput "../$LOGS_DIR/backend.log" -RedirectStandardError "../$LOGS_DIR/backend_error.log" -NoNewWindow -PassThru
Pop-Location



# Start the frontend server
Write-Host "Starting frontend server..."
Push-Location frontend
$global:FRONTEND_PROC = Start-Process -FilePath $NPM_PATH -ArgumentList "run dev -- -p $env:FRONTEND_PORT" -RedirectStandardOutput "../$LOGS_DIR/frontend.log" -RedirectStandardError "../$LOGS_DIR/frontend_error.log" -NoNewWindow -PassThru
Pop-Location

# write only the process IDs to the files instead of entire process objects
$global:BACKEND_PROC.Id | Out-File -FilePath $BACKEND_PROC_FILE -Force
$global:FRONTEND_PROC.Id | Out-File -FilePath $FRONTEND_PROC_FILE -Force

# Wait for services to be ready
Wait-ForPort $env:BACKEND_HOST $env:BACKEND_PORT "Backend"
Wait-ForPort $env:FRONTEND_HOST $env:FRONTEND_PORT "Frontend"

Write-Host "--------------------------------"
Write-Host "🚀 Services are running!"
Write-Host "Frontend: http://$($env:FRONTEND_HOST):$($env:FRONTEND_PORT)"
Write-Host "Backend: http://$($env:BACKEND_HOST):$($env:BACKEND_PORT)/docs"
Write-Host "Log files: backend.log, frontend.log"
Write-Host "Press Ctrl+C to stop all services"

# Wait for both background processes to complete (will only happen on Ctrl+C)
# while true
# while ($true) {
#     if ($global:BACKEND_PROC.HasExited -or $global:FRONTEND_PROC.HasExited) {
#         Cleanup
#     }
#     Start-Sleep -Seconds 1
# }

# Main monitoring loop with improved production features
$running = $true
$maxRetries = 5
$retryCount = 0
$heartbeatInterval = 30  # Seconds between health status logs
$lastHeartbeat = Get-Date
$startTime = Get-Date

try {
    Write-Host "Monitoring services (started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))..." -ForegroundColor Cyan

    while ($running) {
        try {
            # Listen for Ctrl+C in the background
            [console]::TreatControlCAsInput = $true
            if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character)) {
                Write-Host "Ctrl+C detected. Shutting down..." -ForegroundColor Yellow
                Cleanup
                $running = $false
                break
            } else {
                [console]::TreatControlCAsInput = $false
            }

            # Check if the backend process is still running
            if ($null -eq $global:BACKEND_PROC -or $global:BACKEND_PROC.HasExited) {
                $exitCode = $global:BACKEND_PROC ? $global:BACKEND_PROC.ExitCode : "unknown"
                Write-Host "Backend server has stopped unexpectedly (Exit code: $exitCode). Shutting down..." -ForegroundColor Red
                Cleanup
                $running = $false
                break
            }

            # Check if the frontend process is still running
            if ($null -eq $global:FRONTEND_PROC -or $global:FRONTEND_PROC.HasExited) {
                $exitCode = $global:FRONTEND_PROC ? $global:FRONTEND_PROC.ExitCode : "unknown"
                Write-Host "Frontend server has stopped unexpectedly (Exit code: $exitCode). Shutting down..." -ForegroundColor Red
                Cleanup
                $running = $false
                break
            }

            # Check if either process has completed
            if ($global:BACKEND_PROC.State -eq "Completed" -or $global:FRONTEND_PROC.State -eq "Completed") {
                Write-Host "One of the processes has completed. Shutting down..." -ForegroundColor Yellow
                Cleanup
                $running = $false
                break
            }

            # Print periodic heartbeat status
            $currentTime = Get-Date
            if (($currentTime - $lastHeartbeat).TotalSeconds -ge $heartbeatInterval) {
                $runningTime = $currentTime - $startTime
                $formattedRuntime = "{0:d2}:{1:d2}:{2:d2}" -f $runningTime.Hours, $runningTime.Minutes, $runningTime.Seconds
                
                # Check memory usage of processes for health monitoring
                $backendProcess = Get-Process -Id $global:BACKEND_PROC.Id -ErrorAction SilentlyContinue
                $frontendProcess = Get-Process -Id $global:FRONTEND_PROC.Id -ErrorAction SilentlyContinue
                
                $backendMemory = if ($backendProcess) { [math]::Round($backendProcess.WorkingSet64 / 1MB, 2) } else { "N/A" }
                $frontendMemory = if ($frontendProcess) { [math]::Round($frontendProcess.WorkingSet64 / 1MB, 2) } else { "N/A" }
                
                Write-Host "STATUS [Runtime: $formattedRuntime] - Services running normally (Backend: $backendMemory MB, Frontend: $frontendMemory MB)" -ForegroundColor Cyan
                $lastHeartbeat = $currentTime
            }

            # Sleep before the next iteration (using a shorter interval for responsiveness)
            Start-Sleep -Milliseconds 250
            $retryCount = 0  # Reset retry count if no issues
        } catch {
            Write-Host "Error in monitoring loop: $_" -ForegroundColor Red
            Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
            
            $retryCount++
            if ($retryCount -ge $maxRetries) {
                Write-Host "Max retries reached ($maxRetries). Forcing shutdown..." -ForegroundColor Red
                Cleanup
                $running = $false
                break
            }
            
            Write-Host "Retry $retryCount of $maxRetries..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
} finally {
    # Ensure cleanup happens even if the script is terminated in unexpected ways
    if ($running) {
        Write-Host "Script terminating abnormally. Performing cleanup..." -ForegroundColor Red
        Cleanup
    }
    
    $endTime = Get-Date
    $totalRuntime = $endTime - $startTime
    $formattedTotalTime = "{0:d2}:{1:d2}:{2:d2}" -f $totalRuntime.Hours, $totalRuntime.Minutes, $totalRuntime.Seconds
    Write-Host "Services have been stopped. Total runtime: $formattedTotalTime. Exiting..." -ForegroundColor Green
}

# Wait for both processes
# $running = $true
# $maxRetries = 5
# $retryCount = 0

# while ($running) {
#     try {
#         # Listen for Ctrl+C in the background
#         [console]::TreatControlCAsInput = $true
#         if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character)) {
#             Write-Host "Ctrl+C detected. Shutting down..." -ForegroundColor Yellow
#             Cleanup
#             $running = $false
#             break
#         } else {
#             [console]::TreatControlCAsInput = $false
#         }

#         # Check if the backend process is still running
#         if ($global:BACKEND_PROC -eq $null -or $global:BACKEND_PROC.HasExited) {
#             Write-Host "Backend server has stopped unexpectedly." -ForegroundColor Red
#             Cleanup
#             $running = $false
#             break
#         }

#         # Check if the frontend process is still running
#         if ($global:FRONTEND_PROC -eq $null -or $global:FRONTEND_PROC.HasExited) {
#             Write-Host "Frontend server has stopped unexpectedly." -ForegroundColor Red
#             Cleanup
#             $running = $false
#             break
#         }

#         # Check if either process has completed
#         if ($global:BACKEND_PROC.State -eq "Completed" -or $global:FRONTEND_PROC.State -eq "Completed") {
#             Write-Host "One of the processes has completed. Shutting down..." -ForegroundColor Yellow
#             Cleanup
#             $running = $false
#             break
#         }

#         # Retry logic for stuck processes
#         if ($retryCount -ge $maxRetries) {
#             Write-Host "Max retries reached. Forcing shutdown..." -ForegroundColor Red
#             Cleanup
#             $running = $false
#             break
#         }

#         # Sleep before the next iteration
#         Start-Sleep -Seconds 1
#         $retryCount = 0  # Reset retry count if no issues
#     } catch {
#         Write-Host "An error occurred in the monitoring loop: $_" -ForegroundColor Red
#         $retryCount++
#         Start-Sleep -Seconds 1
#     }
# }

# Write-Host "Services have been stopped. Exiting..." -ForegroundColor Green
