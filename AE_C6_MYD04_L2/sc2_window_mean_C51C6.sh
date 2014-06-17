# qsub -v DAYc=011,WIND=7 /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc2_window_mean_C51C6.sh
# bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc2_window_mean_C51C6.sh 011 2 

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l mem=4gb          
#PBS -l walltime=10:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr


export INDIR_C51=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2
export INDIR_C6=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2
export OUTDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/mean_${WIND}_C51C6/tif
export DAYc=$DAYc
#export DAYc=$1
export WIND=$WIND
#export WIND=$2

echo multiply the AOD for the quality flag 

awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc +16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt  | xargs -n 1  -P 8  bash -c $' 

DAY=$1

for YEAR in $(seq 2002 2014)  ; do 

#  gdal_info -mm -50.000,5000.000
if [ -f $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif ] ; then 

gdal_calc.py -A $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif -B $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif --calc="( A * B)" --type Int16  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --overwrite --outfile=$INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_mult_QA_year${YEAR}_day${DAY}.tif

fi 

done 

' _ 

echo sum the multiplication for $DAYc

# mininimum value -50 * 3 = -150 
# insterted if condition to avoid blocking in case of missing files. 
# QA sum

# list the multiplied file $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_mult_QA_year${YEAR}_day${DAY}.tif 

rm -f  $OUTDIR/file_4AOD_550_sum_day${DAYc}.txt $OUTDIR/file_4AOD_550_QA_sum_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_mult_QA_year${YEAR}_day${DAY}.tif       2> /dev/null >>  $OUTDIR/file_4AOD_550_sum_day${DAYc}.txt
	ls $INDIR_C6/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif       2> /dev/null >>  $OUTDIR/file_4AOD_550_QA_sum_day${DAYc}.txt
    done 
done

pkcomposite  $(cat $OUTDIR/file_4AOD_550_sum_day${DAYc}.txt     |  xargs -n 1 echo -i  )   -min -9990  -cr sum   -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_C6_sum_day${DAYc}.tif

# rm previus file 

pkcomposite  $(cat $OUTDIR/file_4AOD_550_QA_sum_day${DAYc}.txt |   xargs -n 1 echo -i  )   -min -9990  -cr sum   -dstnodata -9999  -srcnodata -9999  -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -o $OUTDIR/AOD_QA_C6_sum_day${DAYc}.tif

echo  finish weigthed for the C6

# list the C51 file 
rm $OUTDIR/file4vrt_day${DAYc}.txt
for YEAR in  $(seq 2002 2014) ; do 
    for DAY in $(awk -v DAYc=$DAYc -v WIND=$WIND ' { if (  NR >= DAYc + 16 - WIND && NR<= DAYc + 16 + WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt ) ; do  
	# redirect the sterr to dev/null if the file is missing # to a file if the file is there 
	ls $INDIR_C51/$YEAR/tif/MYD04_Deep_Blue_Aerosol_Optical_Depth_550_Land_year${YEAR}_day${DAY}.tif 2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR_C51/$YEAR/tif/MOD04_Deep_Blue_Aerosol_Optical_Depth_550_Land_year${YEAR}_day${DAY}.tif 2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR_C51/$YEAR/tif/MYD04_Corrected_Optical_Depth_Land_year${YEAR}_day${DAY}.tif             2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
	ls $INDIR_C51/$YEAR/tif/MOD04_Corrected_Optical_Depth_Land_year${YEAR}_day${DAY}.tif             2> /dev/null >>  $OUTDIR/file4vrt_day${DAYc}.txt
    done 
done

echo sum and create count layer for the C51 
pkcomposite $(cat $OUTDIR/file4vrt_day${DAYc}.txt | xargs -n 1 echo -i ) -min -9990 -cr sum -dstnodata -9999 -srcnodata -9999 -ot Int32 -co COMPRESS=LZW -co ZLEVEL=9 -o $OUTDIR/AOD_C51_sum_day${DAYc}.tif -file 

# rm -f $OUTDIR/file4vrt_day${DAYc}.txt
# calculate the average 

# extract band 2 from the composite one 

gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9    -b 2 $OUTDIR/AOD_C51_sum_day${DAYc}.tif  $OUTDIR/AOD_QA_C51_sum_day${DAYc}.tif  

echo calculate the finall mean 


pkcomposite  -i  $OUTDIR/AOD_C6_sum_day${DAYc}.tif    -i   $OUTDIR/AOD_C51_sum_day${DAYc}.tif    -min -9990 -cr sum -dstnodata -9999 -srcnodata -9999 -ot Int32 -co COMPRESS=LZW -co ZLEVEL=9 -o $OUTDIR/AOD_C51_C6_sum_day${DAYc}.tif
pkcomposite  -i  $OUTDIR/AOD_QA_C6_sum_day${DAYc}.tif -i   $OUTDIR/AOD_QA_C51_sum_day${DAYc}.tif -min -9990 -cr sum -dstnodata 0 -srcnodata -9999  -ot Int32 -co COMPRESS=LZW -co ZLEVEL=9 -o $OUTDIR/AOD_QA_C51_C6_sum_day${DAYc}.tif

gdal_calc.py -A    $OUTDIR/AOD_C6_sum_day${DAYc}.tif  -B   $OUTDIR/AOD_C51_sum_day${DAYc}.tif  -C  $OUTDIR/AOD_QA_C6_sum_day${DAYc}.tif -D  $OUTDIR/AOD_QA_C51_sum_day${DAYc}.tif   --calc="( (A + B) / ( C + D) )" --type Int16   --NoDataValue=-99999 --co=COMPRESS=LZW --co=ZLEVEL=9 --overwrite --outfile=$OUTDIR/AOD_550_Dark_Target_Deep_Blue_day${DAYc}.tif

# checkjob -v $PBS_JOBID

exit 


# validation yes the weight average is correct 


awk -v DAYc=$DAYc ' { if (  NR >= DAYc +16-WIND && NR<= DAYc +16+WIND ) print $0  }' /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list_year_round.txt  | xargs -n 1  -P 8 bash -c $'

DAY=$1

for YEAR in 2004 2005 2006 ; do 

# echo  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif

echo $YEAR $(gdallocationinfo  -valonly  $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day${DAY}.tif 2677 982 )   $(gdallocationinfo  -valonly $INDIR/$YEAR/tif/AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag_year${YEAR}_day${DAY}.tif 2677 982 ) 

done 


' _ 






