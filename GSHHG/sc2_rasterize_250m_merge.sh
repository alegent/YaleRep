# bash /lustre/home/client/fas/sbsc/ga254/scripts/GSHHG/sc2_rasterize_250m_merge.sh  

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_merge

# any Enables the ALL_TOUCHED rasterization  , so the mask is extrimely the land is biger ...
gdalbuildvrt -overwrite -o  $DIR/output.vrt    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m/*.tif 
gdal_translate -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/output.vrt   $DIR/GSHHS_land_mask250m.tif 

# put color table to visualize better in openev 
pkcreatect  -min 0 -max 1 > /dev/shm/color.txt
pkcreatect   -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9    -ct /dev/shm/color.txt -i $DIR/GSHHS_land_mask250m.tif -o   $DIR/GSHHS_land_mask250m_ct.tif


exit 

# e' stata trasferita so la parte sottostante specifica  /home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc1_GSHHG_preparation.sh  cancelarre quando sicuri 


# enlarge of 4 pixels the rasterize cost line and use it to mask out the ocean in the dem 

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb/ loc_Cost  $DIR/GSHHS_land_mask250m.tif
r.grow  input=GSHHS_land_mask250m   output=GSHHS_land_mask250m_enlarge  radius=4.01
r.out.gdal  --overwrite -f  -c  createopt="COMPRESS=LZW,BIGTIFF=YES" format=GTiff type=Byte  input=land_mask250m_enlarge  output=$DIR/GSHHS_land_mask250m_enlarge.tif

# crop artico e antartide 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin -180 +84 +180 -60 $DIR/land_mask250m_enlarge.tif $DIR/GSHHS_land_mask250m_enlarge_crop.tif

echo pkcreatect  GSHHS_land_mask250m_enlarge_crop_ct.tif
pkcreatect -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct /dev/shm/color.txt -i $DIR/GSHHS_land_mask250m_enlarge_crop.tif -o $DIR/GSHHS_land_mask250m_enlarge_crop_ct.tif


# start the clump 
# rm -r  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb/loc_clump
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2.sh  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/grassdb/ loc_clump  $DIR/GSHHS_land_mask250m_enlarge_crop.tif
r.mask raster=GSHHS_land_mask250m_enlarge_crop
echo start r.clump
r.clump -d  --overwrite  input=GSHHS_land_mask250m_enlarge_crop   output=GSHHS_land_mask250m_enlarge_crop_clump
r.out.gdal  --overwrite -f  -c  createopt="COMPRESS=DEFLATE,ZLEVEL=9,BIGTIFF=YES" format=GTiff type=UInt32  input=GSHHS_land_mask250m_enlarge_crop_clump  output=$DIR/GSHHS_land_mask250m_enlarge_crop_clump.tif

# done to remove the BIGTIFF=YES
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/GSHHS_land_mask250m_enlarge_crop_clump.tif $DIR/GSHHS_land_mask250m_enlarge_crop_clumpA.tif

mv $DIR/GSHHS_land_mask250m_enlarge_crop_clumpA.tif $DIR/GSHHS_land_mask250m_enlarge_crop_clump.tif

# min and max 1.000 99784.000 

# change the sea to 0 
pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -nodata 0   -msknodata 0  -m  $DIR/GSHHS_land_mask250m_enlarge_crop.tif -i   $DIR/GSHHS_land_mask250m_enlarge_crop_clump.tif  -o   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0.tif 

pkstat --hist -i  $DIR/GSHHS_land_mask250m_enlarge_crop_clump0.tif | grep  -v " 0"  >  $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_hist.txt

awk '{ if($2<4) {  print $1 , 0} else { print $1 , $1 }  }'     $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_hist.txt >   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_hist_reclass.txt 

pkreclass  -co COMPRESS=DEFLATE -co ZLEVEL=9  -code  $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_hist_reclass.txt -msknodata 0 -nodata 0   -m   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0.tif   -i   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0.tif -o   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclass.tif 

calculate unit statistic and remove island with average = 0 ; far ricorrer considerando anche la STD 

oft-stat -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/be75_grd_tif/be75_grd_Land.tif -o  $DIR/GSHHS_land_mask250m_enlarge_crop_clump_hist_reclass_GMTED.txt    -um   $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclass.tif  

awk '{ if($3==0  || $4==0 || -9999 ) {  print $1 , 0 } else { print $1 , $1 }  }'   $DIR/GSHHS_land_mask250m_enlarge_crop_clump_hist_reclass_GMTED.txt  >  $DIR/GSHHS_land_mask250m_enlarge_crop_clump_hist_reclass_GMTEDreclass.txt

pkreclass  -co COMPRESS=DEFLATE -co ZLEVEL=9  -code  $DIR/GSHHS_land_mask250m_enlarge_crop_clump_hist_reclass_GMTEDreclass.txt -msknodata 0 -nodata 0 -m $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclass.tif  -i $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclass.tif  -o  $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclassGMTEDreclass.tif 

pkstat --hist -i  $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclassGMTEDreclass.tif | grep  -v " 0" > $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclassGMTEDreclass_hist.txt 

TIFMSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_continent_merge

# 0-E EUROASIA EAST                                                                                                                                    
# 0-W EUROASIA WEST                                                                                                                                    
# 1 africa                                                                                                                                             
# 2 NA                                                                                                                                                 
# 3 SA                                                                                                                                                 
# 4 ?                                                                                                                                                  
# 5 ?                                                                                                                                                  
# 6 AU                                                                                                                                                 
# 7 GL                                                                                                                                                 
# 8 NZ                                                                                                                                                 
# 9 BR                                                                                                                                                 
# 10 MG                                                                                                                                                

# 31813 computational unit 

pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  \
-nodata  9999   -msknodata 1  -m   $TIFMSK/continent0-E_crop_enlarge4.tif  \
-nodata 10000   -msknodata 1  -m   $TIFMSK/continent0-W_crop_enlarge4.tif  \
-nodata 10001   -msknodata 1  -m   $TIFMSK/continent1_crop_enlarge4.tif  \
-nodata 10002   -msknodata 1  -m   $TIFMSK/continent2_crop_enlarge4.tif  \
-nodata 10003   -msknodata 1  -m   $TIFMSK/continent3_crop_enlarge4.tif  \
-nodata 10006   -msknodata 1  -m   $TIFMSK/continent6_crop_enlarge4.tif  \
-nodata 10007   -msknodata 1  -m   $TIFMSK/continent7_crop_enlarge4.tif  \
-i $DIR/GSHHS_land_mask250m_enlarge_crop_clump0_reclassGMTEDreclass.tif -o $DIR/GSHHS_land_mask250m_enlarge_compUNIT.tif 

# final computational unit  
pkstat --hist -i   $DIR/GSHHS_land_mask250m_enlarge_compUNIT.tif | grep  -v " 0" >   $DIR/GSHHS_land_mask250m_enlarge_compUNIT.txt

