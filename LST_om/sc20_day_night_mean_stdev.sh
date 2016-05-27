# qsub /lustre/home/client/fas/sbsc/ga254/scripts/LST/sc20_day_night_mean_stdev.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=10:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export NIG=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/NIG
export DAY=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/DAY


echo $DAY max mean Day $DAY max stdev Day $NIG min mean Nig $NIG  min stdev Nig  | xargs -n 4 -P 4 bash -c $' 

DIR=$1
var=$2
oper=$3
day=$4

pkcomposite  -cr  $oper  -srcnodata -9999 -dstnodata -9999 -ot Float32  -co COMPRESS=DEFLATE -co ZLEVEL=9   $( for month in $(seq 1 12 ) ; do echo -i $DIR/LST_MOYD${var}_${day}_spline_month$month.tif    ; done  ) -o $DIR/LST_MOYD${var}_${day}_spline_month_$oper.tif


' _ 

