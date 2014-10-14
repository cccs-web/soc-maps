#!/bin/sh
xhost +
# Home is mounted so QGIS finds your Qt and QGIS settings
# /web is mounted as it is also available in the QGIS Server
# context, so anything you put there (e.g. .qgs projects)
# will be made available to the QGIS server instance.

docker run --rm --name="qgis-cccs-public" \
    -i -t \
    -v ${HOME}:/home/${USER} \
    -v `pwd`/web:/web \
    --link cccs-postgis-public:cccs-postgis-public \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    kartoza/qgis-desktop:latest
xhost -
