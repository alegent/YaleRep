# /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID 

echo -180 0   0 north_west  > /tmp/xy_geoid.txt
echo    0 0   1 north_east >> /tmp/xy_geoid.txt
echo -180 -90 2 south_west >> /tmp/xy_geoid.txt
echo    0 -90 3 south_east >> /tmp/xy_geoid.txt


cat /tmp/xy_geoid.txt  | xargs -n 4 -P 4  bash -c $' 

X=$1
Y=$2
N=$3
TILE=$4

echo "ncols        86400"                 >  raster_${TILE}.asc 
echo "nrows        43200"                 >> raster_${TILE}.asc 
echo "xllcorner    $X"                    >> raster_${TILE}.asc 
echo "yllcorner    $Y"                    >> raster_${TILE}.asc 
echo "cellsize     0.002083333333333"     >> raster_${TILE}.asc 

echo create asc $TILE

awk -v N=$N \' BEGIN {  
for (row=1 ; row<=43200 ; row++)  { 
     for (col=1 ; col<=86400 ; col++) { 
         printf ("%i " , N *  3732480000 + (  col+(row-1)*86400 ) ) } ; printf ("\\n")  }}\' >> raster_${TILE}.asc 

echo create tif  $TILE

gdal_translate  -ot  Float32 -co  COMPRESS=LZW -co ZLEVEL=9  raster_${TILE}.asc   raster_${TILE}.tif 

' _ 



# transform the created arcinfo ascii grid in a tif.

gdalbuildvrt      -te -180  -90  180 90       -overwrite  glob_ID_rast.vrt    raster_*_*.tif 

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9   glob_ID_rast.vrt   glob_ID_rast250m.tif 

gdal_translate        -co PREDICTOR=2  -co  COMPRESS=LZW -co ZLEVEL=9     glob_ID_rast.tif      glob_ID_rast250m_super_compres.tif