
# to prepare the dataset for testing 
# qsub     /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc7_month_mean.sh

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00  # 1 hour for the full cicle 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export INDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth_1km
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/temp_smoth_1km_month_mean


echo  09 10 11 12 | xargs -n 1 -P 8 bash -c $'

MM=$1

pkcomposite   -co  COMPRESS=LZW -co ZLEVEL=9  -srcnodata -1 --dstnodata -1 -ot Int16  -min 0 -max 5000  -cr mean  $(for day  in  $(grep ^$MM  /scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt | awk \'{  print $2  }\') ; do echo -i  $INDIR/AOD_1km_day${day}.tif ; done ) -o $OUTDIR/AODmeanMM${MM}.tif  


' _ 

