#!/bin/bash

# Load the script with the command source and specify the grass database location_name and file to import. 
# source create_location.sh /dev/shm location $HOME/ost4sem/exercise/basic_adv_gdalogr/input_proj.tif  r.in.gdal or r.external 

export GISDBASE=$1
export LOCATION=$2
export file=$3
export imp=$4

export filename=$(basename  $file .tif)

rm -rf  $GISDBASE/$LOCATION $GISDBASE/${LOCATION}_tmp$$

mkdir -p  $GISDBASE/${LOCATION}_tmp$$/tmp

echo "LOCATION_NAME: ${LOCATION}_tmp$$"             > $HOME/.grass7/rc_$filename
echo "GISDBASE: $1"                        >> $HOME/.grass7/rc_$filename
echo "MAPSET: tmp"                         >> $HOME/.grass7/rc_$filename
echo "GRASS_GUI: text"                     >> $HOME/.grass7/rc_$filename

# path to GRASS settings file
export GISRC=$HOME/.grass7/rc_$filename
export GRASS_PYTHON=python
export GRASS_MESSAGE_FORMAT=plain
export GRASS_PAGER=cat
export GRASS_WISH=wish
export GRASS_ADDON_BASE=$HOME/.grass7/addons
export GRASS_VERSION=7.0.2
export GISBASE=/gpfs/apps/hpc.rhel7/Apps/GRASS/7.2.2/grass-7.2.2
export GRASS_PROJSHARE=/gpfs/apps/hpc.rhel7/Libs/PROJ/4.9.3/share/proj
export PROJ_DIR=/gpfs/apps/hpc.rhel7/Libs/PROJ/4.9.3

export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$GISBASE/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man
export GIS_LOCK=$$
export GRASS_OVERWRITE=1

rm -rf  $GISDBASE/$LOCATION

echo start importing 
if [ $imp = "r.in.gdal"  ] ; then r.in.gdal   in=$file      out=$filename    location=$LOCATION   memory=2000 ; fi 
if [ $imp = "r.external" ] ; then r.external  input=$file   out=$filename  ; fi 

g.mapset   mapset=PERMANENT  location=$LOCATION

rm -rf  $GISDBASE/${LOCATION}_tmp$$

echo "########################"
echo  Welcome to GRASS
echo "########################"

g.gisenv 

echo "########################"
echo Start to use GRASS comands
echo "########################"
