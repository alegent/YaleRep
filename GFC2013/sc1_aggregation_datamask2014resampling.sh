#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# for list  in  tiles8_listF?.txt  tiles8_listF??.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_datamask2014resampling.sh ; done 

# bash /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_datamask2014resampling.sh  tiles8_listF1.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

INDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/
OUTDIR=/lustre0/scratch/ga254/dem_bj/GFC2013/datamask/tif_1km


export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif
export INDIRM_R=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif_res
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif_1km
export RAM=/dev/shm

rm -rf $RAM/*

export list=$list
echo process $list

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/$list  | xargs -n 1 -P 8  bash -c $' 
tile=$1 

gdalwarp -srcnodata 255 -dstnodata  255 -overwrite -co COMPRESS=LZW -co ZLEVEL=9 -tr 0.00025252525252525 0.00025252525252525 -r near  $INDIR/Hansen_GFC2014_datamask_${tile}.tif      $INDIRM_R/Hansen_GFC2014_datamask_${tile}.tif
pkfilter    -co COMPRESS=LZW -ot  Float32   -class 1  -dx 33 -dy 33   -f density -d 33  -i    $INDIRM_R/Hansen_GFC2014_datamask_${tile}.tif  -o  $RAM/1km_tmp_Hansen_GFC2014_datamask_${tile}.tif
gdal_calc.py  -A $RAM/1km_tmp_Hansen_GFC2014_datamask_${tile}.tif    --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9    --overwrite  --outfile  $RAM/1km_tmp2_Hansen_GFC2014_datamask_${tile}.tif
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9 $RAM/1km_tmp2_Hansen_GFC2014_datamask_${tile}.tif    $OUTDIR/1km_Hansen_GFC2014_datamask_${tile}.tif
rm  $RAM/1km_tmp_Hansen_GFC2014_datamask_${tile}.tif   $RAM/1km_tmp2_Hansen_GFC2014_datamask_${tile}.tif 

' _

checkjob -v $PBS_JOBID 



