@ECHO OFF

CALL deploy\helpers\docker_deploy_common.bat dev

docker-compose -f deploy\docker-compose.yml build deployer
