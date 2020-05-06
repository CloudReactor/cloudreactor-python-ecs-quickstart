if "%~1"=="" (
    echo Usage: %0% ^<deployment^>
    exit /b 1
)

set DEPLOYMENT_ENVIRONMENT=%1

echo DEPLOYMENT_ENVIRONMENT = %DEPLOYMENT_ENVIRONMENT%

set VAR_FILENAME=deploy\vars\%DEPLOYMENT_ENVIRONMENT%.yml

echo VAR_FILENAME = %VAR_FILENAME%

if not exist %VAR_FILENAME% (
    echo %VAR_FILENAME% does not exist, please copy deploy\vars\example.yml to %VAR_FILENAME% and fill in your secrets.
    exit /b 1
)

git rev-parse HEAD > commit_hash.txt
set /p CLOUDREACTOR_PROCESS_VERSION_SIGNATURE= < commit_hash.txt
del commit_hash.txt

echo CLOUDREACTOR_PROCESS_VERSION_SIGNATURE = %CLOUDREACTOR_PROCESS_VERSION_SIGNATURE%

type nul >> deploy\docker_deploy.env
type nul >> "deploy\docker_deploy.%DEPLOYMENT_ENVIRONMENT%.env"
