#!/bin/bash

# Specify the base path to the shapefiles dir as parameter or it will default
# to the path below

PATH=/home/sync/cccs-maps/shapefiles
if [ -n "$1" ]; then
    PATH=$1
fi


DB=cccs_public
createdb ${DB}
psql -c 'CREATE EXTENSION postgis;' ${DB}

#The public folders contain shapefiles that have the same name , the only difference being the prefix to show which folder it came from and others having field names which have
#different names so we will load data from a single corresponding table that has many records

#Firstly load all the files listed in the text file because they contain a records with more columns than the other corresponding shapefiles

for FILE in `cat public.txt`
do
    shp2pgsql -s 4326 -c -D -I -W LATIN1  ${PATH}/${FILE}  | psql -p 5432  -d ${DB}
done


#running thesql file to clean the database

psql -d ${DB} -f public.sql


function load_mdb {
    SHAPEFILE=$1
    TABLE=$2
    SQL="$3"

    ogr2ogr \
        -progress \
        -append \
        -skipfailures \
        -a_srs "EPSG:4326" \
        -nlt PROMOTE_TO_MULTI \
        -f "ESRI Shapefile" \
        PG:"dbname=$DB" \
        ${SHAPEFILE} \
        -nln ${TABLE} -sql "${SQL}"
}


SHAPEFILE=$PATH/MBD_public/MBD_public_shapefiles/admin_point-L5_IDN_MBD_population.shp
TABLE=admin_point_l5
SQL="SELECT name as desa, population as desa_popul,range_pop as range_pop, class as class, kode2010 as kode2010 from 'admin_point-L5_IDN_MBD_population'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

SHAPEFILE=${PATH}/MBD_public/MBD_public_shapefiles/infra-airports_point-L3_IDN_MBD.shp
TABLE=infra_airports
SQL="SELECT name from 'infra-airports_point-L3_IDN_MBD'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

SHAPEFILE=$PATH/MBD_public/MBD_public_shapefiles/infra-roads_line-L3_IDN_MBD.shp
TABLE=infra_roads
SQL="SELECT id from 'infra-roads_line-L3_IDN_MBD'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

SHAPEFILE=$PATH/MBD_public/MBD_public_shapefiles/infra-seports_point-L3_IDN_MBD.shp
TABLE=infra_seports
SQL="SELECT name from 'infra-seports_point-L3_IDN_MBD'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

#Append layers from the MTB_public folder whilst also mapping fields which we saw as the same
SHAPEFILE=$PATH/MTB_public/MTB_public_shapefiles/admin_area-L3_IDN_MTB.shp
TABLE=admin_area_l3
SQL="SELECT provinsi, kabkotno as kab, kabkot from 'admin_area-L3_IDN_MTB'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

SHAPEFILE=$PATH/MTB_public/MTB_public_shapefiles/admin_area-L4_IDN_MTB.shp
TABLE=admin_area_l4
SQL="SELECT kecamatan, kecno as kec from 'admin_area-L4_IDN_MTB'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}

SHAPEFILE=$PATH/MTB_public/MTB_public_shapefiles/admin_area-L5_IDN_MTB.shp
TABLE=admin_area_l5
SQL="SELECT kode2010,provinsi,provno as prop,kabkot,kabkotno as kab,kecamatan,kecno as kec,desa as nama,desano as desa,sumber,desa_popul from 'admin_area-L5_IDN_MTB'"
load_mdb ${SHAPEFILE} ${TABLE} ${SQL}


psql -d $DB -c "update  admin_point_l5 set kabkot  =  'Maluku Barat Daya' where kabkot is null;"
psql -d $DB -c "update  admin_area_l4 set kabkot  =  'Maluku Tenggara Barat' where  kabkot is null;"




















