#!/bin/bash

# Specify the base path to the shapefiles dir as parameter or it will default
# to the path below

DATA_PATH=/home/sync/cccs-maps/shapefiles
if [ -n "$1" ]; then
    DATA_PATH=$1
fi

echo "Checking for docker installation"
echo "---------------------------------"

if dpkg -l | grep "docker.io" > /dev/null
then
    echo "You have the ubuntu docker package, please install the upstream"
    echo "official docker packages rather."
    echo "After removing docker.io package from ubuntu simply rerun this "
    echo "script and it will be installed:"
    exit
fi
if dpkg -l | grep "lxc-docker" > /dev/null
then
    echo "Upstream docker installation found, great!"
else
    echo "You need to have docker installed before you run this script."
    echo "We will install docker from the upstream repo for you, please"
    echo "enter your sudo password when prompted."
    curl -sSL https://get.docker.io/ubuntu/ | sudo sh
fi

echo "Checking for gdal installation"
echo "------------------------------"

if dpkg -l | grep "gdal-bin" > /dev/null
then
    echo "GDAL found, great!"
else
    echo "You need to have gdal installed before you run this script."
    echo "We will install gdal-bin from the ubuntu repos for you, please"
    echo "enter your sudo password when prompted."
    sudo apt-get install gdal-bin
fi




DB=gis
PORT=6001
CONTAINER_NAME=cccs-postgis-public
USER=docker
PASSWORD=docker

echo "Starting docker postgis container for public data"
echo "-------------------------------------------------"

docker kill ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
docker run \
    --name="${CONTAINER_NAME}" \
    --hostname="${CONTAINER_NAME}" \
    -p ${PORT}:5432 \
    -d -t \
    kartoza/postgis

 #-e USERNAME=${USER} \
 #-e PASS=${PASSWORD}\
echo "localhost:${PORT}:*:${USER}:${PASSWORD}" >> ~/.pgpass

# Wait while the docker container spins up
sleep 20

PSQL="psql -p ${PORT} -h localhost -U docker ${DB}"

# Helpers to run shp2pgsql from in docker so we dont need to
# have it installed on the host
# We dont' use -t and we added -a=STDOUT so that we get only the stdout
# that we need to pip it into the next process
SHP2PGSQL="docker run --rm -i -a=STDOUT -v ${DATA_PATH}:/shapefiles/ kartoza/postgis /usr/bin/shp2pgsql"
# Where the shapefiles will appear to be in the docker container
VOLUME=/shapefiles

function load_mdb {
    # Helper function to load a shapefile using OGR2OGR
    SHAPE_FILE=$1
    TABLE=$2
    SQL="$3"

    CONN="dbname='${DB}' host='localhost' port='${PORT}' user='${USER}' password='${PASSWORD}'"
    ogr2ogr \
        -progress \
        -append \
        -skipfailures \
        -a_srs "EPSG:4326" \
        -nlt PROMOTE_TO_MULTI \
        -f "ESRI Shapefile" \
        PG:"${CONN}" \
        ${SHAPE_FILE} \
        -nln ${TABLE} -sql "${SQL}"
}


#The public folders contain shapefiles that have the same name , the only
#difference being the prefix to show which folder it came from and others
#having field names which have different names so we will load data from a
#single corresponding table that has many records



#Firstly load all the files listed in the text file because they contain
# records with more columns than the other corresponding shapefiles
echo "Loading shapefiles"
echo "------------------"

for SHAPE_FILE in `cat public.txt`
do
    echo "Loading ${SHAPE_FILE}"
    ${SHP2PGSQL} -s 4326 -c -D -I -W LATIN1 ${VOLUME}/${SHAPE_FILE} | ${PSQL}
done


echo "Running the sql file to clean the database"
echo "-------------------------------------------"
${PSQL} -f public.sql

echo "Appending data to tables"
echo "------------------------"

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/admin_point-L5_IDN_MBD_population.shp
TABLE=admin_point_l5
SQL="SELECT name as desa, population as desa_popul,range_pop as range_pop, class as class, kode2010 as kode2010 from 'admin_point-L5_IDN_MBD_population'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-airports_point-L3_IDN_MBD.shp
TABLE=infra_airports
SQL="SELECT name from 'infra-airports_point-L3_IDN_MBD'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-roads_line-L3_IDN_MBD.shp
TABLE=infra_roads
SQL="SELECT id from 'infra-roads_line-L3_IDN_MBD'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-seports_point-L3_IDN_MBD.shp
TABLE=infra_seports
SQL="SELECT name from 'infra-seports_point-L3_IDN_MBD'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

#Append layers from the MTB_public folder whilst also mapping fields which we saw as the same
SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L3_IDN_MTB.shp
TABLE=admin_area_l3
SQL="SELECT provinsi, kabkotno as kab, kabkot from 'admin_area-L3_IDN_MTB'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L4_IDN_MTB.shp
TABLE=admin_area_l4
SQL="SELECT kecamatan, kecno as kec from 'admin_area-L4_IDN_MTB'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}

SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L5_IDN_MTB.shp
TABLE=admin_area_l5
SQL="SELECT kode2010,provinsi,provno as prop,kabkot,kabkotno as kab,kecamatan,kecno as kec,desa as nama,desano as desa,sumber,desa_popul from 'admin_area-L5_IDN_MTB'"
load_mdb ${SHAPE_FILE} ${TABLE} ${SQL}


${PSQL} -c "UPDATE admin_point_l5 SET kabkot = 'Maluku Barat Daya' WHERE kabkot IS NULL;"
${PSQL} -c "UPDATE admin_area_l4 SET kabkot = 'Maluku Tenggara Barat' WHERE  kabkot IS NULL;"




















