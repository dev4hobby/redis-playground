FROM redis:7.2.2

ENV SENTINEL_QUORUM 2
ENV SENTINEL_DOWN_AFTER 1000
ENV SENTINEL_FAILOVER 1000

RUN apt-get -y update && apt-get -y install tree procps
RUN useradd -ms /bin/bash d3fau1t
WORKDIR /d3fau1t
RUN chown -R d3fau1t:d3fau1t /d3fau1t
USER d3fau1t

RUN mkdir -p /d3fau1t/var/lib /d3fau1t/var/log /d3fau1t/etc/conf /d3fau1t/bin /d3fau1t/tmp

COPY ./redis/nodes/sentinel/common.conf /d3fau1t/etc/conf/
COPY ./redis/scripts/init-sentinel.sh /d3fau1t/bin/run

USER root
RUN chown d3fau1t:d3fau1t /d3fau1t/*
RUN chmod +x /d3fau1t/bin/run
USER d3fau1t

EXPOSE 26379

CMD ["/d3fau1t/bin/run"]
