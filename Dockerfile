ARG BASE_IMAGE=3.12.0a1-alpine3.16

FROM ${BASE_IMAGE}

RUN  apk update     \
  && apk upgrade    \
  && apk add jq     \
  && rm -rf /var/cache/*/*

ADD requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    mkdir -p /var/log/dumpsterdiver

ADD *.py *.yaml ./
RUN chmod +x DumpsterDiver.py

CMD ["python","DumpsterDiver.py"]

