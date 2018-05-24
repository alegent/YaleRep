#!/bin/bash
#SBATCH -p day
#SBATCH -J sc06_prediction_Nemision.sh
#SBATCH -n 1 -c 10  -N 1  
#SBATCH -t 24:00:00  
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc06_prediction_Nemision.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc06_prediction_Nemision.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --mem-per-cpu=2000

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NP/sc06_prediction_Nemision.sh


export DIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NP

awk '{ if (NR>2) print NR, $1 }' $DIR/gfortran_code/header.txt   | xargs -n 2 -P 10 bash -c $'  

n=$1
H=$2
awk -v n=$n  \'{ printf ("%i  %.12f\\n" , $2 ,  $n) }\'       $DIR/gfortran_code/Output_N2O_emission.dat   >   $DIR/prediction/Output_N2O_emission_$H.dat  
awk          \'{ print $2 , "-1" }\'                          $DIR/gfortran_code/Inconsistent_PR.dat      >>   $DIR/prediction/Output_N2O_emission_$H.dat  
#  
pkreclass -m $DIR/global_prediction/map_pred_TN_mask.tif -msknodata -1 -nodata -9999 --code $DIR/prediction/Output_N2O_emission_$H.dat -ot  Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -i $DIR/global_wsheds/global_grid_ID_mskNO3.tif -o $DIR/prediction/prediction_$H.tif 
gdal_edit.py -a_nodata -9999  $DIR/prediction/prediction_$H.tif  
pkstat -mm  -nodata -1   -nodata -9999 -i   $DIR/prediction/prediction_$H.tif  > $DIR/prediction/prediction_${H}_min_max.txt  

# includes the -9999 and -1 in the mask to be interpolated  
pkgetmask  -ot Byte  -min -10000  -max -0.5  -co COMPRESS=DEFLATE -co ZLEVEL=9    -data 0 -nodata 1  -i   $DIR/prediction/prediction_$H.tif   -o  $DIR/prediction/prediction_${H}_-1.tif  
pkfillnodata  -m    $DIR/prediction/prediction_${H}_-1.tif  -d 10  -it 3    -i   $DIR/prediction/prediction_$H.tif  -o   $DIR/prediction/prediction_${H}_fill_tmp.tif 

# re-mask the final results 
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -m $DIR/global_prediction/map_pred_NO3_mask.tif -msknodata -1 -nodata -9999 -i  $DIR/prediction/prediction_${H}_fill_tmp.tif  -o  $DIR/prediction/prediction_${H}_fill.tif 

pkstat -mm    -nodata -9999 -i $DIR/prediction/prediction_${H}_fill.tif  > $DIR/prediction/prediction_${H}_fill_min_max.tif 
' _ 




