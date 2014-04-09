

# echo  1 2 3 4 5 6 7 8 9 | xargs -n 1  -P 10  bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc1_rasterize_point.sh 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=10gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0



export RASTERIZE=/lustre0/scratch/ga254/dem_bj/WDPA/rasterize_buf 
export SHP=/lustre0/scratch/ga254/dem_bj/WDPA/shp_buf
n=$1

# attribute of the shapefile land NO-MARINE

#   IUCN_CAT (String) = Ia               11
#   IUCN_CAT (String) = Ib               12
#   IUCN_CAT (String) = II               2
#   IUCN_CAT (String) = III              3
#   IUCN_CAT (String) = IV               4
#   IUCN_CAT (String) = Not Applicable   20
#   IUCN_CAT (String) = Not Reported     21
#   IUCN_CAT (String) = V                5
#   IUCN_CAT (String) = VI               6


# attribute of the shapefile MARINE

#   IUCN_CAT (String) = Ia               111
#   IUCN_CAT (String) = Ib               112
#   IUCN_CAT (String) = II               102
#   IUCN_CAT (String) = III              103
#   IUCN_CAT (String) = IV               104
#   IUCN_CAT (String) = Not Applicable   120
#   IUCN_CAT (String) = Not Reported     121
#   IUCN_CAT (String) = V                105
#   IUCN_CAT (String) = VI               106



echo rasterize the land 

if [ $n -eq 1  ] ; then  IUCN_CAT='"Ia"' ;              BURN=11 ; fi 
if [ $n -eq 2  ] ; then  IUCN_CAT='"Ib"' ;              BURN=12 ; fi 
if [ $n -eq 3  ] ; then  IUCN_CAT='"II"' ;              BURN=2  ; fi 
if [ $n -eq 4  ] ; then  IUCN_CAT='"III"';              BURN=3  ; fi 
if [ $n -eq 5  ] ; then  IUCN_CAT='"IV"' ;              BURN=4  ; fi 
if [ $n -eq 6  ] ; then  IUCN_CAT='"Not Applicable"' ;  BURN=20 ; fi 
if [ $n -eq 7  ] ; then  IUCN_CAT='"Not Reported"' ;    BURN=21 ; fi 
if [ $n -eq 8  ] ; then  IUCN_CAT='"V"'  ;              BURN=5  ; fi 
if [ $n -eq 9  ] ; then  IUCN_CAT='"VI"' ;              BURN=6  ; fi 


rm -f $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp

ogr2ogr   -sql   "SELECT * FROM  WDPA_point_Jan2014EPSG4326Buf  WHERE  ( IUCN_CAT = ${IUCN_CAT} )  AND (  MARINE = '0')   "   $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp    $SHP/WDPA_point_Jan2014EPSG4326Buf.shp 



rm -f   $RASTERIZE/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.tif 

gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014EPSG4326BufIUCN$BURN   -a IUCN_CAT \
-burn $BURN   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9 $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp    $RASTERIZE/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.tif


echo rasterize the marine 

if [ $n -eq 1  ] ; then  IUCN_CAT='"Ia"' ;              BURN=111 ; fi 
if [ $n -eq 2  ] ; then  IUCN_CAT='"Ib"' ;              BURN=112 ; fi 
if [ $n -eq 3  ] ; then  IUCN_CAT='"II"' ;              BURN=102  ; fi 
if [ $n -eq 4  ] ; then  IUCN_CAT='"III"';              BURN=103  ; fi 
if [ $n -eq 5  ] ; then  IUCN_CAT='"IV"' ;              BURN=104  ; fi 
if [ $n -eq 6  ] ; then  IUCN_CAT='"Not Applicable"' ;  BURN=120 ; fi 
if [ $n -eq 7  ] ; then  IUCN_CAT='"Not Reported"' ;    BURN=121 ; fi 
if [ $n -eq 8  ] ; then  IUCN_CAT='"V"'  ;              BURN=105  ; fi 
if [ $n -eq 9  ] ; then  IUCN_CAT='"VI"' ;              BURN=106  ; fi 


rm -f $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp

ogr2ogr   -sql   "SELECT * FROM  WDPA_point_Jan2014EPSG4326Buf  WHERE  ( IUCN_CAT = ${IUCN_CAT} )  AND (  MARINE = '1')   "   $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp    $SHP/WDPA_point_Jan2014EPSG4326Buf.shp 

rm -f   $RASTERIZE/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.tif
gdal_rasterize -ot Byte -a_srs EPSG:4326 -l WDPA_point_Jan2014EPSG4326BufIUCN$BURN   -a IUCN_CAT \
-burn $BURN   -a_nodata 0  -tr   0.008333333333333 0.008333333333333  -te  $(getCorners4Gwarp /lustre0/scratch/ga254/dem_bj/WDPA/rasterize/6/IUCN6.tif )  -co COMPRESS=LZW \
-co ZLEVEL=9 $SHP/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.shp    $RASTERIZE/WDPA_point_Jan2014EPSG4326BufIUCN$BURN.tif








