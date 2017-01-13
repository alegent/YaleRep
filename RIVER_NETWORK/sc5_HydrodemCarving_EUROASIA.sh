#   qsub /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_HydrodemCarving_EUROASIA.sh 

# 90420 11750011      MADAGASCAR        
# 10328 12535192      canada island 
# 80691 13772932     indonesia 
# 84397 14731200     guinea 
# 2285 22431475      canada island 
# 26487 26414813     canada island 
# 33778 150020638    greenland      
# 92404 158200595     AUSTRALIA
# 11000 350855901     south america 
# 11001 576136081     africa 
# 98343 596887982     north america 
# 91518 1474765872    EUROASIA    
# 19899               EUROASIA camptacha


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:8:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

TRH=$TRH

# euroasia camptacha data preparation 

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT19899msk.tif )  $DIR/dem/be75_grd_LandEnlarge_cond_carv100smoth.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_19899.tif  # camptacha 
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $( getCorners4Gtranslate $DIR/unit/UNIT91518msk.tif )  $DIR/dem/be75_grd_LandEnlarge_cond_carv100smoth.tif   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_91518.tif # EUROASIA

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/unit/UNIT19899msk.tif  --msknodata 0 -nodata -9999    -i $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_19899.tif -o  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_19899msk.tif
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -m  $DIR/unit/UNIT91518msk.tif  --msknodata 0 -nodata -9999    -i $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_91518.tif -o  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_91518msk.tif


# pkinfo   -te   -i   $DIR/unit/UNIT91518msk.tif  | awk '{ printf ("%.10f %.10f %.10f %.10f\n" ,  $2 - 50 , $5 , $4 - 50  , $3 )  }'  # messo a mano per l'arrotodamento decimale 
gdal_edit.py -a_ullr  -59.5020833333 77.720833333333 129.997916666666 1.2687500000        $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_91518msk.tif 
                                                       
gdal_edit.py -a_ullr  129.997916666666  68.9958333333333   140.3562500000   64.2375000           $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_19899msk.tif  # camptacha  

rm -f  /tmp/out.vrt
gdalbuildvrt  /tmp/out.vrt   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_19899msk.tif  $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_91518msk.tif  
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  /tmp/out.vrt   $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA.tif 
rm -f  /tmp/out.vrt

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb loc_river_EUROASIA $DIR/dem_EUROASIA/be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA.tif 

exit 

# non piu usato
source /lustre/home/client/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/grassdb/loc_river_EUROASIA/PERMANENT

g.region res=0.0083333333333333333333  -a 
r.resamp.stats -nw input=be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA  output=be75_grd_LandEnlarge_cond_carv100smoth_EUROASIA_km method=average






