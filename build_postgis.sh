#!/bin/bash

# This script builds PostgreSQL and PostGIS from source and installs
# them under /usr/local/pgsql.

set -ex

groupadd -f postgres
useradd -u 600 -c postgres -d /home/postgres -g postgres -m -s /bin/bash postgres

echo "Installing Postgres dependencies at `date`"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison \
        libxml2-dev libxslt-dev libssl-dev wget

echo "Downloading PostgreSQL and PostGIS sources at `date`"
su postgres <<'EOF'
mkdir -p /home/postgres/src
cd /home/postgres/src
wget -nv https://ftp.postgresql.org/pub/source/v9.4.1/postgresql-9.4.1.tar.bz2
wget -nv http://download.osgeo.org/postgis/source/postgis-2.1.5.tar.gz
wget -nv http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
wget -nv http://download.osgeo.org/proj/proj-4.9.1.tar.gz
wget -nv http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz
wget -nv https://github.com/json-c/json-c/archive/json-c-0.11-20130402.tar.gz
for f in *.tar.bz2; do echo $f; tar -xjpf $f; done
for f in *.tar.gz; do echo $f; tar -xzpf $f; done
rm -f *.tar.bz2 *.tar.gz
EOF

su postgres <<'EOF01'
echo "Building postgres at `date`"
cd /home/postgres/src/postgresql-9.4.1
./configure
make world
EOF01

echo "Installing postgres at `date`"
cd /home/postgres/src/postgresql-9.4.1
make install-world

# Update /etc/profile so that all login shells can find PostgreSQL.
set +e
grep -q "/usr/local/pgsql" /etc/profile
if [ $? -ne 0 ]
then
echo "Updating /etc/profile at `date`"
cat <<'EOF02' >> /etc/profile
LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH
PATH=/usr/local/pgsql/bin:$PATH
export PATH
EOF02
fi
set -e

# Since the current shell is not going to reread /etc/profile,
# we need to set these environment variables here too before continuing.
LD_LIBRARY_PATH=/usr/local/pgsql/lib
export LD_LIBRARY_PATH
PATH=/usr/local/pgsql/bin:$PATH
export PATH

echo "Running ldconfig at `date`"
ldconfig

echo "Building json-c at `date`"
JSONCDIR=/home/postgres/src/json-c-json-c-0.11-20130402
su postgres <<EOF03
cd $JSONCDIR
./configure
make
EOF03

echo "Installing json-c at `date`"
cd $JSONCDIR
make install

echo "Building proj.4 at `date`"
PROJ4DIR=/home/postgres/src/proj-4.9.1
su postgres <<EOF04
cd $PROJ4DIR
./configure
make
chmod 755 .
EOF04

echo "Installing proj.4 at `date`"
cd $PROJ4DIR
make install

echo "Building GEOS at `date`"
GEOSDIR=/home/postgres/src/geos-3.4.2
su postgres <<EOF05
cd $GEOSDIR
./configure
make
EOF05

echo "Installing GEOS at `date`"
cd $GEOSDIR
make install

echo "Building GDAL at `date`"
GDALDIR=/home/postgres/src/gdal-1.11.2
su postgres <<EOF06
cd $GDALDIR
./configure
make
EOF06

echo "Installing GDAL at `date`"
cd $GDALDIR
make install

echo "Building PostGIS at `date`"
POSTGISDIR=/home/postgres/src/postgis-2.1.5
su postgres <<EOF07
cd $POSTGISDIR
./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config
make
EOF07

echo "Installing PostGIS at `date`"
cd $POSTGISDIR
make install

echo "Running ldconfig at `date`"
ldconfig
