#!/bin/bash
#SBATCH -p day
#SBATCH -J sc03_Nemision_flok1crop.sh
#SBATCH -n 1 -c 3 -N 1  
#SBATCH -t 24:00:00  
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_Nemision_flok1crop.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_Nemision_flok1crop.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --mem-per-cpu=20000

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NP/sc03_Nemision_flok1crop.sh

export  INDIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/FLOK1
export  OUTDIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP
export  RAM=/dev/shm

rm -rf $RAM/*.tif  $INDIR/grassdb/loc_${filename}



echo FLO1K.ts.1960.2015.qma_max.tif FLO1K.ts.1960.2015.qmi_min.tif FLO1K.ts.1960.2015.qav_mean.tif | xargs -P 3 -n 1 bash -c $' 

file=$1 
filename=$(basename $file .tif)

gdal_translate --config GDAL_CACHEMAX 5000    -co COMPRESS=DEFLATE -co ZLEVEL=9 -a_srs EPSG:4326 -projwin $(getCorners4Gtranslate $OUTDIR/global_wsheds/global_grid_ID.tif ) $INDIR/$file  $RAM/crop_$file 
pkgetmask  -ot Byte  -min -2 -max -0.5  -co COMPRESS=DEFLATE -co ZLEVEL=9    -data 0 -nodata 1  -i   $RAM/crop_$file   -o   $RAM/msk_$file  
pkfillnodata  -m   $RAM/msk_$file  -d 100 -it 10   -i $RAM/crop_$file -o $OUTDIR/FLOK1/${filename}_fill.tif 

rm -f $RAM/crop_$file $RAM/msk_$file   

pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $OUTDIR/global_prediction/map_pred_NO3_mask.tif   -msknodata -1   -nodata -9999 -i $OUTDIR/FLOK1/${filename}_fill.tif -o $OUTDIR/FLOK1/$file 


' _ 

sbatch /gpfs/home/fas/sbsc/ga254/scripts/NP/sc05_Nemision_table.sh 

exit 

