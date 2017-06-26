# qsub /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/scripts/sc02_core.sh

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# chmod -R g+rwx /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin

# pkcreatect -min 0 -max 1 > /tmp/color.txt 
# pkcreatect -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Byte  -nodata -1 -min 0 -max 1  -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9.5.tif   -o  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9.5_clean.tif
# gdal_edit.py -a_nodata -1  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9.5_clean.tif

# echo 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5  | xargs -n 1 -P 8 bash -c $'
# gdal_edit.py -a_nodata -1             $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin$1.tif
# ' _


# echo 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5  | xargs -n 1 -P 8 bash -c $'

#     bin1=$1
#     bin2=$(bc <<< "$bin1-1")
#     echo $bin1
#         rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif 
#         gdal_calc.py --calc="A+B" --co="COMPRESS=LZW" --overwrite --NoDataValue=-1 \
#             -A $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}.tif \
#             -B $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}.tif \
#             --outfile=$DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif

#         oft-stat -mm --noavg --nostd \
#             -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif \
#             -um $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clump.tif \
#             -o  $DIR/zonal_stats_${bin2}.txt

#         awk \'{if($4==1) { print $1,1 }  else { print $1,0 }}\' $DIR/zonal_stats_${bin2}.txt > $DIR/code_${bin2}.txt

#         pkreclass -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -nodata -1 -ct /tmp/color.txt \
#             -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clump.tif \
#             -o $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clean.tif \
#             --code $DIR/code_${bin2}.txt

#         rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif
#         rm -f $DIR/zonal_stats_${bin2}.txt
#         rm -f $DIR/code_${bin2}.txt

# ' _


# gdalbuildvrt -overwrite  -separate $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt $DIR/*_clean.tif

# oft-calc -ot Byte $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif << EOF
# 1
# #1 #2 #3 #4 #5 #6 #7 #8 #9 + + + + + + + +
# EOF


# rm $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt 

# pkcreatect  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -nodata -1 -min 0 -max 1   -co COMPRESS=DEFLATE -co ZLEVEL=9 -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif -o  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct.tif
# rm  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif

# oft-clump \
#     -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct.tif \
#     -o  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif \
#     -um $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct.tif

# gdal_translate  -a_nodata -1  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump.tif
# rm  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif


exit 

# seams that the below part is not needed 
# # second run skipping one bin


# echo 3.5 4.5 5.5 6.5 7.5 8.5 9.5  | xargs -n 1 -P 8 bash -c $'

#     bin1=$1
#     bin2=$(bc <<< "$bin1-2")
#     echo $bin1
#         rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif 
#         gdal_calc.py --calc="A+B" --co="COMPRESS=LZW" --overwrite --NoDataValue=-1 \
#             -A $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}.tif \
#             -B $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}.tif \
#             --outfile=$DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif

#         oft-stat -mm --noavg --nostd \
#             -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif \
#             -um $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clump.tif \
#             -o  $DIR/zonal_stats_${bin2}.txt

#         awk \'{if($4==1) { print $1,1 }  else { print $1,0 }}\' $DIR/zonal_stats_${bin2}.txt > $DIR/code_${bin2}.txt

#         pkreclass -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -nodata -1 -ct /tmp/color.txt \
#             -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clump.tif \
#             -o $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin2}_clean.tif \
#             --code $DIR/code_${bin2}.txt

#         rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${bin1}+${bin2}.tif
#         rm -f $DIR/zonal_stats_${bin2}.txt
#         rm -f $DIR/code_${bin2}.txt

# ' _


gdalbuildvrt -overwrite  -separate $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin{1.5,2.5,3.5,4.5,5.5,6.5,7.5}_clean.tif

oft-calc -ot Byte $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif << EOF
1
#1 #2 #3 #4 #5 #6 #7 + + + + + +
EOF

rm $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.vrt 

pkcreatect  -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -nodata -1 -min 0 -max 1   -co COMPRESS=DEFLATE -co ZLEVEL=9 -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif -o  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct2.tif
rm  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_tmp.tif

oft-clump \
    -i  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct.tif \
    -o  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif \
    -um $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_ct2.tif

gdal_translate  -a_nodata -1  -co COMPRESS=DEFLATE -co ZLEVEL=9   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump2.tif
rm  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core_clump_tmp.tif




