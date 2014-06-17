
# for DAYc in $(  awk '{ print $3  }'  /lustre0/scratch/ga254/dem_bj/MERRAero/tif_day/MMDD_JD_0JD.tx  ) ; do qsub -v  DAYc=$DAYc,WIND=15  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc2_window_mean.sh    ; done  

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc2_window_mean.sh   030


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=00:30:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

echo working 

DIRTIF_DAY=/lustre0/scratch/ga254/dem_bj/MERRAero/tif_day
DIRTIF_W15=/lustre0/scratch/ga254/dem_bj/MERRAero/tif_mean_w15_day365

# DAYc=$1
# WIND=15

rm -f   $DIRTIF_W15/file4vrt_day${DAYc}.txt

for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	MMDD=$( awk -v  DAYc=$DAYc '{ if($3==DAYc) print $1  }'  /lustre0/scratch/ga254/dem_bj/MERRAero/tif_day/MMDD_JD_0JD.txt   ) 
	# echo MMDD $MMDD
	MONTH=${MMDD:0:2}
	DAY=${MMDD:2:2}
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls  $DIRTIF_DAY/Y$YEAR/M$MONTH/mean$YEAR$DAY.tif   2> /dev/null >>  $DIRTIF_W15/file4vrt_day${DAYc}.txt
    done 
done

echo start the mean computation  $DIRTIF_W15/mean${DAYc}.tif

pkcomposite  $(cat  $DIRTIF_W15/file4vrt_day${DAYc}.txt | xargs -n 1 echo -i  )  -cr mean    -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   -o  $DIRTIF_W15/mean${DAYc}.tif












