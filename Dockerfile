# Alpine base image can lead to long compilation times and errors.
# https://pythonspeed.com/articles/base-image-python-docker-images/
# The one below is based on Debian 10.
FROM python:3.9.7-slim-buster

LABEL maintainer="jeff@cloudreactor.io"

WORKDIR /usr/src/app

# Install any OS libraries required to build python libraries
# For example, libpq-dev is required to build psycopg2
#RUN apt-get update \
#  && apt-get install -y libpq-dev=11.12-0+deb10u1 build-essential=12.6 --no-install-recommends \
#  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Run as non-root user for better security
RUN groupadd appuser && useradd -g appuser --create-home appuser
USER appuser
WORKDIR /home/appuser

# Output directly to the terminal to prevent logs from being lost
# https://stackoverflow.com/questions/59812009/what-is-the-use-of-pythonunbuffered-in-docker-file
ENV PYTHONUNBUFFERED 1

# Don't write *.pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# Enable the fault handler for segfaults
# https://docs.python.org/3/library/faulthandler.html
ENV PYTHONFAULTHANDLER 1

ENV PYTHONPATH /home/appuser/src

ENV PIP_USER 1
ENV PIP_NO_INPUT 1
ENV PIP_NO_CACHE_DIR 1
ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PIP_NO_WARN_SCRIPT_LOCATION 0

# So that tools installed by pip are available in the path
ENV PATH $PATH:/home/appuser/.local/bin

RUN pip install --upgrade pip==21.1.3
RUN pip install pip-tools==5.5.0 MarkupSafe==1.1.1 requests==2.25.1

COPY requirements.in .

RUN pip-compile --allow-unsafe --generate-hashes \
  requirements.in --output-file /tmp/requirements.txt

# Install dependencies
# https://stackoverflow.com/questions/45594707/what-is-pips-no-cache-dir-good-for
RUN pip install -r /tmp/requirements.txt

# Pre-create this directory so that it has the correct permission
# when ECS mounts a volume, otherwise it will be owned by root.
RUN mkdir scratch

COPY --chown=appuser:appuser src ./src

# For the web-server task example only.
# If you are not deploying the web server, you can comment out this line.
EXPOSE 7070

ENTRYPOINT python -m proc_wrapper $TASK_COMMAND
