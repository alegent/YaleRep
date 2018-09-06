#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 8:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_dem_variables_float_noMult_equi7_4HyperScaleRoughness.sh.%A_%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_dem_variables_float_noMult_equi7_4HyperScaleRoughness.sh.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc05_dem_variables_float_noMult_equi7_4HyperScaleRoughness.sh
#SBATCH --array=1-853

# 853    number of files 
# bash    /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc05_dem_variables_float_noMult_equi7_4HyperScaleRoughness.sh
# sbatch  /gpfs/home/fas/sbsc/ga254/scripts/MERIT/sc05_dem_variables_float_noMult_equi7_4HyperScaleRoughness.sh


module load Apps/GRASS/7.3-beta

# file=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/EU/EU_048_000.tif

file=$(ls /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/??/??_???_???.tif | head -n $SLURM_ARRAY_TASK_ID | tail -1 )
# use this if one file is missing

MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT
SCRATCH=/gpfs/loomis/scratch60/fas/sbsc/ga254/grace0/dataproces/MERIT
RAM=/dev/shm
filename=$(basename $file .tif )
CT=${filename:0:2}
echo filename  $filename
echo file $filename.tif  SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID 

ulx=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]"," ") ; printf ("%i" ,  $3  - (1010 * 100 )) }')
uly=$(gdalinfo $file | grep "Upper Left"  | awk '{ gsub ("[(),]"," ") ; printf ("%i" ,  $4  + (1010 * 100 )) }')
lrx=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]"," ") ; printf ("%i" ,  $3  + (1010 * 100 )) }')
lry=$(gdalinfo $file | grep "Lower Right" | awk '{ gsub ("[(),]"," ") ; printf ("%i" ,  $4  - (1010 * 100 )) }')

echo $ulx $uly $lrx $lry
gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -projwin  $ulx $uly $lrx $lry  $MERIT/equi7/dem/${CT}/all_${CT}_tif.vrt  $RAM/$filename.tif 
pksetmask   -m $RAM/$filename.tif   -msknodata -9999 -nodata 0 -i $RAM/$filename.tif -o $RAM/${filename}_0.tif
gdal_edit.py  -a_nodata 0  $RAM/${filename}_0.tif 

# ./whitebox_tools   --toolhelp="MultiscaleRoughness" 
# ./whitebox_tools   --toolhelp="MaxElevationDeviation" 

singularity exec UbuntuWB.simg  bash <<EOF
/WBT/whitebox_tools   -r=MultiscaleRoughness    -v --wd="$RAM"  --dem=${filename}_0.tif --out_mag=${filename}_roug_mag.tif  --out_scale=${filename}_roug_sca.tif --min_scale=1 --max_scale=10 --step=3
EOF

for PAR in mag sca ; do 
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -m $RAM/$filename.tif -nodata -9999 -msknodata -9999 -i  $RAM/${filename}_roug_$PAR.tif -o  $RAM/${filename}_roug_${PAR}_msk.tif 
rm -f  $RAM/${filename}_roug_${PAR}.tif    
gdal_translate   -projwin $( getCorners4Gtranslate $file  )     -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_roug_${PAR}_msk.tif  $SCRATCH/multirough/tiles/${filename}_roug_${PAR}.tif 
rm -f  $RAM/${filename}_roug_${PAR}_msk.tif 
done 

singularity exec UbuntuWB.simg  bash <<EOF
/WBT/whitebox_tools -r=MaxElevationDeviation  -v --wd="$RAM"  --dem=${filename}_0.tif --out_mag=${filename}_devi_mag.tif   --out_scale=${filename}_devi_sca.tif  --min_scale=1 --max_scale=10 --step=3
EOF

for PAR in mag sca ; do 
pksetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND  -m $RAM/$filename.tif -nodata -9999 -msknodata -9999 -i  $RAM/${filename}_devi_$PAR.tif -o  $RAM/${filename}_devi_${PAR}_msk.tif 
rm -f  $RAM/${filename}_devi_${PAR}.tif    
gdal_translate   -projwin $( getCorners4Gtranslate $file  )     -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/${filename}_devi_${PAR}_msk.tif  $SCRATCH/deviation/tiles/${filename}_devi_${PAR}.tif 
rm -f  $RAM/${filename}_devi_${PAR}_msk.tif 
done 




