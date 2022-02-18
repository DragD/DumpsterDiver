ARG BASE_IMAGE=python:alpine3.15

FROM ${BASE_IMAGE}

RUN  set -x           \
	&& apk update       \
  && apk upgrade

ADD requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    mkdir -p /var/log/dumpsterdiver

ADD *.py *.yaml ./
RUN chmod +x DumpsterDiver.py

ENTRYPOINT ["python","DumpsterDiver.py"]

