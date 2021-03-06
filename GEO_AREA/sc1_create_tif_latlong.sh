#create lat long tif 

mkdir -p  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/lat_long_tif/loc_tmp/tmp

echo "LOCATION_NAME: loc_tmp"                                                               > $HOME/.grass7/rc_latlong
echo "GISDBASE: /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/lat_long_tif"    >> $HOME/.grass7/rc_latlong
echo "MAPSET: tmp"                                                                         >> $HOME/.grass7/rc_latlong
echo "GRASS_GUI: text"                                                                     >> $HOME/.grass7/rc_latlong


# path to GRASS settings file                                                                                                                                                                                        
export GISRC=$HOME/.grass7/rc_latlong
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



# rm -rf  mkdir -p  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/lat_long_tif/loc_latlong

echo start importing 
# r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/30arc-sec-Area_prj6842.tif   out=arc30ref   location=loc_latlong

g.mapset mapset=PERMANENT  location=loc_latlong

g.region n=90 s=0 w=-180 e=0

r.mapcalc " one=1 "

# export the tif in xyz and reinport only one column 

echo calculate lat 

r.out.xyz --o one | \
cut -f1,2 -d'|' | \
m.proj -oed --quiet | \
sed -e 's/[ \t]/|/g' | \
cut -f1-4 -d'|' | \
r.in.xyz --o in=- z=4 out=rast.lat

echo calculate lon

r.out.xyz --o one | \
xccut -f1,2 -d'|' | \
m.proj -oed --quiet | \
sed -e 's/[ \t]/|/g' | \
cut -f1-4 -d'|' | \
r.in.xyz --o in=- z=3 out=rast.lon

g.remove one

r.out.gdal -c type=Float32    createopt="COMPRESS=LZW,ZLEVEL=9"  input=rast.lon    output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/lat_long_tif/30arc-sec-lon.tif 
r.out.gdal -c type=Float32    createopt="COMPRESS=LZW,ZLEVEL=9"  input=rast.lat    output=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/lat_long_tif/30arc-sec-lat.tif 


exit 


r.in.gdal in=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/area_tif/75arc-sec-Area_prj28.tif    out=arc75ref   location=loc_latlong



