FROM ubuntu:14.04

ADD build_postgis.sh /tmp/
RUN /tmp/build_postgis.sh
RUN /bin/rm -f /tmp/build_postgis.sh
