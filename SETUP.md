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

<!--
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
-->

## Install python packages
```powershell
$PROJ_DIR_NAME="semantic-kernel-workshop\playground";
$PROJ_ROOT_DIRS="Documents\VCS\agents";
$PROJ_PATH="$env:USERPROFILE\$PROJ_ROOT_DIRS\$PROJ_DIR_NAME";
cd "$PROJ_PATH";

$PackageFile="requirements.txt";
Invoke-Expression "(Get-Command python).Source";
& "python" -m pip install -r $PackageFile --no-cache-dir;
```

## Install a nodejs env

```powershell
nvm list available
# nvm install 23.9.0
nvm install 23.11.0
# nvm uninstall 23.9.0
nvm use 23.11.0
nvm ls

$PROJ_DIR_NAME="semantic-kernel-workshop\playground\frontend";
$PROJ_ROOT_DIRS="Documents\VCS\agents";
$PROJ_PATH="$env:USERPROFILE\$PROJ_ROOT_DIRS\$PROJ_DIR_NAME";
cd "$PROJ_PATH";
npm install
```

## start frontend and back
1. Activate Python VENV
```powershell
$VERSION="3.13";
$ENV_NAME="multiagents";
$ENV_SURFIX="pip";
$ENV_FULL_NAME = "$ENV_NAME$VERSION$ENV_SURFIX";
$WORK_DIR="$env:USERPROFILE\Documents\VENV\";
& "$WORK_DIR$ENV_FULL_NAME\Scripts\Activate.ps1";
Invoke-Expression "(Get-Command python).Source";
```

2. change directory to the project playground
```powershell
$PROJ_DIR_NAME="semantic-kernel-workshop\playground";
$PROJ_ROOT_DIRS="Documents\VCS\agents";
$PROJ_PATH="$env:USERPROFILE\$PROJ_ROOT_DIRS\$PROJ_DIR_NAME";
cd "$PROJ_PATH";

& ".\start.ps1"

# & ".\start_sync.ps1"
```

## (Optional) local backend endpoint swagger api
```output
http://localhost:8000/docs
```


## Env variable setup

* Connection String for the Azure AI Project examples https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples
* Python code sample of Azure AI Project connection string https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/ai/azure-ai-projects/samples/connections/sample_connections.py

## Additional Read
* Semantic Kernel AzureAIAgent (Exprimental) https://learn.microsoft.com/en-us/semantic-kernel/frameworks/agent/azure-ai-agent?pivots=programming-language-python
* Multi Agent Examples: https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples/agents

* Semantic Kernel Roadmap: https://devblogs.microsoft.com/semantic-kernel/semantic-kernel-roadmap-h1-2025-accelerating-agents-processes-and-integration/
* Multi-agent Orchestration with SK https://techcommunity.microsoft.com/blog/educatordeveloperblog/using-azure-ai-agent-service-with-autogen--semantic-kernel-to-build-a-multi-agen/4363121
* Semantic Kernel Workshop (Intro.) https://github.com/Azure-Samples/semantic-kernel-workshop/
* Semantic Kernel Workshop (Adv.) https://github.com/Azure-Samples/semantic-kernel-advanced-usage
* Observability in Semantic Kernel with OpenTelemetry https://devblogs.microsoft.com/semantic-kernel/observability-in-semantic-kernel/

* Microsoft Blogpost multi agent orchestration https://techcommunity.microsoft.com/blog/azure-ai-services-blog/building-a-multimodal-multi-agent-system-using-azure-ai-agent-service-and-openai/4396267
* Semantic Kernel Agent Framework https://learn.microsoft.com/en-us/semantic-kernel/frameworks/agent/?pivots=programming-language-python

* Microsoft 365 Agent SDK (M365 Teams, Copilot Studio, Webchat) https://github.com/Microsoft/Agents

## Issues
* "chat_deployment_name is required" https://github.com/microsoft/semantic-kernel/issues/11404#issuecomment-2784972513

## Reference
* Semantic Kernel Env Variable https://pypi.org/project/semantic-kernel/
* SK AzureChatCompletion Constructor https://github.com/microsoft/semantic-kernel/blob/main/python/semantic_kernel/connectors/ai/open_ai/services/azure_chat_completion.py