
# 1 8-day mean no considered QC
# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17

# for DAY  in $(cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/geo_file/list_day.txt ) ; do qsub -v DAY=$DAY /home/fas/sbsc/ga254/scripts/LST/sc1_wget_MYOD11A2.sh ; done 

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout/
#PBS -e /scratch/fas/sbsc/ga254/stderr/


checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt


# export DAY=$1

export DAY=$DAY

export HDFMOD11A2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MOD11A2
export HDFMYD11A2=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/MYD11A2
export LST=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST
export RAMDIR=/dev/shm

rm -f /dev/shm/*.hdf   /dev/shm/*.tif  /dev/shm/.listing

seq 2000 2014  | xargs -n 1 -P 8  bash -c $' 

YEAR=$1

if [ $YEAR -eq  2000  ] ; then sleep=0 ; fi
if [ $YEAR -eq  2001  ] ; then sleep=600 ; fi
if [ $YEAR -eq  2002  ] ; then sleep=1200 ; fi
if [ $YEAR -eq  2003  ] ; then sleep=1800 ; fi
if [ $YEAR -eq  2004  ] ; then sleep=2400 ; fi
if [ $YEAR -eq  2005  ] ; then sleep=3000 ; fi
if [ $YEAR -eq  2006  ] ; then sleep=3600 ; fi
if [ $YEAR -eq  2007  ] ; then sleep=4200 ; fi
if [ $YEAR -eq  2008  ] ; then sleep=4800 ; fi
if [ $YEAR -eq  2009  ] ; then sleep=5400 ; fi
if [ $YEAR -eq  2010  ] ; then sleep=6000 ; fi
if [ $YEAR -eq  2011  ] ; then sleep=6600 ; fi
if [ $YEAR -eq  2012  ] ; then sleep=7200 ; fi
if [ $YEAR -eq  2013  ] ; then sleep=7800 ; fi
if [ $YEAR -eq  2014  ] ; then sleep=8400 ; fi
 
sleep $sleep

for SENS in MOD  MYD ; do

wget -w 5 --waitretry=4 --random-wait   --no-remove-listing   -o $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.log     -N   -P   $RAMDIR   ftp://ladsweb.nascom.nasa.gov/allData/5/${SENS}11A2/${YEAR}/$DAY/*.hdf

ls    $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*.hdf    >  $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.txt

for file in   $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*.hdf   ; do  

filename=$(basename $file .hdf)

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:LST_Day_1km   $RAMDIR/$filename.tif 
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:QC_Day        $RAMDIR/${filename}_QC.tif 

rm -f $file

done 

echo start to spatial merge $YEAR  $DAY 

gdalbuildvrt   -overwrite    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.??????.???.?????????????.tif  
gdal_translate     $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt    -co COMPRESS=DEFLATE -co ZLEVEL=9   -co  PREDICTOR=2            $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}.tif

rm -f  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.??????.???.?????????????.tif

gdalbuildvrt   -overwrite    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.??????.???.?????????????_QC.tif 
gdal_translate     $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt   -co COMPRESS=DEFLATE -co ZLEVEL=9   -co  PREDICTOR=2      $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_QC.tif 

rm -f  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.??????.???.?????????????_QC.tif 


done

' _ 

checkjob -v $PBS_JOBID > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt

exit 
