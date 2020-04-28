@ECHO OFF

CALL deploy\helpers\docker_deploy_common.bat %1

IF %ERRORLEVEL% == 0 (
  docker-compose build deployer
)
