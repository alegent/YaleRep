# for DAYc in $(  awk '{ print $3  }'  /scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt   ) ; do qsub -v  DAYc=$DAYc  /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_AE_C6_MYD04_L2_MERRAero.sh   ; done  

# for DAYc in $(  awk '{ print $3  }'  /scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt | tail -50   ) ; do bash  /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_AE_C6_MYD04_L2_MERRAero.sh $DAYc   ; done  

#  awk '{ print $3  }'  /scratch/fas/sbsc/ga254/dataproces/MERRAero/tif_day/MMDD_JD_0JD.txt  | xargs -n 1  -P 16   bash  /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_AE_C6_MYD04_L2_MERRAero.sh 

# bash /home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_AE_C6_MYD04_L2_MERRAero.sh   030


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

echo working 


DIRTIF_M=/lustre/scratch/client/fas/sbsc/ga254/dataproces/MERRAero/tif_mean_w15_day365_res10km
DIRTIF_C=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/mean_15_C6/tif  
OUTDIR=/scratch/fas/sbsc/ga254/dataproces/AE_C6_MYD04_L2/integration/tif 

DAYc=$1

echo start the data integration   mean${DAYc}.tif  

# fill no data 
pkgetmask -min -101 --max 5001 -data 1 -nodata 0 -i $DIRTIF_C/AOD_550_mean_day${DAYc}.tif    -o $DIRTIF_C/AOD_550_mask_day${DAYc}.tif   

pkfillnodata -m $DIRTIF_C/AOD_550_mask_day${DAYc}.tif  -d 1 -it 1 -i $DIRTIF_C/AOD_550_mean_day${DAYc}.tif    -o $DIRTIF_C/AOD_550_fill_day${DAYc}.tif   

pkcomposite  -cr overwrite  -dstnodata -9999  -srcnodata -9999  -ot Int32  -co COMPRESS=LZW -co ZLEVEL=9  -i  $DIRTIF_M/mean${DAYc}.tif   -i $DIRTIF_C/AOD_550_fill_day${DAYc}.tif    -o $OUTDIR/mean${DAYc}.tif  





