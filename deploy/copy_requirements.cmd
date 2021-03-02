@ECHO OFF
ECHO Copying deployment requirements.txt back to host ...
set IMAGE_NAME=cloudreactor_deployer
set TEMP_CONTAINER_NAME="%IMAGE_NAME%-temp"

docker create --name %TEMP_CONTAINER_NAME% %IMAGE_NAME%
docker cp %TEMP_CONTAINER_NAME%:/tmp/requirements.txt requirements.txt
docker rm %TEMP_CONTAINER_NAME%

ECHO Done copying deployment requirements.txt back to host.
