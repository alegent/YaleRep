#!/bin/bash

# Load the script with the command source and specify the grass database location_name and file to import. 
# source create_location.sh /dev/shm location $HOME/ost4sem/exercise/basic_adv_gdalogr/input_proj.tif

export GISDBASE=$1
export LOCATION=$2
export file=$3

export filename=$(basename  $file .shp)

rm -rf  $GISDBASE/$LOCATION $GISDBASE/loc_tmp

mkdir -p  $GISDBASE/loc_tmp/tmp

echo "LOCATION_NAME: loc_tmp"                                                       > $HOME/.grass7/rc_$filename
echo "GISDBASE: /dev/shm"                                                          >> $HOME/.grass7/rc_$filename
echo "MAPSET: tmp"                                                                 >> $HOME/.grass7/rc_$filename
echo "GRASS_GUI: text"                                                             >> $HOME/.grass7/rc_$filename

# path to GRASS settings file
export GISRC=$HOME/.grass7/rc_$filename
export GRASS_PYTHON=python
export GRASS_MESSAGE_FORMAT=plain
export GRASS_PAGER=cat
export GRASS_WISH=wish
export GRASS_ADDON_BASE=$HOME/.grass7/addons
export GRASS_VERSION=7.0.0beta1
export GISBASE=/usr/local/cluster/hpc/Apps/GRASS/7.0.0beta1/grass-7.0.0beta1
export GRASS_PROJSHARE=/usr/local/cluster/hpc/Libs/PROJ/4.8.0/share/proj/
export PROJ_DIR=/usr/local/cluster/hpc/Libs/PROJ/4.8.0

export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$GISBASE/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man
export GIS_LOCK=$$
export GRASS_OVERWRITE=1

rm -rf  $GISDBASE/$LOCATION

echo start importing 
v.in.ogr -o  -e -c  dsn=$file   output=$filename  location=$LOCATION 
 
echo end import 

g.mapset mapset=PERMANENT  location=$LOCATION

rm -rf  $GISDBASE/loc_tmp

echo "########################"
echo  Welcome to GRASS
echo "########################"

g.gisenv 

echo "########################"
echo Start to use GRASS comands
echo "########################"
