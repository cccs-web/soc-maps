#!/bin/bash

# Configurable options (though we recommend not changing these)

POSTGIS_PORT=6001
POSTGIS_CONTAINER_NAME=cccs-postgis-public
QGIS_SERVER_CONTAINER_NAME=cccs-qgis-server-public
QGIS_SERVER_PORT=6003

# -------------------------------------------------------
# You should not need to change anything below this point
# -------------------------------------------------------

# Specify the base path to the shapefiles dir as parameter when calling this
# script or it will default to the path below

DATA_PATH=/home/sync/cccs-maps/public/bps_indonesia

if [ -n "$1" ]
then
    DATA_PATH=$1
fi


DB=gis
USER=docker
PASSWORD=docker
PSQL="psql -p ${POSTGIS_PORT} -h localhost -U docker ${DB}"

# Helpers to run shp2pgsql from in docker so we dont need to
# have it installed on the host
# We dont' use -t and we added -a=STDOUT so that we get only the stdout
# that we need to pip it into the next process
SHP2PGSQL="docker run --rm -i -a=STDOUT -v ${DATA_PATH}:/bps_indonesia/ kartoza/postgis /usr/bin/shp2pgsql"
# Where the shapefiles will appear to be in the docker container
VOLUME=/bps_indonesia



source functions.sh
install_dependencies
restart_postgis_server


function load_shapefile {
    # Helper function to load a shapefile using OGR2OGR
    SHAPE_FILE=$1
    TABLE=$2
    SQL="$3"

    CONN="dbname='${DB}' host='localhost' port='${POSTGIS_PORT}' user='${USER}' password='${PASSWORD}'"

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
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-airports_point-L3_IDN_MBD.shp
TABLE=infra_airports
SQL="SELECT name from 'infra-airports_point-L3_IDN_MBD'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-roads_line-L3_IDN_MBD.shp
TABLE=infra_roads
SQL="SELECT id from 'infra-roads_line-L3_IDN_MBD'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

SHAPE_FILE=${DATA_PATH}/MBD_public/MBD_public_shapefiles/infra-seports_point-L3_IDN_MBD.shp
TABLE=infra_seports
SQL="SELECT name from 'infra-seports_point-L3_IDN_MBD'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

#Append layers from the MTB_public folder whilst also mapping fields which we saw as the same
SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L3_IDN_MTB.shp
TABLE=admin_area_l3
SQL="SELECT provinsi, kabkotno as kab, kabkot from 'admin_area-L3_IDN_MTB'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L4_IDN_MTB.shp
TABLE=admin_area_l4
SQL="SELECT kecamatan, kecno as kec from 'admin_area-L4_IDN_MTB'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"

SHAPE_FILE=${DATA_PATH}/MTB_public/MTB_public_shapefiles/admin_area-L5_IDN_MTB.shp
TABLE=admin_area_l5
SQL="SELECT kode2010,provinsi,provno as prop,kabkot,kabkotno as kab,kecamatan,kecno as kec,desa as nama,desano as desa,sumber,desa_popul from 'admin_area-L5_IDN_MTB'"
load_shapefile ${SHAPE_FILE} ${TABLE} "${SQL}"


${PSQL} -c "UPDATE admin_point_l5 SET kabkot = 'Maluku Barat Daya' WHERE kabkot IS NULL;"
${PSQL} -c "UPDATE admin_area_l4 SET kabkot = 'Maluku Tenggara Barat' WHERE  kabkot IS NULL;"


restart_qgis_server

















