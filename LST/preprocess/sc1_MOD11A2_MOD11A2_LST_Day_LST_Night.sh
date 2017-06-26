# 1 8-day mean no considered QC
# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17

# for  DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt) ; do qsub -v DAY=$DAY,YEAR=$YEAR /u/gamatull/scripts/LST/preprocess/sc1_MOD11A2_MOD11A2_LST_Day_LST_Night.sh ; done
# bash  /u/gamatull/scripts/LST/preprocess/sc1_MOD11A2_MOD11A2_LST_Day_LST_Night.sh  2005 001 

# infor at http://www.nas.nasa.gov/hecc/support/kb/ 

#  -q   normal, debug, long, and low.   devel 2hours 


# Queue   NCPUs/      Time/
# name      max/def    max/def    pr
# ======= =====/=== ======/====== ===
# low        --/  8  04:00/ 00:30 -10
# normal     --/  8  08:00/ 01:00   0
# long       --/  8 120:00/ 01:00   0
# debug      --/  8  02:00/ 00:30  15
# devel      --/  1  02:00/    -- 149

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=15
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr



echo "DAY  $DAY /u/gamatull/scripts/LST/sc1_wget_MYOD11A2.sh " >  /nobackup/gamatull/stdnode/job_start${YAR}${DAY}_$PBS_JOBID.txt
# checkjob -v $PBS_JOBID                                      >> /nobackup/gamatull/stdnode/job_start${YAR}${DAY}_$PBS_JOBID.txt


echo processing dir  ${DAY} 

export RAMDIR=/dev/shm
rm -f /dev/shm/*.hdf   /dev/shm/*.tif  

export DAY=$DAY

for YEAR in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 ; do 
export YEAR=$YEAR
for SENS in MOD MYD ; do  

export INDIR=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/
export OUTDIR=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/${SENS}11A2

echo processing ${SENS} ${YEAR} ${DAY} 

if [  -d  $INDIR/${YEAR}/${DAY}   ]  ; then

ls $INDIR/${YEAR}/${DAY}/${SENS}11A2.A${YEAR}???.??????.???.*.hdf  | xargs -n 1 -P 30   bash -c $'       

file=$1

filename=$(basename $file .hdf)

gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:LST_Day_1km    $RAMDIR/${filename}_LST_Day.tif  &> /dev/null
gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:QC_Day         $RAMDIR/${filename}_QC_Day.tif   &> /dev/null

gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:LST_Night_1km   $RAMDIR/${filename}_LST_Nig.tif &> /dev/null
gdal_translate -ot  UInt16  -co COMPRESS=LZW -co ZLEVEL=9     HDF4_EOS:EOS_GRID:"$file":MODIS_Grid_8Day_1km_LST:QC_Night        $RAMDIR/${filename}_QC_Nig.tif  &> /dev/null

' _ 

echo start to spatial merge $YEAR  $DAY 

gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST_Day.vrt    $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_LST_Day.tif  
gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC_Day.vrt     $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_QC_Day.tif  

gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST_Nig.vrt    $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_LST_Nig.tif  
gdalbuildvrt   -overwrite  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC_Nig.vrt     $RAMDIR/${SENS}11A2.A$YEAR${DAY}.??????.???.*_QC_Nig.tif  

echo merge the LST and QC

gdalbuildvrt   -overwrite -separate      $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_Day.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST_Day.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC_Day.vrt
gdalbuildvrt   -overwrite -separate      $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_Nig.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_LST_Nig.vrt    $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_QC_Nig.vrt

gdal_translate  -ot  UInt16    -co COMPRESS=DEFLATE -co ZLEVEL=9   -co INTERLEAVE=BAND  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_Day.vrt  $OUTDIR/$YEAR/${SENS}11A2.A${YEAR}${DAY}_Day.tif
gdal_translate  -ot  UInt16    -co COMPRESS=DEFLATE -co ZLEVEL=9   -co INTERLEAVE=BAND  $RAMDIR/${SENS}11A2.A${YEAR}${DAY}_Nig.vrt  $OUTDIR/$YEAR/${SENS}11A2.A${YEAR}${DAY}_Nig.tif

# rm -f $RAMDIR/${filename}_LST_Day.tif $RAMDIR/${filename}_QC_Day.tif   $RAMDIR/${filename}_LST_Night.tif  $RAMDIR/${filename}_QC_Night.tif   

fi
rm -f   /dev/shm/*.tif    /dev/shm/*.vrt
done 
done
rm -f   /dev/shm/*.tif    /dev/shm/*.vrt
checkjob -v $PBS_JOBID >>  /nobackup/gamatull/stdnode/job_start${YAR}${DAY}_$PBS_JOBID.txt

exit 
