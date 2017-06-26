# 1 8-day mean no considered QC
# check http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_8dcmg.html#qa
# and QC at http://www.icess.ucsb.edu/modis/LstUsrGuide/usrguide_1dcmg.html#Table_17

# for MMDD in $(cat  /nobackup/gamatull/dataproces/LST/geo_file/mm_dd_MOD11A2.txt ) ; do qsub -v MMDD=$MMDD /u/gamatull/scripts/LST/sc1_local_MOYD11A2.sh  ; done 

# infor at http://www.nas.nasa.gov/hecc/support/kb/ 

#  -q   normal, debug, long, and low.   devel 2hours 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=15
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

echo "MMDD $MMDD /u/gamatull/scripts/LST/sc1_wget_MYOD11A2_MRT.sh " >  /nobackup/gamatull/stdnode/job_start_$PBS_JOBID.txt
# checkjob -v $PBS_JOBID                                          >> /nobackup/gamatull/stdnode/job_start_$PBS_JOBID.txt

export MMDD=$1

# export MMDD=$MMDD

export MM=${MMDD:0:2}
export DD=${MMDD:2:3}

echo processing dir  ${MM}.${DD} 

export HDFMOD11A2=/nobackup/gamatull/dataproces/LST/MOD11A2_MRT
export HDFMYD11A2=/nobackup/gamatull/datapreces/LST/MYD11A2
export LST=/nobackup/gamatull/dataproces/LST
export INDIR=/nobackupp6/aguzman4/climateLayers/MOD11A2.005
export RAMDIR=/dev/shm
export MOD_MRT=/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2_MRT

rm -f /dev/shm/*.hdf   /dev/shm/*.tif  /dev/shm/.listing

echo 2011 2013 2014 2015   | xargs -n 1 -P 15  bash -c $' 

YEAR=$1 
SENS=MOD

echo processing ${YEAR}.${MM}.${DD} 

if [  -d  $INDIR/${YEAR}/001   ]  ; then 

ls $INDIR/${YEAR}/001/MOD11A2.A${YEAR}*.h??v??.005.*.hdf  > $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.txt 

mrtmosaic -i  $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.txt  -s "1" -o  $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_sin.hdf

gdal_translate  -co  COMPRESS=LZW -co ZLEVEL=9 $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_sin.hdf   $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_sin.tif


echo INPUT_FILENAME = "$MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_sin.hdf"   > $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo SPECTRAL_SUBSET = "( 1 )"  >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo SPATIAL_SUBSET_TYPE = INPUT_LAT_LONG >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo SPATIAL_SUBSET_UL_CORNER = "( +90 -180 )" >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 
echo SPATIAL_SUBSET_LR_CORNER = "( -90 +180 )" >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo OUTPUT_FILENAME = $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_wgs84.tif  >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo RESAMPLING_TYPE = NEAREST_NEIGHBOR >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo OUTPUT_PROJECTION_TYPE = GEO >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 
  
echo OUTPUT_PROJECTION_PARAMETERS = "(  
 0.0 0.0 0.0
 0.0 0.0 0.0
 0.0 0.0 0.0
 0.0 0.0 0.0
 0.0 0.0 0.0 )" >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo DATUM = NoDatum >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

echo OUTPUT_PIXEL_SIZE = 0.0083333333333 >> $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

resample -p $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_hdf.prm 

gdalwarp  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite  -co  COMPRESS=LZW -co ZLEVEL=9   $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_sin.tif    $MOD_MRT/$YEAR/${SENS}11A2.A${YEAR}${DD}_wgs84GDAL.tif 

fi 

' _ 

exit 

