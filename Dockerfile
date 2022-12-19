ARG BASE_IMAGE=python:3.12.0a3-alpine3.17

FROM ${BASE_IMAGE}

RUN  apk update                       \
  && apk upgrade                      \
  && apk add jq                       \
  && rm -rf /var/cache/*/*            \
  && mkdir -p /dumpsterdiver          \
  && mkdir -p /var/log/dumpsterdiver

# # ===== Create "tekton" user  =====
ENV USER_NAME=tekton
ENV USER_ID=110099
ENV GROUP_NAME=tekton
ENV GROUP_ID=110099

RUN  addgroup -g    ${GROUP_ID} ${GROUP_NAME}                 \
  && adduser  -D -u ${USER_ID}  ${USER_NAME} -G ${GROUP_NAME} \
  && mkdir -p            /home/${USER_NAME}                   \
  && chown -R ${USER_ID} /home/${USER_NAME}                   \
  && chown -R ${USER_ID} /dumpsterdiver                       \
  && chown -R ${USER_ID} /var/log/dumpsterdiver
# ====

WORKDIR /dumpsterdiver

ADD requirements.txt ./
RUN  pip install --no-cache-dir -r requirements.txt

ADD *.py *.yaml ./
RUN chmod +x DumpsterDiver.py

USER ${USER_ID}

CMD ["python","DumpsterDiver.py"]

