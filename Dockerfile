FROM ubuntu:14.04

COPY build_postgis.sh /tmp/
RUN /tmp/build_postgis.sh && /bin/rm -f /tmp/build_postgis.sh
