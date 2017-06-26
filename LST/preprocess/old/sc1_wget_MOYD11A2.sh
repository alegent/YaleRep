# 1 8-day mean no considered QC
# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17

# for SENS in MYD MOD ;  do  for YEAR in $(cat  /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt) ; do qsub -v DAY=$DAY,SENS=$SENS  /u/gamatull/scripts/LST/sc1_wget_MOYD11A2.sh ; done ; done 

# for SENS in MOD ;  do  for DAY in $(cat   /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt) ; do bash  /u/gamatull/scripts/LST/sc1_wget_MOYD11A2.sh $DAY $SENS  ; done ; done 

# infor at http://www.nas.nasa.gov/hecc/support/kb/ 

#  -q   normal, debug, long, and low.   devel 2hours 

#PBS -S /bin/bash
#PBS -q devel
#PBS -l select=1:ncpus=15
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

echo "DAY $DAY /u/gamatull/scripts/LST/sc1_wget_MYOD11A2.sh " >  /nobackup/gamatull/stdnode/job_start_$PBS_JOBID.txt
# checkjob -v $PBS_JOBID                                          >> /nobackup/gamatull/stdnode/job_start_$PBS_JOBID.txt

export DAY=$1
export SENS=$2

echo processing dir  ${DAY}  ${SENS} 

export HDFMOD11A2=/nobackup/gamatull/dataproces/LST/MOD11A2
export HDFMYD11A2=/nobackup/gamatull/datapreces/LST/MYD11A2
export LST=/nobackup/gamatull/dataproces/LST
export INDIR=/nobackupp4/datapool/modis/MOD11A2.005
export RAMDIR=/dev/shm

rm -f /dev/shm/*.hdf   /dev/shm/*.tif  /dev/shm/.listing


# seq 2000 2014  | xargs -n 1 -P 1  bash -c $' 

for YEAR in $( seq 2000 2014 ) ; do  

export YEAR=$YEAR 
 
# sleep $sleep
if [  ! -f  $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.txt ] ; then 
line=0
else
line=$(wc -l $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.txt | awk '{ print $1  }' )
fi
echo $line 
if [ $line -lt 317 ]  ; then 

echo start the download of ftp://ladsweb.nascom.nasa.gov/allData/5/${SENS}11A2/${YEAR}/$DAY/hdf 

wget -w 5 --waitretry=4 --random-wait   --no-remove-listing   -o $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.log  -c   -N   -P   $RAMDIR   ftp://ladsweb.nascom.nasa.gov/allData/5/${SENS}11A2/${YEAR}/$DAY/*.hdf  

echo finish the download of ftp://ladsweb.nascom.nasa.gov/allData/5/${SENS}11A2/${YEAR}/$DAY/hdf

ls    $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*.hdf    >  $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.txt

if [ -s  $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}_hdf.txt  ] ; then 

ls  $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*.hdf |   xargs -n 1 -P 30  bash -c $' 

export file=$1

filename=$(basename $file .hdf)

gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:LST_Day_1km   $RAMDIR/${filename}_LST.tif &> /dev/null
gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:QC_Day        $RAMDIR/${filename}_QC.tif  &> /dev/null

rm -f $file
 ' _  

echo start to spatial merge $YEAR  $DAY 

gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST.vrt    $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_LST.tif  
gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt     $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_QC.tif  

echo merge the LST and QC

gdalbuildvrt   -overwrite -separate      $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC.vrt

gdal_translate  -ot  UInt16    -co COMPRESS=DEFLATE -co ZLEVEL=9   -co  PREDICTOR=2  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}.vrt  $LST/${SENS}11A2/$YEAR/${SENS}11A2.A${YEAR}${DAY}.tif

rm -f  $RAMDIR/*11A2.A*.??????.???.*.tif  $RAMDIR/*.vrt   $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*.hdf 

fi
fi 

done 

echo "MMDD $MMDD /u/gamatull/scripts/LST/sc1_wget_MYOD11A2.sh " >  /nobackup/gamatull/stdnode/job_end_$PBS_JOBID.txt
# checkjob -v $PBS_JOBID >>  /nobackup/gamatull/stdnode/job_end_$PBS_JOBID.txt

exit 

