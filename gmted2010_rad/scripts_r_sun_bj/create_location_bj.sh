#!/bin/bash
#
# Script to create a new GRASS LOCATION from a raster data set
#
# (c) Markus Neteler 2002, ITC-irst, Trento
#     V 1.1 2003
#
# Giuseppe Amatulli modify it for the grass64 version
#
# This program is Free Software under the GNU GPL (>=v2).
# create a new LOCATION from a raster data set
# Reference:
#   Markus Neteler and Helena Mitasova:
#   Open Source GIS: A GRASS GIS Approach.
#   Kluwer Academic Publishers, Boston, Dordrecht, 464 pp,
#   ISBN: 1-4020-7088-8, http://mpa.itc.it/grasstutor/
#
# The trick:
#  The script generates a temp LOCATION for a fake GRASS session, then
#  uses r.in.gdal to generate the target LOCATION with new raster
#  data set. Check data first with 'gdalinfo <dataset>'.

#customize path to GRASS start script, if needed:
# GRASSSTARTSCRIPT=/usr/local/bin/grass5
GRASSSTARTSCRIPT=/usr/local/cluster/hpc/Software/BDJ/Applications/GRASS/6.4.2/bin/grass64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cluster/hpc/Software/BDJ/Libraries/PROJ/4.8.0/lib


module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO


########## nothing to change below ##############################
MAP=$1
LOCATION=$2
MYGISDBASE=$3



if [ $# -lt 2 ] ; then
 echo "Script to create a new LOCATION from a raster data set"
 echo "Usage:"
 echo "   create_location.sh rasterfile newlocation_name [GISDBASE]"
 echo ""
 echo "       rasterfile: file to be imported (GeoTIFF, LANDSAT, ...)"
 echo "       newlocation_name: new location to be created"
 echo "       GISDBASE: full path to GRASS database directory (optional)"
 echo "                 e.g. $HOME/grassdata"
 echo ""
 exit 1
fi

if test -f $HOME/.gislock5 ; then
 echo "ERROR. GRASS 6.0 is already running"
 echo "Please close other session first."
 exit 1
fi


#get GISBASE from GRASS start script:
GRASSSTARTSCRIPTPATH=`type -p $GRASSSTARTSCRIPT`
if [ "$GRASSSTARTSCRIPTPATH" = "" ] ; then
 echo "ERROR. Cannot find '$GRASSSTARTSCRIPT' in path"
 exit 1
fi


GISBASE=`cat $GRASSSTARTSCRIPTPATH | grep 'GISBASE=' | cut -d'=' -f2`
if [ "$GISBASE" = "" ] ; then
 echo "ERROR. Cannot get GISBASE from '`type -p $GRASSSTARTSCRIPT`' script"
 exit 1
fi

#get GISDBASE from previous session:
if [ "$MYGISDBASE" = "" ] ; then
  GISDBASE=`grep GISDBASE $HOME/.grassrc6 | cut -d' ' -f2`
  if [ "$GISDBASE" = "" ] ; then
   echo "ERROR. Cannot get GISDBASE from $HOME/.grassrc6"
   echo "Please specify the GISDBASE parameter"
   exit 1
  fi
else
 GISDBASE=$MYGISDBASE
fi

if test -d $GISDBASE/$LOCATION ; then
 echo "ERROR. Location $LOCATION already exists in $GISDBASE"
 exit 1
fi



#generate temporal LOCATION:
TEMPDIR=$$.tmp
mkdir -p  $GISDBASE/$TEMPDIR/temp

#save existing .grassrc6
if test -e $HOME/.grassrc6 ; then
   mv $HOME/.grassrc6 /tmp/$TEMPDIR.grassrc6
fi
echo "LOCATION_NAME: $TEMPDIR" >  $HOME/.grassrc6
echo "MAPSET: temp"            >> $HOME/.grassrc6
echo "DIGITIZER: none"         >> $HOME/.grassrc6
echo "GISDBASE: $GISDBASE"     >> $HOME/.grassrc6

export GISBASE=$GISBASE
export GISRC=$HOME/.grassrc6
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cluster/hpc/Software/BDJ/Libraries/PROJ/4.8.0/lib:"$GISBASE/lib"




module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO


# import raster map into new location
r.in.gdal in=$MAP out=$MAP location=$LOCATION 2> error_gr.txt
if [ $? -eq 1 ] ; then
  echo "An error occured. Stop."
  exit 1
fi

#restore previous .grassrc5
if test -f /tmp/$TEMPDIR.grassrc6 ; then
   mv /tmp/$TEMPDIR.grassrc6 $HOME/.grassrc6
fi

#cleanup:
rm -rf $GISDBASE/$TEMPDIR	

echo "Now you can launch GRASS with:"
echo "    grass64 -text $GISDBASE/$LOCATION/PERMANENT"
echo "and continue to import further data sets."
