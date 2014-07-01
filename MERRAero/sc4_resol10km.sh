# for DAYc in $(  awk '{ print $3  }'  /scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt   ) ; do qsub -v  DAYc=$DAYc  /home/fas/sbsc/ga254/scripts/MERRAero/sc4_resol10km.sh   ; done  

# bash /home/fas/sbsc/ga254/scripts/MERRAero/sc4_resol10km.sh   030


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

echo working 


DIRTIF_W15=/scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_mean_w15_day365
DIRTIF_RES=/scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_mean_w15_day365_res10km

DAYc=$1


gdal_calc.py  --overwrite  --type=Float64    -A  $DIRTIF_W15/mean${DAYc}.tif   --calc="( A * 1000  )"    --outfile=$DIRTIF_W15/mean${DAYc}_k.tif

echo starting the warping for   $DIRTIF_RES/mean${DAYc}.tif  

gdalwarp -r  cubicspline    -te  -180 -90 +180 +90   -tr  0.083333333333330 0.083333333333330  -co COMPRESS=LZW -co ZLEVEL=9    $DIRTIF_W15/mean${DAYc}_k.tif   $DIRTIF_RES/mean${DAYc}_float.tif
gdal_translate  -ot Int16  -co COMPRESS=LZW -co ZLEVEL=9   $DIRTIF_RES/mean${DAYc}_float.tif   $DIRTIF_RES/mean${DAYc}.tif  

rm -f  $DIRTIF_RES/mean${DAYc}_float.tif









