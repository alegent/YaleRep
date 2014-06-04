

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0


SHP=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/shp
REFER=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/reference_tif
TILES=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles

# rasterize green_land poligon  30 arc sec 
rm -f $SHP/green_land30arc-sec.tif
gdal_rasterize  -co COMPRESS=LZW   -ot Byte  -a id -l green_land   -tr  0.008333333333333 0.008333333333333 -te $(/home2/ga254/bin/getCorners4Gwarp $REFER/geo30arcsec_reference.tif) $SHP/green_land.shp $SHP/green_land30arc-sec.tif 

geo_string=$(/home2/ga254/bin/oft-bb $SHP/green_land30arc-sec.tif   1 | grep BB | awk '{ print $6,$7,$8-$6,$9-$7 }')
# clip the tif 
gdal_translate -srcwin  $geo_string   -co COMPRESS=LZW  -ot Byte $SHP/green_land30arc-sec.tif  $SHP/green_land30arc-sec_msk.tif  


# rasterize green_land poligon  30 arc sec 
rm -f $SHP/green_land7.5arc-sec.tif
gdal_rasterize  -co COMPRESS=LZW   -ot Byte  -a id -l green_land   -tr 0.002083333333333 0.002083333333333  -te $(/home2/ga254/bin/getCorners4Gwarp $REFER/geo30arcsec_reference.tif) $SHP/green_land.shp $SHP/green_land7.5arc-sec.tif 

geo_string=$(/home2/ga254/bin/oft-bb $SHP/green_land7.5arc-sec.tif   1 | grep BB | awk '{ print $6,$7,$8-$6,$9-$7 }')
# clip the tif 
gdal_translate -srcwin  $geo_string   -co COMPRESS=LZW  -ot Byte $SHP/green_land7.5arc-sec.tif  $SHP/green_land7.5arc-sec_msk.tif  


# prepare the integration of greeland mn for mn md mx mn 

gdal_translate -a_nodata -1  -co COMPRESS=LZW -projwin $(~/bin/getCorners4Gtranslate $SHP/green_land7.5arc-sec_msk.tif) $TILES/mn30_grd_tif/mn30_grd.tif $TILES/mn30_grd_tif/mn30_grd_greenland.tif

rm -f $TILES/mn75_grd_tif/green_land.tif
gdalwarp  -srcnodata -1    -dstnodata -1  -r cubicspline  -co COMPRESS=LZW     -tr 0.002083333333333 0.002083333333333 $TILES/mn30_grd_tif/mn30_grd_greenland.tif   $TILES/mn75_grd_tif/green_land.tif

pksetmask -i $TILES/mn75_grd_tif/green_land.tif -m $SHP/green_land7.5arc-sec_msk.tif  -t 0 -f 0 -o $TILES/mn75_grd_tif/green_land_msk.tif

gdal_translate -a_nodata -1   -co COMPRESS=LZW -projwin $(~/bin/getCorners4Gtranslate $SHP/green_land7.5arc-sec_msk.tif) $TILES/ds30_grd_tif/mn30_grd.tif $TILES/ds30_grd_tif/mn30_grd_greenland.tif

rm -f $TILES/ds75_grd_tif/green_land.tif

gdalwarp -srcnodata -1  -dstnodata -1 -r cubicspline  -co COMPRESS=LZW    -tr 0.002083333333333 0.002083333333333  $TILES/ds30_grd_tif/ds30_grd.tif $TILES/ds75_grd_tif/green_land.tif

pksetmask -i $TILES/ds75_grd_tif/green_land.tif -m $SHP/green_land7.5arc-sec_msk.tif  -t 0 -f 0 -o $TILES/ds75_grd_tif/green_land_msk.tif


# cp the grenland mn to the other directory 
cp $TILES/mn75_grd_tif/green_land_msk.tif  $TILES/mi75_grd_tif/green_land_msk.tif
cp $TILES/mn75_grd_tif/green_land_msk.tif  $TILES/mx75_grd_tif/green_land_msk.tif
cp $TILES/mn75_grd_tif/green_land_msk.tif  $TILES/md75_grd_tif/green_land_msk.tif
cp $TILES/mn75_grd_tif/green_land_msk.tif  $TILES/be75_grd_tif/green_land_msk.tif



