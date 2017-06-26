
# qsub    /home6/gamatull/scripts/LST/mask/sc4_val_area_selection.sh

# LST3k deriva dal QC quindi potrebbe avere dei pixel non mappati 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=1
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo  /u/gamatull/scripts/LST/sc1_val_area_selection.sh

export LST=/nobackupp8/gamatull/dataproces/LST
export RAMDIR=/dev/shm

rm -f /dev/shm/*

# sum up area with lst value in order to have area with full observation; the area with 46 area will full data cover 

cp $LST/MOD11A2_mean_msk/MOD_LST3k_mask_day001_wgs84.tif 
gdal_edit.py -a_nodata -1 /dev/shm/MOD_sum.tif

for file in $LST/MOD11A2_mean_msk/MOD_LST3k_mask_day[0-9]??_wgs84.tif   ; do 
echo sum $file
gdal_edit.py -a_nodata -1 $file    
gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A $file -B /dev/shm/MOD_sum.tif --outfile=/dev/shm/MOD_sum_post.tif  --calc="(A + B)"  
gdal_edit.py -a_nodata -1 /dev/shm/MOD_sum_post.tif
mv /dev/shm/MOD_sum_post.tif   /dev/shm/MOD_sum.tif 
done

gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A /dev/shm/MOD_sum.tif --outfile=$LST/MOD11A2_mean_msk/MOD_LST3k_mask_daySUM_wgs84.tif --calc="(A -1 )"
pkcreatect -min 0 -max 46   > /tmp/color.txt
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct  /tmp/color.txt   -i $LST/MOD11A2_mean_msk/MOD_LST3k_mask_daySUM_wgs84.tif -o   $LST/MOD11A2_mean_msk/MOD_LST3k_mask_daySUM_wgs84_ct.tif

rm -f /dev/shm/*

cp $LST/MYD11A2_mean_msk/MYD_LST3k_mask_day001_wgs84.tif  /dev/shm/MYD_sum.tif
gdal_edit.py -a_nodata -1 /dev/shm/MYD_sum.tif

for file in $LST/MYD11A2_mean_msk/MYD_LST3k_mask_day[0-9]??_wgs84.tif   ; do 
echo sum $file
gdal_edit.py -a_nodata -1 $file    
gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A $file -B /dev/shm/MYD_sum.tif --outfile=/dev/shm/MYD_sum_post.tif  --calc="(A + B)"  
gdal_edit.py -a_nodata -1 /dev/shm/MYD_sum_post.tif
mv /dev/shm/MYD_sum_post.tif   /dev/shm/MYD_sum.tif 
done

gdal_calc.py --overwrite  --type=Byte  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9   -A /dev/shm/MYD_sum.tif --outfile=$LST/MYD11A2_mean_msk/MYD_LST3k_mask_daySUM_wgs84.tif --calc="(A -1 )"
pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct  /tmp/color.txt   -i $LST/MYD11A2_mean_msk/MYD_LST3k_mask_daySUM_wgs84.tif -o   $LST/MYD11A2_mean_msk/MYD_LST3k_mask_daySUM_wgs84_ct.tif

rm -f /dev/shm/*

