# SOC-MAPS


Mapping application to support social development planning.

**[soc-maps](https://github.com/cccs-web/soc-maps/)**

**Note:** The data, procedures and services provided by this repo are **public**
and should only include items allowed for general redistribution.

# Quick Start

## Requirements

You need to have docker installed since all the services provided here
run inside of docker containers. Please note that you should use the docker 
binaries from the upstream docker project. The easiest way to do this is to run:

```
curl -sSL https://get.docker.io/ubuntu/ | sudo sh
```

Once you have docker installed, make sure you are in the 'docker' group e.g.:

```
sudo usermod -a -G docker <username>
```

**Note:** You will need to log out and in again before your group changes
are applied to your logged in session.

## Installation

Once docker is installed, run the loader bash script by executing the following:

```
./public_loader.sh
```

**Note:** By default the above script will look for the gis dataset at this
location: `/home/sync/cccs-maps/public/`. If your shapefiles are located
in a different place then append the path to the shapefiles directory as a 
parameter to the public_loader script e.g.:

```
./public_loader.sh <path>
```

After running the above script you can open the web map project by visiting:

http://localhost:6003/index4326.html


# Additional notes

## Data schema

This repository and the above script deal only with loading public data.

The shapefiles listed in `public.txt` are loaded into the database
using the following method: for the first file encountered, a new table is
created, and thereafter each subsequent file is appended into table created
for the first layer.

## Postgis Server

The `public_loader.sh` script will start a virtualised Postgis Server (running
in a docker container) on completion. Should you need to, you can connect to
that PostgreSQL database using the following settings:

**Host:** localhost
**Port:** 6001
**User:** docker
**Pass:** docker
**Database:** gis

We recommend that you use the virtualised QGIS Desktop application for 
any project editing, layer loading etc. (see below for more details). The
above connection details are primarily intended to provide an easy access point
for doing backups and bulk data loads.


## QGIS Server

The `public_loader.sh` script will start a virtualised QGIS Server (running
in a docker container) on completion. Should you need to, you can kill and
redeploy the QGIS server by running:

```
./restart_qgis_server.sh
```

QGIS will provide a WMS (Web Mapping Service) for any QGIS projects saved into
the root of the web folder. Additionally, any files lodged into that folder
will be available via the web server. For example ``web/index4326.html`` will
be available as:

```
http://localhost:6003/index4326.html
```

**Note:** The QGIS Server instance is deployed with port 80 of the docker 
container mapped to port 6003 of the host. If you want to, you can open this
port on your firewall, but we recommend rather using a reverse proxy (e.g. nginx)
to proxy requests into the virtualised QGIS Server container.

## QGIS Desktop

Editing the project in QGIS requires using a copy of QGIS desktop run from
a docker container. Presently this will only work on Linux. To run QGIS in
this way do:

```
./run_qgis_in_docker.sh
```

The project file published to QGIS server will be in the /web directory
in the root of the virtualised file system (as seen from within file dialogs
of the dockerised QGIS application).

Note that in the context of the virtualised QGIS Desktop application, you
should use the following connection settings in order to connect to the 
PostGIS docker container:

**Host:** cccs-postgis-public
**Port:** 5432
**User:** docker
**Pass:** docker
**Database:** gis


# Contact

Admire Nyakudya & Tim Sutton
October 2014
