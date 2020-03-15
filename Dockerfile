FROM python:3.8.2-alpine3.11

LABEL maintainer="dmitrii@zakharov.cc"

RUN addgroup -S otus &&\
    adduser -h /home/otus -G otus -S -D otus

COPY ./websocket-sample/signal_server.py ./requirements.txt /home/otus/

RUN apk add --no-cache --virtual .build-deps gcc musl-dev &&\
    pip install --require-hashes --trusted-host=pypi.python.org --no-cache-dir -r /home/otus/requirements.txt &&\
    apk del .build-deps

WORKDIR /home/otus

USER otus

EXPOSE 8088

CMD ["python", "signal_server.py"]
