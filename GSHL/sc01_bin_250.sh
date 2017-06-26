#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc01_bin_250.sh 
#SBATCH -N 1  --cpus-per-task=8
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_bin_250.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_bin_250.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc01_bin_250.sh 

module load Libs/ARMADILLO/7.700.0

# bash /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc01_bin_250.sh 
# bsub -W 24:00 -M 15000 -R "rusage[mem=15000]" -n 8 -R "span[hosts=1]" -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_bin_250.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_bin_250.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc01_bin_250.sh 

export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0

# gdalwarp -overwrite -te -180 -60 +180 +80 -tr 0.00208333333333333333333  0.00208333333333333333333  -srcnodata -3.4028234663852886e+3 -dstnodata "None" -t_srs EPSG:4326 -r bilinear -co COMPRESS=DEFLATE -co ZLEVEL=9 -co BIGTIFF=YES  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_warp.tif

# pksetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -co BIGTIFF=YES    -m $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_warp.tif -msknodata 0 -p '<' -nodata 0 -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_warp.tif -o $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_msk.tif

mv  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_msk.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84.tif
gdal_edit.py -a_nodata -1   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84.tif

oft-calc -ot Byte $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin.tif <<EOF
1
#1 0.05 + 10 * 1 -
EOF

pkcreatect -min 0 -max 9 > /tmp/color.txt 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9  -ct  /tmp/color.txt -m  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin.tif -msknodata 10 -nodata 9  -i   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin.tif -o   ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin_ct.tif
gdal_edit.py -a_nodata -1   ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin_ct.tif

rm  -f  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin.tif 

pkcreatect -min 0 -max 1 > /tmp/color.txt 

echo 1 2 3 4 5 6 7 8 9 | xargs -n 1 -P 8 bash -c $' 
BIN=$1
MIN=$( echo $1 - 0.5 | bc )  

pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -min $MIN  -max 9.5  -data 1 -nodata 0 -ct  /tmp/color.txt  -i ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin_ct.tif -o ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN.tif 
gdal_edit.py -a_nodata 0   ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN.tif  

rm -fr  ${DIR}_bin/grassdb_250/loc_clump$BIN                                                                        
source /gpfs/home/fas/sbsc/ga254/scripts/general/create_location_grass7.0.2-grace2.sh  ${DIR}_bin/grassdb_250  loc_clump$BIN ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN.tif 

r.clump -d  --overwrite    input=GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN     output=GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN
r.colors -r map=GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN

r.out.gdal nodata=0 --overwrite -f -c createopt="COMPRESS=DEFLATE,ZLEVEL=9" format=GTiff type=UInt32  input=GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin$BIN  output=${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump.tif 
rm -rf ${DIR}_bin/grassdb_250/loc_clump$BIN

# bash /gpfs/home/fas/sbsc/ga254/scripts/general/createct_random.sh  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump.tif  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump_random_color.txt 
# gdaldem color-relief -co COMPRESS=DEFLATE -co ZLEVEL=9  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump.tif  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump_random_color.txt  ${DIR}_bin/GHS_BUILT_LDS2014_# GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump_ct.tif
# gdal_edit.py -a_nodata 0  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump_ct.tif

rm  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump_random_color.txt ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_250_v1_0_WGS84_bin${BIN}_clump.tif.aux.xml

' _  

rm -f /tmp/color.txt 

exit 


bsub  -W 08:00  -n 4  -R "span[hosts=1]"  -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc02_core.sh.%J.out  -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc02_core.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc02_core.sh
