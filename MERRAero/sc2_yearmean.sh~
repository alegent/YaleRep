
# transform to tif in litoria 
# export OUTDIR=/mnt/data2/scratch/GMTED2010/MERRAero
# for YEAR in `seq 2002 2014` ; do   
#      for month  in M01 M02 M03 M04 M05 M06 M07 M08 M09 M10 M11 M12 ;  do 
#
#	 export YEAR=$YEAR
#        export month=$month
#
# ls   $OUTDIR/nc/Y$YEAR/$month/*.nc4  | xargs -n 1 -P 16 bash -c    $' 
# file=$1
# echo $file
# filename=`basename  $file .nc4`
# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  NETCDF:"$OUTDIR/nc/Y$YEAR/$month/$filename.nc4":AODANA  $OUTDIR/tif/Y$YEAR/$month/$filename.tif 
# ' _ 
#     done  
# done


# for YEAR in `seq 2002 2014` ; do   for MONTH  in 01 02 03 04 05 06 07 08 09 10 11 12 ;  do  qsub -v  YEAR=$YEAR,MONTH=$MONTH  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc1_daymean.sh  ; sleep 30 ;  done ;  done  

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MERRAero/sc1_daymean.sh   2003 01 



#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=00:30:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

export DIRTIF=/lustre0/scratch/ga254/dem_bj/MERRAero/tif
export DIRTIF_DAY=/lustre0/scratch/ga254/dem_bj/MERRAero/tif_day
export YEAR=$YEAR
export MONTH=$MONTH


cd $DIRTIF/Y$YEAR/M$MONTH

# to list the uniq day for month  wich change in acoordance to the month and the year 

ls | xargs -n 1 bash -c $' file=$1 ;  echo ${file:35:2}   ' _ | sort | uniq   | xargs -n 1 -P 8 bash -c $' 

export DAY=$1 
echo compute the mean or the $DAY day 
 pkcomposite  -cr mean  $( ls $DIRTIF/Y$YEAR/M$MONTH/dR_MERRA-AA-r2.inst2d_gaas_x.$YEAR$MONTH${DAY}_{06,09,12,15,18,21}00z.tif  | xargs -n 1 echo -i )  -o $DIRTIF_DAY/Y$YEAR/M$MONTH/mean$YEAR$DAY.tif 

' _ 





