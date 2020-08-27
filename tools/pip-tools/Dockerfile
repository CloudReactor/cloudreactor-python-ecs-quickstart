# This needs to match the base image used in the root Dockerfile,
# to match the same python environment:
# Operating System, Python version, and Python implementation
FROM python:3.8.5-slim-buster

LABEL maintainer="jeff@cloudreactor.io"

# Install any OS libraries required to build python libraries
# For example, libpq-dev is required to build psycopg2
# RUN apt-get update && apt-get install -y libpq-dev build-essential

RUN pip install --no-cache-dir --upgrade pip==20.2
RUN pip install --no-cache-dir pip-tools==5.2.1 MarkupSafe==1.1.1 requests==2.24.0

WORKDIR /work

ENTRYPOINT [ "pip-compile", "--generate-hashes" ]
CMD ["requirements.in",  "--output-file", "requirements.txt"]
