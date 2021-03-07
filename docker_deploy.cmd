@ECHO OFF

if "%~1"=="" (
    echo Usage: %0% ^<deployment^>
    exit /b 1
)

set DEPLOYMENT_ENVIRONMENT=%1

echo DEPLOYMENT_ENVIRONMENT = %DEPLOYMENT_ENVIRONMENT%

set VAR_FILENAME=deploy_config\vars\%DEPLOYMENT_ENVIRONMENT%.yml

echo VAR_FILENAME = %VAR_FILENAME%

if not exist %VAR_FILENAME% (
    echo %VAR_FILENAME% does not exist, please copy deploy_config\vars\example.yml to %VAR_FILENAME% and fill in your secrets.
    exit /b 1
)

REM Optional: use the latest git commit hash to set the version signature,
REM so that the git commit can be linked in the CloudReactor dashboard.
REM Otherwise, ansible will compute the task version signature as the
REM timestamp when it was started.
REM You can comment out the next block if you don't use git.
git rev-parse HEAD > commit_hash.txt
set /p CLOUDREACTOR_TASK_VERSION_SIGNATURE= < commit_hash.txt
del commit_hash.txt
echo CLOUDREACTOR_TASK_VERSION_SIGNATURE = %CLOUDREACTOR_TASK_VERSION_SIGNATURE%
REM End Optional

type nul >> deploy.env
type nul >> "deploy.%DEPLOYMENT_ENVIRONMENT%.env"

docker-compose -f docker-compose-deployer.yml run --rm deploy %*
