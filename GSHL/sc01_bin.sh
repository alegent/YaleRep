# qsub /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/scripts/sc1_bin.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/


# gdalwarp -overwrite -te -180 -90 +180 +90 -tr 0.008333333333333333333 0.008333333333333333333 -tap -t_srs EPSG:4326 -r bilinear -co COMPRESS=DEFLATE -co ZLEVEL=9 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84.tif

# oft-calc -ot Byte $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin.tif <<EOF
# 1
# #1 10 *
# EOF

# pkcreatect -co COMPRESS=DEFLATE -co ZLEVEL=9  -min 0 -max 11 -i   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin.tif -o  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin_ct.tif
# rm  -f  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin.tif 

pkcreatect -min 0 -max 1 > /tmp/color.tif 


echo 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5 | xargs -n 1 -P 8 bash -c $' 
MIN=$1 
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9  -min $MIN  -max 11 -data 1 -nodata 0 -ct  /tmp/color.tif -i ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin_ct.tif -o ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$MIN.tif 
rm -f /tmp/color.tif 

oft-clump -i  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$MIN.tif  -o  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump.tif  -um  ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$MIN.tif 

gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9   ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump.tif    ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump_tmp.tif 
mv    ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump_tmp.tif    ${DIR}_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${MIN}_clump.tif 

' _  

