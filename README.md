## soc-maps

mapping application to support social development planning


### System Requirements

* Ubuntu 14.04
* [GDAL](http://www.gdal.org/) 1.10 and above
   * `$ sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update`
   * `$ sudo apt-get install libgdal-dev gdal-bin`
* PostgreSQL (we used 9.3) 
* PostGIS (we used 2.1)
* QGIS server

### Instructions for loading data into the database

The bash data loading scripts create a PostgreSQL geodatabase, call a script to clean the database, and will append all the shape files into their respective tables. The bash scripts assume that data is loaded from a shared btsync folder, hard-coded with following path `/home/sync/cccs-maps/shapefiles/`. The directory structure for any collaborative project should remain the same across all servers so that the script will run smoothly. Bash uploading scripts are specific to particular project schema, but can be used as an extendable pattern to facilitate data loading when starting new projects. Adjust the scripts as necessary before running the loader for a new project.

Running the bash script will create a PostgreSQL geodatabase, call a script to clean the database, and will append all the shape files into their respective tables. 

run the bash script by executing the following:
  ./public_loader.sh

In the btsync folder there is a database dump that has all the data loaded in and it can be restored as an alternative to running the script.


#### A brief aside on data schema

The project utilizes different schema to differentiate conceptual groups of data (e.h. public vs. private data, group1 vs group1). **[soc-maps](https://github.com/cccs-web/soc-maps/)** utilizes a public schema, which references shapefiles in our public folders. The corresponding `public.txt` lists all such public files that are used as initial tables in the database, to which other layers are appended.


In the btsync folder there is a CCCS folder that contains a graphical description of the schema representation in the database. Open the ccss folder and open index.html in a web browser to view the different schemas that exist in the database. For each schema it lists the tables and the columns that are in the table as well as the data type.


## QGIS

Once all the data have been loaded into the database, open the QGIS project file  and replace the following connection string with the correct connection info depending on the location of the database:

`host=192.168.10.200 port=5432`

Then proceed to open QGIS and open the QGIS project file to see how the layers have been styled.

We will serve the project with QGIS server to publish WMS layers that can be used in web mapping applications.
