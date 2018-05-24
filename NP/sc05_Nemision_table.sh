#!/bin/bash
#SBATCH -p day
#SBATCH -J sc05_Nemision_table.sh
#SBATCH -n 1 -c 6 -N 1  
#SBATCH -t 24:00:00  
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_Nemision_table.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_Nemision_table.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --mem-per-cpu=5000

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NP/sc05_Nemision_table.sh

export DIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP
export RAM=/dev/shm

# module load Libs/GDAL/2.2.4 

ls  $DIR/global_prediction/*.tif | xargs -n 1 -P 3 bash -c $'
file=$1 
gdal_translate  --config GDAL_NUM_THREADS 2  --config GDAL_CACHEMAX  5000  -of XYZ   $file  $DIR/global_prediction/$(basename $file .tif ).txt 

awk \' { if($3 != -1 ) print $3  }\' $DIR/global_prediction/$(basename $file .tif ).txt  > $DIR/global_prediction/$(basename $file .tif )_clean.txt 
rm $DIR/global_prediction/$(basename $file .tif ).txt 
' _   &

ls  $DIR/FLOK1/{FLO1K.ts.1960.2015.qav_mean.tif,FLO1K.ts.1960.2015.qma_max.tif,FLO1K.ts.1960.2015.qmi_min.tif} | xargs -n 1 -P 3 bash -c $'                                                                                                                                                                                
file=$1 
gdal_translate  --config GDAL_NUM_THREADS 2  --config GDAL_CACHEMAX  5000  -of XYZ   $file  $DIR/FLOK1/$(basename $file .tif ).txt
awk \'{ if($3 != -9999 ) print $3  }\' $DIR/FLOK1/$(basename $file .tif ).txt  > $DIR/FLOK1/$(basename $file .tif )_clean.txt 
rm  -f $DIR/FLOK1/$(basename $file .tif ).txt                                                                                           
' _

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/global_prediction/map_pred_NO3_mask.tif -msknodata -1 -nodata -9999 -i   $DIR/global_wsheds/tmean_wavg.tif -o $DIR/global_wsheds/tmean_wavg_stream.tif 
gdal_translate  --config GDAL_NUM_THREADS 2 --config GDAL_CACHEMAX 10000 -of XYZ $DIR/global_wsheds/tmean_wavg_stream.tif    $DIR/global_wsheds/tmean_wavg_stream.txt 
awk ' { if($3 != -9999 ) print $3  }' $DIR/global_wsheds/tmean_wavg_stream.txt    > $DIR/global_wsheds/tmean_wavg_stream_clean.txt 
rm -f   $DIR/global_wsheds/tmean_wavg.txt   

gdal_translate --config GDAL_CACHEMAX 10000    -co COMPRESS=DEFLATE -co ZLEVEL=9 -a_srs EPSG:4326 -projwin $(getCorners4Gtranslate $DIR/global_wsheds/global_grid_ID.tif ) /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/slope/mean/slope_1KMmean_MERIT.tif  $DIR/global_wsheds/slope_1KMmean_MERIT_crop.tif
pkgetmask  -ot Byte  -min -10000 -max -9998  -co COMPRESS=DEFLATE -co ZLEVEL=9    -data 0 -nodata 1    -i   $DIR/global_wsheds/slope_1KMmean_MERIT_crop.tif  -o    $RAM/msk_slope.tif 
pkfillnodata  -m      $RAM/msk_slope.tif    -d 50   -i  $DIR/global_wsheds/slope_1KMmean_MERIT_crop.tif -o $DIR/global_wsheds/slope_1KMmean_MERIT_crop_fill.tif
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/global_prediction/map_pred_NO3_mask.tif -msknodata -1 -nodata -9999 -i $DIR/global_wsheds/slope_1KMmean_MERIT_crop_fill.tif -o $DIR/global_wsheds/slope_1KMmean_MERIT_stream.tif
gdal_translate --config GDAL_NUM_THREADS 2 --config GDAL_CACHEMAX 10000 -of XYZ $DIR/global_wsheds/slope_1KMmean_MERIT_stream.tif $DIR/global_wsheds/slope_1KMmean_MERIT_stream.txt 
awk ' { if($3 != -9999 ) print $3  }'  $DIR/global_wsheds/slope_1KMmean_MERIT_stream.txt > $DIR/global_wsheds/slope_1KMmean_MERIT_stream_clean.txt 
rm -f $DIR/global_wsheds/slope_1KMmean_MERIT_stream.txt 

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/global_prediction/map_pred_NO3_mask.tif -msknodata -1 -nodata -9999 -i $DIR/global_wsheds/global_grid_ID.tif -o  $DIR/global_wsheds/global_grid_ID_mskNO3.tif
gdal_translate --config GDAL_NUM_THREADS 2 --config GDAL_CACHEMAX 10000 -of XYZ  $DIR/global_wsheds/global_grid_ID_mskNO3.tif $DIR/global_wsheds/global_grid_ID_mskNO3.txt
awk ' { if($3 != -9999 ) print $3  }'  $DIR/global_wsheds/global_grid_ID_mskNO3.txt  > $DIR/global_wsheds/global_grid_ID_mskNO3_clean.txt
rm -f $DIR/global_wsheds/global_grid_ID.txt 

echo "FID,Cell_ID,Qmax,Qmean,Qmin,S,NH4,NO3,TN,Tp" > $DIR/emision_table.txt

paste <( seq 1 19892976) $DIR/global_wsheds/global_grid_ID_mskNO3_clean.txt  \
$DIR/FLOK1/FLO1K.ts.1960.2015.qma_max_clean.txt $DIR/FLOK1/FLO1K.ts.1960.2015.qav_mean_clean.txt $DIR/FLOK1/FLO1K.ts.1960.2015.qmi_min_clean.txt \
$DIR/global_wsheds/slope_1KMmean_MERIT_stream_clean.txt  \
$DIR/global_prediction/map_pred_DNH4_mask_clean.txt $DIR/global_prediction/map_pred_NO3_mask_clean.txt $DIR/global_prediction/map_pred_TN_mask_clean.txt \
 <(awk ' {print $1/10 }'  $DIR/global_wsheds/tmean_wavg_stream_clean.txt)   >> $DIR/emision_table.txt

#    | awk '{ if ($3 == -1 ) print  }' 
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_wsheds/global_grid_ID_mskNO3_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/FLOK1/FLO1K.ts.1960.2015.qma_max_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/FLOK1/FLO1K.ts.1960.2015.qav_mean_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/FLOK1/FLO1K.ts.1960.2015.qmi_min_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_wsheds/slope_1KMmean_MERIT_stream_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_prediction/map_pred_DNH4_mask_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_prediction/map_pred_NO3_mask_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_prediction/map_pred_TN_mask_clean.txt
#   19892976 /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP/global_wsheds/tmean_wavg_stream_clean.txt

#  wc -l 19892976 global_grid_ID_mskNO3_hist.tx # do not count the -9999 
#  wc -l 19892960 emision_table.txt 

# exclude 2 lines that have discarge -1 
awk '{ if ($3 != -1 ) print  }' $DIR/emision_table.txt >  $DIR/emision_table_valid.txt
awk '{ if ($3 == -1 ) print  }' $DIR/emision_table.txt >  $DIR/emision_table_notvalid.txt

cd $DIR 
GZIP=-9 
tar -czvf emision_table_valid.tar.gz emision_table_valid.txt 

exit 
