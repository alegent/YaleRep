
# for MMDD in $(  awk '{ print $1  }'  /lustre0/scratch/ga254/dem_bj/MERRAero/tif_day/MMDD_JD.txt ) ; do qsub -v  MMDD=$MMDD  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc2_yearmean.sh    ; done  

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc2_yearmean.sh  0503  



#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=00:15:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

echo working 

DIRTIF_DAY=/lustre0/scratch/ga254/dem_bj/MERRAero/tif_day
DIRTIF_DAY365=/lustre0/scratch/ga254/dem_bj/MERRAero/tif_day365

# MMDD=$1
MONTH=${MMDD:0:2}
DAY=${MMDD:2:2}

JD=$( grep $MMDD  /lustre0/scratch/ga254/dem_bj/MERRAero/tif_day/MMDD_JD.txt  | awk '{ print $2 }'  ) 

echo compute the mean for the month $MONTH day   $DAY 
pkcomposite  -cr mean  $( ls $DIRTIF_DAY/Y*/M$MONTH/mean*$DAY.tif  | xargs -n 1 echo -i )  -o $DIRTIF_DAY365/mean$JD.tif 









