# qsub -v DAYc=261,WIND=7 /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_MOD04_L2_MYD04_L2/sc2_window_mean_C51.sh 

# for DAYc  in `head -10  /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt`  ; do qsub -v DAYc=$DAYc,WIND=7 /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_MOD04_L2_MYD04_L2/sc2_window_median_C51_w11.sh ; done

# 6 hour for 7 window 

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=18:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


export INDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/mean_${WIND}/tif
export DAYc=$DAYc
export WIND=$WIND

echo processing median for the $DAYc using $WIND days moving window


# mininimum value -50 * 3 = -150 

# create a txt for the vrt with the only files that exist

rm -f  $OUTDIR/file4vrt_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls $INDIR/$YEAR/tif/MYD04_Deep_Blue_Aerosol_Optical_Depth_550_Land_year${YEAR}_day${DAY}.tif 2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR/$YEAR/tif/MOD04_Deep_Blue_Aerosol_Optical_Depth_550_Land_year${YEAR}_day${DAY}.tif 2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR/$YEAR/tif/MYD04_Corrected_Optical_Depth_Land_year${YEAR}_day${DAY}.tif             2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR/$YEAR/tif/MOD04_Corrected_Optical_Depth_Land_year${YEAR}_day${DAY}.tif             2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
    done 
done

pkcomposite  $(cat $OUTDIR/file4vrt_day${DAYc}.txt               |  xargs -n 1 echo -i $1 )   -min -1 -max 5001 -cr median  -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_median_day${DAYc}.tif
# pkcomposite  $(grep "tif/MOD04"  $OUTDIR/file4vrt_day${DAYc}.txt |  xargs -n 1 echo -i $1 )   -min -1 -max 5001 -cr mean  -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_MOD04_mean_day${DAYc}.tif
# pkcomposite  $(grep "tif/MYD04"  $OUTDIR/file4vrt_day${DAYc}.txt |  xargs -n 1 echo -i $1 )   -min -1 -max 5001 -cr mean  -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_550_MYD04_mean_day${DAYc}.tif

rm -f $OUTDIR/file4vrt_day${DAYc}.txt

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






