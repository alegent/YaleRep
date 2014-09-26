# mosaic the tile and create a stak layer 
# needs to be impruved with the data type; now keep as floting. 
# reflect in caso di slope=0 reflectance 0 quindi non calcolata 
# for DIR in  beam   ; do bash  /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc2_merge_Monthradiation_bj.sh   $DIR ; done 
# for DIR in  beam  diff     ; do  qsub -v DIR=$DIR /home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_r_sun_om/sc2_merge_Monthradiation_bj.sh  ; done

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout  
#PBS -e /scratch/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

export DIR=$DIR

export INDIRD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad_day_tiles
export OUTDIRD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad_day_merge

export INDIRM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad_month_tiles
export OUTDIRM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/${DIR}_Hrad_month_merge

for INPUT in CA  ; do  

export INPUT=$INPUT

seq 1 365 | xargs -n 1  -P 8  bash  -c $'
echo processing day  $day for $INPUT
day=$1
gdalbuildvrt   -te -180  -56  180 84    $OUTDIRD/${DIR}_Hrad${INPUT}_day$day.vrt   $INDIRD/$day/${DIR}_Hrad${INPUT}_day${day}_month??_h??v??.tif   -overwrite 
gdal_translate  -projwin -180 84 180 -56   -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTDIRD/${DIR}_Hrad${INPUT}_day$day.vrt     $OUTDIRD/${DIR}_Hrad${INPUT}_day$day.tif
rm $OUTDIRD/${DIR}_Hrad${INPUT}_day$day.vrt
' _ 


echo  01 02 03 04 05 06 07 08 09 10 11 12 | xargs -n 1  -P  8  bash -c $' 
month=$1
gdalbuildvrt   -te -180  -56  180 84   $OUTDIRM/${DIR}_Hrad${INPUT}_month$month.vrt   $INDIRM/$month/${DIR}_Hrad${INPUT}_month${month}_h??v??.tif   -overwrite 
gdal_translate   -projwin -180 84 180 -56  -ot  Int16  -co  COMPRESS=LZW -co ZLEVEL=9   $OUTDIRM/${DIR}_Hrad${INPUT}_month$month.vrt    $OUTDIRM/${DIR}_Hrad${INPUT}_month$month.tif
rm $OUTDIRM/${DIR}_Hrad${INPUT}_month$month.vrt
' _ 

done

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt