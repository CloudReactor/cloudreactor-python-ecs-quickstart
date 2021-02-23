@ECHO OFF

CALL deploy\helpers\docker_deploy_common.cmd %1

IF %ERRORLEVEL% == 0 (
  docker-compose -f deploy\docker-compose.yml build deployer
)

IF %ERRORLEVEL% == 0 (
  docker-compose -f deploy\docker-compose.yml run --rm deployer ./deploy.sh %*
)
