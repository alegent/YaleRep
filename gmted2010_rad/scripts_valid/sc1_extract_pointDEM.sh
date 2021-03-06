cd /mnt/data2/scratch/GMTED2010/solar_radiation 
rm  -f shp/point_mn30_grd.*

pkextract   -i ../grassdb/mn30_grd_tif/mn30_grd.tif -ft  Integer -bn alt -s shp/point.shp -o  shp/point_mn30_grd.shp
gdal_rasterize -a_nodata -1  -tr 0.008333333300000 0.008333333300000  -co COMPRESS=LZW -co ZLEVEL=9  -te -180 -90 +180 +90  -ot  Int16 -a alt -l   point_mn30_grd    shp/point_mn30_grd.shp   tif/point_mn30_grd.tif

export INDIRG=/media/data/grassdb1
cp /mnt/data2/scratch/GMTED2010/solar_radiation/tif/point_mn30_grd.tif $INDIRG

cd $INDIRG
rm -rf $INDIRG/loc_point
/mnt/data2/scratch/GMTED2010/scripts/create_location_gr.sh  point_mn30_grd.tif  loc_point /media/data/grassdb1




rm -f $file 
# echo enter in grass 

echo "LOCATION_NAME: loc_$filename"              >  $HOME/.grassrc6$$
echo "MAPSET: PERMANENT"                         >> $HOME/.grassrc6$$
echo "DIGITIZER: none"                           >> $HOME/.grassrc6$$
echo "GRASS_GUI: text"                           >> $HOME/.grassrc6$$
echo "GISDBASE: $INDIRG"            >> $HOME/.grassrc6$$

# path to GRASS binaries and libraries:

export GISBASE=/usr/lib/grass64
export PATH=$PATH:$GISBASE/bin:$GISBASE/scripts
export LD_LIBRARY_PATH="$GISBASE/lib"
export GISRC=~/.grassrc6$$

# create a mask 

r.mapcalc "mask = if (  point_mn30_grd.tif > -100 , 1 , null ())"


# create a buffer around each point 
r.grow input=point_mn30_grd.tif  output=point_mn30_buf radius=500 new=1 --overwrite

g.mremove -f  rast=*_rad_day*