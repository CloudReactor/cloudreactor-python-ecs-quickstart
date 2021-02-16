FROM python:3.9.1

WORKDIR /work

# Output directly to the terminal to prevent logs from being lost
# https://stackoverflow.com/questions/59812009/what-is-the-use-of-pythonunbuffered-in-docker-file
ENV PYTHONUNBUFFERED 1

# Don't write *.pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# Enable the fault handler for segfaults
# https://docs.python.org/3/library/faulthandler.html
ENV PYTHONFAULTHANDLER 1

RUN apt-get update
RUN apt-get install binutils libproj-dev gdal-bin -y
RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get -y install docker-ce

RUN pip install --no-input --no-cache-dir --upgrade pip==21.0.1 pip-tools==5.5.0 MarkupSafe==1.1.1 requests==2.24.0

COPY ./deploy/requirements.in /tmp/requirements.in

RUN pip-compile --allow-unsafe --generate-hashes \
  /tmp/requirements.in --output-file /tmp/requirements.txt

# Install dependencies
# https://stackoverflow.com/questions/45594707/what-is-pips-no-cache-dir-good-for
RUN pip install --no-input --no-cache-dir -r /tmp/requirements.txt

CMD [ "./deploy.sh" ]
