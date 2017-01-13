# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc10_river_newtworkGMTED250_mergeEUROASIA.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

echo start the script 
export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK

# clip out the broken basin 
echo LEFT 10 CENTER 10 RIGHT 10 LEFT 100 CENTER 100 RIGHT 100  | xargs -n 2   -P  8 bash  -c $'   
SIDE=$1
TRH=$2
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/output/basin_last/basin_last91518_${SIDE}_trh${TRH}_cleanmsk.tif -msknodata 0 -nodata 0 -i $DIR/output/stream/stream01_91518_${SIDE}_trh$TRH.tif  -o $DIR/output/stream/stream01_91518_${SIDE}clip_trh$TRH.tif 
' _ 

pkcreatect   -min 0 -max 1 > /tmp/color.txt 

echo  10 100 | xargs -n 1 -P 2 bash  -c $'   
TRH=$1
gdalbuildvrt -separate  -overwrite  $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.vrt   $DIR/output/stream/stream01_91518_LEFTclip_trh$TRH.tif   $DIR/output/stream/stream01_91518_CENTERclip_trh$TRH.tif  $DIR/output/stream/stream01_91518_RIGHTclip_trh$TRH.tif  
 
oft-calc -ot Byte $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.vrt   $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.tif   <<EOF
1
#1 #2 #3 + + 
EOF

pkgetmask  -ot Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -min 0.5 -max 10 -data 1 -data 0 -ct /tmp/color.txt  -i $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.tif  -o  $DIR/output/stream/stream01_91518_MERGE_clip_trh${TRH}_ct.tif  
# rm -f $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.tif   $DIR/output/stream/stream01_91518_LEFTclip_trh$TRH.tif   $DIR/output/stream/stream01_91518_CENTERclip_trh$TRH.tif  $DIR/output/stream/stream01_91518_RIGHTclip_trh$TRH.tif  $DIR/output/stream/stream01_91518_MERGE_clip_trh$TRH.vrt 
 
# crop and shift 
# euroasia
xoff=0
yoff=0 
xsize=$(gdalinfo  $DIR/unit/UNIT91518msk.tif | grep "Size is" | awk \'{gsub(",","") ;  print $3 }\' ) 
ysize=$(gdalinfo  $DIR/unit/UNIT91518msk.tif | grep "Size is" | awk \'{gsub(",","") ;  print $4 }\' )

gdal_translate -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/stream/stream01_91518_MERGE_clip_trh${TRH}_ct.tif   $DIR/output/stream/stream01_91518_MERGEleft_clip_trh${TRH}_ct.tif 
gdal_edit.py -a_ullr $(  getCorners4Gtranslate   $DIR/unit/UNIT91518msk.tif )  $DIR/output/stream/stream01_91518_MERGEleft_clip_trh${TRH}_ct.tif 

# camptacha 
xoff=$(gdalinfo  $DIR/unit/UNIT91518msk.tif   | grep "Size is" | awk \'{gsub(",","") ;  print $3 }\' ) 
yoff=0
xsize=$(gdalinfo  $DIR/unit/UNIT19899msk.tif  | grep "Size is" | awk \'{gsub(",","") ;  print $3 }\' ) 
ysize=$(gdalinfo  $DIR/unit/UNIT91518msk.tif  | grep "Size is" | awk \'{gsub(",","") ;  print $4 }\' ) 

gdal_translate -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9  -srcwin $xoff $yoff $xsize $ysize  $DIR/output/stream/stream01_91518_MERGE_clip_trh${TRH}_ct.tif   $DIR/output/stream/stream01_91518_MERGEright_clip_trh${TRH}_ct.tif 

ulx=$(getCorners4Gtranslate $DIR/unit/UNIT19899msk.tif |   awk \'{gsub(",","") ;  print $1 }\' )
uly=$(getCorners4Gtranslate $DIR/output/stream/stream01_91518_MERGEright_clip_trh${TRH}_ct.tif |  awk \'{gsub(",","") ;  print $2 }\' )
lrx=$(getCorners4Gtranslate $DIR/unit/UNIT19899msk.tif |   awk \'{gsub(",","") ;  print $3 }\' )
lry=$(getCorners4Gtranslate $DIR/output/stream/stream01_91518_MERGEright_clip_trh${TRH}_ct.tif |  awk \'{gsub(",","") ;  print $4 }\' )

gdal_edit.py -a_ullr $ulx $uly $lrx $lry  $DIR/output/stream/stream01_91518_MERGEright_clip_trh${TRH}_ct.tif 

' _

rm -f  /tmp/color.txt 

exit 

qsub   -v TRH=100  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh
qsub   -v TRH=10   /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc11_continentisland_merge_oft-calc.sh




 
