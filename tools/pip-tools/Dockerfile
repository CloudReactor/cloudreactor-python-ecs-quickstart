# This needs to match the base image used in the root Dockerfile,
# to match the same python environment:
# Operating System, Python version, and Python implementation 
FROM python:3.8.3-slim-buster

LABEL maintainer="jeff@cloudreactor.io"

RUN pip install --no-cache-dir --upgrade pip==20.1.1
RUN pip install --no-cache-dir pip-tools==5.1.2

WORKDIR /work

ENTRYPOINT [ "pip-compile", "--generate-hashes" ]
CMD ["requirements.in",  "--output-file", "requirements.txt"]
