# small file have tif value = 0 , so scripting procedure to recode the tif value

# for filetar in /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out.tars/tif_out_list*.tar  ; do qsub -v filetar=$filetar  /home/fas/sbsc/ga254/scripts/WDPA/sc2_correction_4smalltif.sh  ; done

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

filetar=$filetar 

echo processing $filetar 

filename=$(basename $filetar)
export RAM=/dev/shm
   
rm $RAM/*.csv  $RAM/*.tif $RAM/*.txt $RAM/*.asc

cp $filetar  /dev/shm/

cd  /dev/shm/

tar -xf  $filetar  --strip 9


ls /dev/shm/wdpa2014_id*.tif   | xargs -n 1 -P 8 bash -c  $'  

filetif=$1
filetifname=$( basename $filetif .tif  )
polyID=${filetifname:11:20}



sizeX=$(  gdalinfo $filetif  | grep "Size is" | awk \'{ gsub (","," ") ; print $3 }\')
sizeY=$(  gdalinfo $filetif  | grep "Size is" | awk \'{ gsub (","," ") ; print $4 }\')

if [ ${sizeX} -eq 1 ]  || [ ${sizeX} -eq 1 ] ; then 

    gdal_edit.py -a_nodata -1  wdpa2014_id$polyID.tif

    max=$(pkinfo -mm -i   wdpa2014_id$polyID.tif | awk \'{  print $4 }\')

    if [ $max -eq 0 ] ; then 

	gdal_calc.py  -A wdpa2014_id$polyID.tif --calc="( A + $polyID  )" --outfile=cp_wdpa2014_id$polyID.tif
        gdal_edit.py -a_nodata 0  cp_wdpa2014_id$polyID.tif
        mv cp_wdpa2014_id$polyID.tif   /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_correct/wdpa2014_id$polyID.tif
    fi 

fi  

' _ 

rm *.tif *.tar 

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt