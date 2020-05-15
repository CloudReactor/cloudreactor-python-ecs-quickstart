# This needs to match the base image used in the root Dockerfile,
# to match the same python environment:
# Operating System, Python version, and Python implementation 
FROM python:3.8.2-slim-buster

LABEL maintainer="jeff@cloudreactor.io"

RUN pip install --upgrade pip==20.1
RUN pip install pip-tools==5.1.2

WORKDIR /src

ENTRYPOINT [ "pip-compile", "--generate-hashes" ]
CMD ["requirements.in",  "--output-file", "requirements.txt"]
