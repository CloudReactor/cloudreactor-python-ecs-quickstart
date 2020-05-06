@ECHO OFF

ECHO Run this script to debug build problems. It will take you to a
ECHO bash shell in the deployer container so you can inspect the files
ECHO that ansible writes. 

CALL deploy\helpers\docker_deploy_common.bat %1

IF %ERRORLEVEL% == 0 ( 
    ECHO The working directory is mounted in /work and you can re-run ansible by typing 
    ECHO   ./deploy.sh
    ECHO in the working directory.

    docker-compose -f deploy\docker-compose.yml run --rm deployer bash 
)
