# create the list block 
# /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_list/tif_out_list.txt 

# for n in $(seq 1 21) ; do  
#    hn=$(expr $n \* 10000 )  ;  
#    head -$hn  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_list/tif_out_fulllist.txt   | tail -10000 >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_list/tif_out_list$n.txt   
# done

# tail -137  tif_out_fulllist.txt > tif_out_list22.txt

#  prepare the tar file 

# ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_list/tif_out_list*.txt | xargs  -n 1   -P 8 bash -c $' 
# filelist=$1
# filename=$(basename $filelist .txt )
# tar -cf   /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out.tars/$filename.tar    $(for file in $(cat $filelist) ; do echo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out/$file ; done)
# ' _ 

# for filetar in /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out.tars/tif_out_list*.tar  ; do qsub -v filetar=$filetar /home/fas/sbsc/ga254/scripts/WDPA/sc10_create_table4overlaping.sh ; done 

# bash  /home/fas/sbsc/ga254/scripts/WDPA/sc10_create_table4overlaping.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out.tars/tif_out_list2.tar 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=2:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

filetar=$filetar

echo processing $filetar 

filename=$(basename $filetar)
export RAM=/dev/shm
   
rm $RAM/*.csv  $RAM/*.tif $RAM/*.tx $RAM/*.asc

cp $filetar  /dev/shm/
cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID_rast_super_compres.tif  /dev/shm/ 


cd  /dev/shm/

tar -xf  $filetar  --strip 9


ls /dev/shm/wdpa2014_id*.tif  | xargs -n 1 -P 8 bash -c  $'  

filetif=$1
filetifname=$( basename $filetif .tif  )
polyID=${filetifname:11:20}

echo processing $RAM/glob_ID_$filetifname.asc 

gdal_translate -projwin   $(getCorners4Gtranslate  $filetif)  $RAM/glob_ID_rast_super_compres.tif  $RAM/glob_ID_crop_$filetifname.tif &> /dev/null
pksetmask   -msknodata 0 -nodata 0  -m  $filetif   -i  $RAM/glob_ID_crop_$filetifname.tif -o  $RAM/glob_ID_$filetifname.tif   &> /dev/null  

gdal_translate -of  AAIGrid   $RAM/glob_ID_$filetifname.tif   $RAM/tmp_glob_ID_$filetifname.asc                                    &> /dev/null 

awk   -v polyID=$polyID  \'{  if (NR>6) { for (col=1 ; col<=NF ; col ++) { if ($col!=0) printf("%i,"polyID"\\n", $col ) } }}\'   $RAM/tmp_glob_ID_$filetifname.asc >   $RAM/glob_ID_$filetifname.csv

rm -f $RAM/tmp_glob_ID_$filetifname.asc    $RAM/tmp_glob_ID_$filetifname.asc.aux.xml   $RAM/glob_ID_$filetifname.tif  $RAM/glob_ID_crop_$filetifname.tif $filetif 

' _ 


echo start the tar 

cat  $RAM/glob_ID_wdpa2014_id*.csv   >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/csv_out/$filename.csv

tar -cf   /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/txt_out.tars/$filename.tar   $RAM/glob_ID_wdpa2014_id*.csv 

rm  $RAM/glob_ID_wdpa2014_id*.csv   $RAM/$filetar $RAM/glob_ID_rast_super_compres.tif 

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt