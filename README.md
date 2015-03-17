This Dockerfile builds PostgreSQL and PostGIS from source and installs them in /usr/local/pgsql/. It uses an Ubuntu 14.04 base image.

Note that the Docker image does not start a running PostgreSQL service. This should be done on top of this image if desired.
