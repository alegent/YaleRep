# qsub -v DAYc=010,WIND=15 /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc3_window_weightmean.sh

# for DAYc  in `tail -365 /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt`  ; do qsub -v DAYc=$DAYc,WIND=15 /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc3_window_weightmean.sh ; done 

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=18:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


export INDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/mean_${WIND}_C6/tif
export DAYc=$DAYc
export WIND=$WIND
echo multiply the AOD for the quality flag

echo sum the multiplication for $DAYc

# mininimum value -50 * 3 = -150  ..... 5000 x 3 = 15000   ... dove 3 e' il quality flag 0 1 2 3 


# fa la somma dey valori moltiplicati 
rm -f  $OUTDIR/file4vrt_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_mult_QA_year${YEAR}_day${DAY}.tif  2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
    done 
done
pkcomposite  $(cat $OUTDIR/file4vrt_day${DAYc}.txt |  xargs -n 1 echo -i $1 ) -min -151  -max 15001  -cr sum -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_sum_day${DAYc}.tif

echo sum the quality for $DAYc
rm -f  $OUTDIR/file4vrt_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif  2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
    done 
done

pkcomposite   $(cat $OUTDIR/file4vrt_day${DAYc}.txt |  xargs -n 1 echo -i $1 ) -min -1 -max 4 -cr sum -dstnodata -9999  -srcnodata -9999   -srcnodata 0   -ot Int32  -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_QA_sum_day${DAYc}.tif

gdal_calc.py -A    $OUTDIR/AOD_550_sum_day${DAYc}.tif  -B   $OUTDIR/AOD_550_QA_sum_day${DAYc}.tif  --calc="( A /  B)" --type Int16   --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --overwrite --outfile=$OUTDIR/AOD_550_Dark_Target_Deep_Blue_day${DAYc}.tif
rm -f  $OUTDIR/file4vrt_day${DAYc}.txt   $OUTDIR/AOD_550_sum_day${DAYc}.tif   $OUTDIR/AOD_550_QA_sum_day${DAYc}.tif 

checkjob -v $PBS_JOBID

exit 



# validation yes the weight average is correct 


awk -v DAYc=$DAYc ' { if (  NR >= DAYc +16-WIND && NR<= DAYc +16+WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt  | xargs -n 1  -P 8 bash -c $'

DAY=$1

for YEAR in 2004 2005 2006 ; do 

# echo  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif

echo $YEAR $(gdallocationinfo  -valonly  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif 2677 982 )   $(gdallocationinfo  -valonly $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif 2677 982 ) 

done 


' _ 






