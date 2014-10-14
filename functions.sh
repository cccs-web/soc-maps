#!/bin/bash

# Configurable options (though we recommend not changing these)
POSTGIS_PORT=6001
POSTGIS_CONTAINER_NAME=cccs-postgis-public
QGIS_SERVER_PORT=6003
QGIS_SERVER_CONTAINER_NAME=cccs-qgis-server-public

# -------------------------

function restart_postgis_server {

    echo "Starting docker postgis container for public data"
    echo "-------------------------------------------------"

    # too dodgy? - docker container needs read access to these files
    chmod -R a+rX ${DATA_PATH}

    docker kill ${POSTGIS_CONTAINER_NAME}
    docker rm ${POSTGIS_CONTAINER_NAME}
    docker run \
        --restart="always" \
        --name="${POSTGIS_CONTAINER_NAME}" \
        --hostname="${POSTGIS_CONTAINER_NAME}" \
        -p ${POSTGIS_PORT}:5432 \
        -d -t \
        kartoza/postgis

     #-e USERNAME=${USER} \
     #-e PASS=${PASSWORD}\

    # Todo:  prevent multiple entries in pgpass
    echo "localhost:${POSTGIS_PORT}:*:${USER}:${PASSWORD}" >> ~/.pgpass

    sleep 20

}
function restart_qgis_server {

    echo "Running QGIS server"
    echo "-------------------"
    WEB_DIR=`pwd`/web
    chmod -R a+rX ${WEB_DIR}
    docker kill ${QGIS_SERVER_CONTAINER_NAME}
    docker rm ${QGIS_SERVER_CONTAINER_NAME}
    docker run \
        --restart="always" \
        --name="${QGIS_SERVER_CONTAINER_NAME}" \
        --hostname="${QGIS_SERVER_CONTAINER_NAME}" \
        --link ${POSTGIS_CONTAINER_NAME}:${POSTGIS_CONTAINER_NAME} \
        -d -t \
        -v ${WEB_DIR}:/web \
        -p ${QGIS_SERVER_PORT}:80 \
        kartoza/qgis-server

    echo "You can now consume WMS services at this url"
    echo "http://locahost:${QGIS_SERVER_PORT}/cgi-bin/qgis_mapserv.fcgi?map=/web/cccs_public.qgs"
}

function install_dependencies {

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
}
