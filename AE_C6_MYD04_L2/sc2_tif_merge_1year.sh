
# qsub -S /bin/bash -v YEAR=2005  /lustre/home/client/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc2_tif_merge_1year.sh

#  for YEAR in `seq 2002 2014` ; do  qsub -S /bin/bash -v YEAR=$YEAR    /lustre/home/client/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc2_tif_merge_1year.sh    ; done  

# bash   /lustre/home/client/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc2_tif_merge_1year.sh   2004   

# 80 ore per un anno .. mi sembra che si blocca con 80 
# 8 for each node 

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=0:04:00:00
#PBS -l nodes=2:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# export YEAR=$1

export YEAR=$YEAR

cat   /scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/day_list.txt  | xargs -n 1 -P 16  bash -c $'  

export DAY=$1


TIFDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/$YEAR/tif
MERGEDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/$YEAR/tif_merge

# pixel value in the Quality_Assurance_Land 17 = 0 ;  51 = 1 ;  85 = 2 ; 119 = 3 

# Corrected_Optical_Depth_Land                             valid_range=-100, 5000     min importanve 
# Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate   valid_range=0, 5000        median importanve 
# AOD_550_Dark_Target_Deep_Blue_Combined                   valid_range=-100, 5000     max importance 

pksetmask   -ot Int32   -co COMPRESS=LZW -co ZLEVEL=9   -m $TIFDIR/Quality_Assurance_Land_year${YEAR}_day$DAY.tif -msknodata 17 51 85 -nodata -9999 -i $TIFDIR/Corrected_Optical_Depth_Land_year${YEAR}_day$DAY.tif -o  $TIFDIR/Corrected_Optical_Depth_Land_QA_year${YEAR}_day$DAY.tif  

# the last one overwrite the full 

pkcomposite -srcnodata -9999 -dstnodata -9999  -min -101 -max 5001  -ot Int32  -co COMPRESS=LZW -co ZLEVEL=9   -cr overwrite  -i   $TIFDIR/Corrected_Optical_Depth_Land_QA_year${YEAR}_day$DAY.tif  -i   $TIFDIR/Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate_year${YEAR}_day$DAY.tif   -i   $TIFDIR/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day$DAY.tif  -o  $MERGEDIR/Combined_year${YEAR}_day$DAY.tif

# deciso di spostarlo dopo la media window 

# pkgetmask -min -101  --max 5001 -data 1 -nodata 0 -i $MERGEDIR/Combined_year${YEAR}_day$DAY.tif     -o   $MERGEDIR/Combined_year${YEAR}_day${DAY}_mask.tif
# pkfillnodata -m   $MERGEDIR/Combined_year${YEAR}_day${DAY}_mask.tif   -d 1 -it 1 -i  $MERGEDIR/Combined_year${YEAR}_day$DAY.tif  -o  $MERGEDIR/Combined_year${YEAR}_day${DAY}_fill.tif


' _ 

exit 


