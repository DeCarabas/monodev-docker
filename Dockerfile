FROM debian:jessie

COPY ./build-image.sh /tmp

RUN bash /tmp/build-image.sh && rm -rf /tmp/*
