# How to setup the Python Env
Author: Yingding Wang

## Python 3.13
### Creat VENV
use the `create_env.sh` script to create a venv on windows, the `create_env.sh` file located current in a different project

```powershell
cd $env:USERPROFILE\Documents\VCS\llm-train;

$VERSION="3.13";
$ENV_NAME="multiagents";
$ENV_SURFIX="pip";
$PM="pip";
$WORK_DIR="$env:USERPROFILE\Documents\VENV\";
.\envtools\create_env.ps1 -VERSION $VERSION -ENV_NAME $ENV_NAME -ENV_SURFIX $ENV_SURFIX -PM $PM -WORK_DIR $WORK_DIR;
```

### Activate the VENV
```powershell
$VERSION="3.13";
$ENV_NAME="multiagents";
$ENV_SURFIX="pip";
$ENV_FULL_NAME = "$ENV_NAME$VERSION$ENV_SURFIX";
$WORK_DIR="$env:USERPROFILE\Documents\VENV\";
& "$WORK_DIR$ENV_FULL_NAME\Scripts\Activate.ps1";
Invoke-Expression "(Get-Command python).Source";
```

## (Not for playground) Python 3.12
### Creat VENV
use the `create_env.sh` script to create a venv on windows, the `create_env.sh` file located current in a different project

```powershell
cd $env:USERPROFILE\Documents\VCS\llm-train;

$VERSION="3.12";
$ENV_NAME="multiagents";
$ENV_SURFIX="pip";
$PM="pip";
$WORK_DIR="$env:USERPROFILE\Documents\VENV\";
.\envtools\create_env.ps1 -VERSION $VERSION -ENV_NAME $ENV_NAME -ENV_SURFIX $ENV_SURFIX -PM $PM -WORK_DIR $WORK_DIR;
```

### Activate the VENV
```powershell
$VERSION="3.12";
$ENV_NAME="multiagents";
$ENV_SURFIX="pip";
$ENV_FULL_NAME = "$ENV_NAME$VERSION$ENV_SURFIX";
$WORK_DIR="$env:USERPROFILE\Documents\VENV\";
& "$WORK_DIR$ENV_FULL_NAME\Scripts\Activate.ps1";
Invoke-Expression "(Get-Command python).Source";
```

## Install python packages
```powershell
$PROJ_DIR_NAME="azure-ai-agent-service-enterprise-demo";
$PROJ_ROOT_DIRS="Documents\VCS\democollections";
$PROJ_PATH="$env:USERPROFILE\$PROJ_ROOT_DIRS\$PROJ_DIR_NAME";
cd "$PROJ_PATH";

$PackageFile="requirements.txt";
Invoke-Expression "(Get-Command python).Source";
& "python" -m pip install -r $PackageFile --no-cache-dir;
```

## Install a nodejs env

```powershell
nvm list available
nvm install 23.9.0
nvm use 23.9.0
nvm ls 
```



## Env variable setup

* Connection String for the Azure AI Project examples https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples
* Python code sample of Azure AI Project connection string https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/ai/azure-ai-projects/samples/connections/sample_connections.py

## Additional Read
* Multi Agent Examples: https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples/agents

