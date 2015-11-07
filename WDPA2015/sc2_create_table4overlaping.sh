# create the relative idgrid list for each polygons
# /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_list/tif_out_list.txt 



# for filetar in /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tifs_out.tar/*.tar   ; do qsub -v filetar=$filetar /home/fas/sbsc/ga254/scripts/WDPA2015/sc2_create_table4overlaping.sh ; done 

# bash  /home/fas/sbsc/ga254/scripts/WDPA2015/sc10_create_table4overlaping.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tif_out.tars/tif_out_list2.tar 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=10:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

# filetar=$1

echo processing $filetar 

filename=$(basename $filetar)
export RAM=/dev/shm
   
rm -rf $RAM/*.txt  $RAM/glob_ID*.tif $RAM/*.txt $RAM/*.asc  

cp $filetar  /dev/shm/
cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID_rast_super_compres.tif  /dev/shm/ 

cd  /dev/shm/

tar -xf  $filetar  


ls /dev/shm/wdpa2014_id*.tif   | xargs -n 1 -P 8 bash -c  $'  

filetif=$1
filetifname=$( basename $filetif .tif  )
polyID=${filetifname:11:20}

echo processing $RAM/glob_ID_$filetifname.asc 

gdal_translate -projwin   $(getCorners4Gtranslate  $filetif)  $RAM/glob_ID_rast_super_compres.tif  $RAM/glob_ID_crop_$filetifname.tif &> /dev/null
pksetmask   -msknodata 0 -nodata 0  -m  $filetif   -i  $RAM/glob_ID_crop_$filetifname.tif -o  $RAM/glob_ID_$filetifname.tif   &> /dev/null  

gdal_translate -of  AAIGrid   $RAM/glob_ID_$filetifname.tif   $RAM/tmp_glob_ID_$filetifname.asc                                    &> /dev/null 

awk   -v polyID=$polyID  \'{  if (NR>6) { for (col=1 ; col<=NF ; col ++) { if ($col!=0) printf("%i "polyID"\\n", $col ) } }}\'   $RAM/tmp_glob_ID_$filetifname.asc >   $RAM/glob_ID_$filetifname.txt

rm -f $RAM/tmp_glob_ID_$filetifname.asc    $RAM/tmp_glob_ID_$filetifname.asc.aux.xml   $RAM/glob_ID_$filetifname.tif  $RAM/glob_ID_crop_$filetifname.tif $filetif 

' _ 


echo start the tar 

cat  $RAM/glob_ID_wdpa2014_id*.txt   >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/txt_out/$filename.txt

tar -cf   /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/txt_out.tars/$filename.tar   $RAM/glob_ID_wdpa2014_id*.txt 

rm  $RAM/glob_ID_wdpa2014_id*.txt   $RAM/$filename   $RAM/glob_ID_rast_super_compres.tif   $RAM/*.tif

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt