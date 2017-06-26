
# for SENS in MYD MOD ; do  qsub -v SENS=$SENS  /u/gamatull/scripts/LST/sc3_pixelcount_MOYD11A2.sh   ; done

#PBS -S /bin/bash
#PBS -q long
#PBS -l select=1:ncpus=1
#PBS -l walltime=18:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo /u/gamatull/scripts/LST/sc3_pixelcount_MOYD11A2.sh

export  SENS=$SENS

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/txt

export RAMDIR=/dev/shm


cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt   | xargs -n 1 -P 15  bash -c $' 
day=$1
LST=LST_${SENS}_day${day}_wgs84.tif
LST_QC=LST_${SENS}_QC_day${day}_wgs84.tif

echo count pixel $SENS $day 

gdal_edit.py  -a_nodata -1   $INSENS/LST_${SENS}_day${day}.tif
gdal_edit.py  -a_nodata -1   $INSENS/LST_${SENS}_QC_day${day}.tif

echo $(pkinfo  -src_min  -1 -src_max  0  -hist -i $INSENS/LST_${SENS}_day${day}.tif  | awk \'{ if (NR==1) print $2  }\' )  $(pkinfo  -src_min  -1 -src_max  0  -hist -i $INSENS/LST_${SENS}_QC_day${day}.tif  | awk \'{ if (NR==1) print $2  }\' )  >  $OUTSENS/nodata_LST_LST_QC_day${day}.txt

' _ 


paste <(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt )  <(cat /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean/txt/nodata_LST_LST_QC_day???.txt ) > $OUTSENS/nodata_LST_LST_QC.txt
