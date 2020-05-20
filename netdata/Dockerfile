FROM netdata/netdata

WORKDIR /etc/netdata
COPY ./netdata.conf ./netdata.conf
COPY httpcheck-supervisor.yml ./go.d/httpcheck.conf
COPY balenad.conf ./python.d/dockerd.conf
COPY boinc.conf ./python.d/boinc.conf
