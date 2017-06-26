#  nohup bash  /u/gamatull/scripts/LST/spline/sc12_upload2GEE.sh  Day  &
#  nohup bash  /u/gamatull/scripts/LST/spline/sc12_upload2GEE.sh  Nig  &

#PBS -S /bin/bash
#PBS -q low
#PBS -l select=1:ncpus=24:model=has
#PBS -l walltime=n:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr
#PBS -N sc12_upload2GEE.sh

echo /u/gamatull/scripts/LST/spline/sc12_upload2GEE.sh
export INDIR=/nobackupp8/gamatull/dataproces/LST/MYOD11A2_celsiusmean

export DN=$1

seq 7 13  | xargs -n 1 -P 13 bash -c $' 

echo gsutil   gsutil   gsutil gsutil  gsutil   gsutil  max 

/home6/gamatull/gsutil/gsutil  rm gs://data.earthenv.org/LST/LST_MOYDmax_${DN}_spline_month$1.tif  
sleep 1000
/home6/gamatull/gsutil/gsutil  cp -r $INDIR/LST_MOYDmax_${DN}_spline_month$1.tif  gs://data.earthenv.org/LST/ 

echo earthengine   earthengine earthengine earthengine earthengine earthengine earthengine 

/u/gamatull/.local/bin/earthengine  rm --verbose users/giuseppeamatulli/LST_3/LST_MOYDmax_${DN}_spline_month$1

sleep 1000

/u/gamatull/.local/bin/earthengine  upload image  --nodata_value -9999  gs://data.earthenv.org/LST/LST_MOYDmax_${DN}_spline_month$1.tif --asset_id=users/giuseppeamatulli/LST_3/LST_MOYDmax_${DN}_spline_month$1

echo gsutil   gsutil   gsutil gsutil  gsutil   gsutil  max 

/home6/gamatull/gsutil/gsutil  rm gs://data.earthenv.org/LST/LST_MOYDmin_${DN}_spline_month$1.tif  
sleep 1000  
/home6/gamatull/gsutil/gsutil  cp -r $INDIR/LST_MOYDmin_${DN}_spline_month$1.tif  gs://data.earthenv.org/LST/

echo earthengine   earthengine earthengine earthengine earthengine earthengine earthengine min

/u/gamatull/.local/bin/earthengine  rm --verbose users/giuseppeamatulli/LST_3/LST_MOYDmin_${DN}_spline_month$1

sleep 1000

/u/gamatull/.local/bin/earthengine  upload image --nodata_value -9999 gs://data.earthenv.org/LST/LST_MOYDmin_${DN}_spline_month$1.tif --asset_id=users/giuseppeamatulli/LST_3/LST_MOYDmin_${DN}_spline_month$1 

' _ 

sleep 8000

seq 1 13  | xargs -n 1 -P 13 bash -c $' 

/u/gamatull/.local/bin/earthengine  acl set public users/giuseppeamatulli/LST_3/LST_MOYDmax_${DN}_spline_month$1
/u/gamatull/.local/bin/earthengine  acl set public users/giuseppeamatulli/LST_3/LST_MOYDmin_${DN}_spline_month$1 

' _ 
