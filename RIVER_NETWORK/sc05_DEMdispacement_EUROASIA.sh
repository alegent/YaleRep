# bsub -W 4:00 -n 1 -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_DEMdispacement_EUROASIA.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_DEMdispacement_EUROASIA.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc03_DEMdispacement_EUROASIA.sh

DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK

# dem displacement 
                # 
# EUROASIA      13496    3562
# island-east    1191     333
# camptacha       497     497 
# island-west    1215     338



gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT3562_333msk.tif )  $DIR/dem/be75_grd_LandEnlarge.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_3562_333.tif  # EUROASIA  
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT497_338msk.tif  )  $DIR/dem/be75_grd_LandEnlarge.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_497_338.tif  # camptacha 

gdal_edit.py -a_ullr $(getCorners4Gtranslate $DIR/unit/UNIT3562_333msk.tif  | awk '{ print $1 - 50 , $2 , $3 -50  , $4 }' )             $DIR/dem_EUROASIA/be75_grd_LandEnlarge_3562_333.tif 
gdal_edit.py -a_ullr $(getCorners4Gtranslate   $DIR/unit/UNIT497_338msk.tif | awk '{ print 129.998,$2,129.998 + 180 -169.6416667 , $4 }')  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_497_338.tif  # camptacha  

rm -f  /tmp/out.vrt
gdalbuildvrt  /tmp/out.vrt   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_497_338.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_3562_333.tif  
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  /tmp/out.vrt   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_EUROASIA.tif 
rm -f  /tmp/out.vrt   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_497_338.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_3562_333.tif  

# occurence displacement 

gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT3562_333msk.tif )  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif  $DIR/GSW_unit/occurrence_250m_3562_333.tif
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT497_338msk.tif )   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/GSW/input/occurrence_250m.tif  $DIR/GSW_unit/occurrence_250m_497_338.tif

gdal_edit.py -a_ullr $(  getCorners4Gtranslate  $DIR/unit/UNIT3562_333msk.tif | awk '{ print $1 - 50 , $2 , $3 -50  , $4 }' )           $DIR/GSW_unit/occurrence_250m_3562_333.tif
gdal_edit.py -a_ullr $(getCorners4Gtranslate  $DIR/unit/UNIT497_338msk.tif | awk '{ print 129.998,$2,129.998 + 180 -169.6416667,$4 }')  $DIR/GSW_unit/occurrence_250m_497_338.tif  # camptacha  

rm -f  /tmp/out.vrt
gdalbuildvrt  /tmp/out.vrt   $DIR/GSW_unit/occurrence_250m_3562_333.tif     $DIR/GSW_unit/occurrence_250m_497_338.tif
gdal_translate          -co COMPRESS=DEFLATE -co ZLEVEL=9    /tmp/out.vrt   $DIR/GSW_unit/occurrence_250m_EUROASIA.tif
rm -f  /tmp/out.vrt    $DIR/GSW_unit/occurrence_250m_3562_333.tif           $DIR/GSW_unit/occurrence_250m_497_338.tif

# mask displacement 

cp $DIR/unit/UNIT3562_333msk.tif $DIR/unit/UNIT3562_333msk_displace.tif 
cp $DIR/unit/UNIT497_338msk.tif  $DIR/unit/UNIT497_338msk_displace.tif

gdal_edit.py -a_ullr $(getCorners4Gtranslate  $DIR/unit/UNIT3562_333msk.tif | awk '{ print $1 - 50 , $2 , $3 -50  , $4 }' )  $DIR/unit/UNIT3562_333msk_displace.tif 
gdal_edit.py -a_ullr $(getCorners4Gtranslate  $DIR/unit/UNIT497_338msk.tif | awk '{ print 129.998  , $2 ,  129.998 + 180 -169.6416667, $4 }' )  $DIR/unit/UNIT497_338msk_displace.tif  # camptacha  

rm -f  /tmp/out.vrt
gdalbuildvrt  /tmp/out.vrt   $DIR/unit/UNIT3562_333msk_displace.tif   $DIR/unit/UNIT497_338msk_displace.tif  
gdal_translate -a_nodata 0   -co COMPRESS=DEFLATE -co ZLEVEL=9  /tmp/out.vrt    $DIR/unit/UNIT497_338_3562_333msk.tif 
rm -f  /tmp/out.vrt   $DIR/unit/UNIT3562_333msk_displace.tif   $DIR/unit/UNIT497_338msk_displace.tif  






