FROM redis:7.2.2
RUN apt-get -y update && apt-get -y install tree procps
RUN useradd -ms /bin/bash d3fau1t
WORKDIR /d3fau1t
RUN chown -R d3fau1t:d3fau1t /d3fau1t
USER d3fau1t
RUN mkdir -p /d3fau1t/var/lib /d3fau1t/var/log /d3fau1t/etc/conf/common /d3fau1t/bin
