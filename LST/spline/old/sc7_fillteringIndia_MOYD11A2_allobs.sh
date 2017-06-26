
#  qsub -v SENS=MYD  /u/gamatull/scripts/LST/spline/sc7_fillteringIndia_MOYD11A2_allobs.sh 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=24
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr




gdal_translate -projwin  65 35 100 5  -co COMPRESS=LZW -co ZLEVEL=9 /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_mask_daySUM_wgs84_allobs.tif    /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/indiaMYD_LST3k_mask_daySUM_wgs84_allobs.tif  

pkgetmask -min -1 -max 43 -data 1 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9   -i    /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/indiaMYD_LST3k_mask_daySUM_wgs84_allobs.tif   -o   /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/india43MYD_LST3k_mask_daySUM_wgs84_allobs.tif   

pksetmask   -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/india43MYD_LST3k_mask_daySUM_wgs84_allobs.tif -msknodata 0   -nodata 0    \
            -m  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_count_yessea_ct.tif      -msknodata 255   -nodata 0 \
-co COMPRESS=LZW -co ZLEVEL=9 -i /nobackupp8/gamatull/dataproces/LST/MASK/indiaFull4cluster.tif -o   /nobackupp8/gamatull/dataproces/LST/MASK/indiaMYD43obs.tif
 

gdal_translate -projwin  65 35 100 5  -co COMPRESS=LZW -co ZLEVEL=9 /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_mask_daySUM_wgs84_allobs.tif    /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif

pkgetmask -min -1 -max 43 -data 1 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9   -i    /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif   -o   /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/india43MOD_LST3k_mask_daySUM_wgs84_allobs.tif

pksetmask   -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/india43MOD_LST3k_mask_daySUM_wgs84_allobs.tif -msknodata 0   -nodata 0    \
            -m  /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_LST3k_count_yessea_ct.tif      -msknodata 255   -nodata 0  \
-co COMPRESS=LZW -co ZLEVEL=9 -i /nobackupp8/gamatull/dataproces/LST/MASK/indiaFull4cluster.tif -o   /nobackupp8/gamatull/dataproces/LST/MASK/indiaMOD43obs.tif



echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249  | xargs -n 1 -P  23   bash -c $'

DAY=$1 


gdal_translate -projwin 65 35 100 5  -co COMPRESS=LZW -co ZLEVEL=9  /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/LST_MYD_akima_day${DAY}_allobs.tifcluster     /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day$DAY.tif
gdal_translate -projwin 65 35 100 5  -co COMPRESS=LZW -co ZLEVEL=9  /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/LST_MOD_akima_day${DAY}_allobs.tifcluster     /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day$DAY.tif

w=9
f=smooth
pkfilter -circ -dx $w -dy $w  -f $f  -co COMPRESS=LZW -co ZLEVEL=9  -i  /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day${DAY}.tif  -o     /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day${DAY}_$w$f.tif
pkfilter -circ -dx $w -dy $w  -f $f  -co COMPRESS=LZW -co ZLEVEL=9  -i  /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day${DAY}.tif  -o     /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day${DAY}_$w$f.tif

pksetmask -co COMPRESS=LZW -co ZLEVEL=9  -m /nobackupp8/gamatull/dataproces/LST/MASK/indiaMOD43obs.tif -msknodata 0   -nodata -1  -i   /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day${DAY}_$w$f.tif  -o   /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day${DAY}_$w${f}_msk.tif  

pksetmask -co COMPRESS=LZW -co ZLEVEL=9   -m /nobackupp8/gamatull/dataproces/LST/MASK/indiaMYD43obs.tif -msknodata 0   -nodata -1  -i   /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day${DAY}_$w$f.tif  -o   /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day${DAY}_$w${f}_msk.tif  

pkcomposite -srcnodata -1  -dstnodata  -1   -co COMPRESS=LZW -co ZLEVEL=9    -i /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/LST_MYD_akima_day${DAY}_allobs.tifcluster   -i  /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/indiaLST_MYD_akima_day${DAY}_$w${f}_msk.tif   -o  /nobackupp8/gamatull/dataproces/LST/MYD11A2_splinefill_merge/LST_MYD_akima_day${DAY}_allobs.tif   

pkcomposite -srcnodata -1  -dstnodata  -1   -co COMPRESS=LZW -co ZLEVEL=9    -i /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/LST_MOD_akima_day${DAY}_allobs.tifcluster   -i  /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/indiaLST_MOD_akima_day${DAY}_$w${f}_msk.tif   -o  /nobackupp8/gamatull/dataproces/LST/MOD11A2_splinefill_merge/LST_MOD_akima_day${DAY}_allobs.tif   

' _







 


