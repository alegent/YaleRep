
#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# for list  in  tiles8_listF?.txt  tiles8_listF??.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_lossyear2014.sh  ; done 

# bash  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_lossyear2014.sh   tiles8_listF52.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_1km
export RAM=/dev/shm

rm -rf $RAM/*

export list=$list
echo process $list

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/$list   | xargs -n 1 -P 8  bash -c $' 
tile=$1 

# 50N_070E

pkinfo -te   -i  $INDIR/Hansen_GFC2014_lossyear_${tile}.tif > $RAM/te_$tile.txt 
# echo -te 78 48 80 50  > $RAM/te_$tile.txt  
xmin=$(awk \'{ print $2 -0.02  }\'   $RAM/te_$tile.txt )  
ymin=$(awk \'{ print $3 -0.02  }\'   $RAM/te_$tile.txt )  
xmax=$(awk \'{ print $4 +0.02  }\'   $RAM/te_$tile.txt )  
ymax=$(awk \'{ print $5 +0.02  }\'   $RAM/te_$tile.txt )  

gdalbuildvrt     -te $xmin $ymin $xmax $ymax  -o $RAM/Hansen_GFC2014_lossyear_${tile}.vrt      $INDIR/Hansen_GFC2014_lossyear_*.tif
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $RAM/Hansen_GFC2014_lossyear_${tile}.vrt      $RAM/Hansen_GFC2014_lossyear_${tile}.tif

for YEAR in $(seq 1 13) ; do 
YEARF=$(expr $YEAR + 2000 ) 
pkgetmask -ot Float32  -co  COMPRESS=LZW -co ZLEVEL=9  -min $YEAR -max $YEAR -data 1 -nodata 0 -i  $RAM/Hansen_GFC2014_lossyear_${tile}.tif  -o $RAM/Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif 

echo aggregation $YEARF

python /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/Aggregation.py  -m "mean" -no 255 -o $RAM -ref /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID0_rast.tif  -qa $RAM/Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif 

gdal_calc.py  -A   $RAM/mean_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif     --calc="(A * 10000)" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile  $RAM/mean100_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif
rm -f  $RAM/mean_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/mean100_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif   $OUTDIR/1km_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif
rm -f $RAM/mean100_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif $RAM/mean_Hansen_GFC2014_lossyear_${tile}_loss${YEARF}.tif 

done 

' _

checkjob -v $PBS_JOBID 
