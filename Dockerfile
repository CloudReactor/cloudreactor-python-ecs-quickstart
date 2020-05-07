FROM python:3.8.2

LABEL maintainer="jeff@cloudreactor.io"

# For the web task example only.
# If you are not deploying the web task you can comment this out.
EXPOSE 7070

WORKDIR /usr/src/app

RUN pip install --upgrade pip==20.1

COPY ./requirements.txt .

# install dependencies
RUN pip install -r requirements.txt

# Run as non-root user for better security
RUN useradd --create-home appuser
WORKDIR /home/appuser

COPY deploy/files/proc_wrapper_1.2.2.py proc_wrapper.py

COPY src/*.py ./

ARG DEPLOYMENT_ENVIRONMENT=dev

# copy deployment environment settings
COPY build/${DEPLOYMENT_ENVIRONMENT}/.env .env

CMD python proc_wrapper.py $TASK_COMMAND
