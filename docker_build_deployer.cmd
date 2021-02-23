@ECHO OFF

CALL deploy\helpers\docker_deploy_common.cmd dev

docker-compose -f deploy\docker-compose.yml build deployer
