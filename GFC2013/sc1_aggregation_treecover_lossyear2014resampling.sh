#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# for list  in  tiles8_listF?.txt  tiles8_listF??.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_treecover_lossyear2014resampling.sh   ; done 

# bash  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_treecover_lossyear2014resampling.sh   tiles8_listF52.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=23:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export  INDIRL=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif
export  INDIRT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif
export  INDIRL_R=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_res
export  INDIRT_R=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif_res
export  OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_1km
export  RAM=/dev/shm

rm -rf $RAM/*

export list=$list

echo process $list 

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/$list | xargs -n 1 -P 8  bash -c $' 
tile=$1
# 50N_070E

gdalwarp -srcnodata 255 -dstnodata  255 -overwrite -co COMPRESS=LZW -co ZLEVEL=9 -tr 0.00025252525252525 0.00025252525252525 -r near  $INDIRL/Hansen_GFC2014_lossyear_${tile}.tif      $INDIRL_R/Hansen_GFC2014_lossyear_${tile}.tif
gdalwarp -srcnodata 255 -dstnodata  255 -overwrite -co COMPRESS=LZW -co ZLEVEL=9 -tr 0.00025252525252525 0.00025252525252525 -r near  $INDIRT/Hansen_GFC2014_treecover2000_${tile}.tif $INDIRT_R/Hansen_GFC2014_treecover2000_${tile}.tif

echo masking $RAM/Hansen_GFC2014_lossyear_${tile}.tif

pksetmask -co COMPRESS=LZW -co ZLEVEL=9 -m  $INDIRL_R/Hansen_GFC2014_lossyear_${tile}.tif   -msknodata 1 -nodata 0 -i $INDIRT_R/Hansen_GFC2014_treecover2000_${tile}.tif -o $RAM/Hansen_GFC2014_treecover2000_${tile}_loss2001.tif

pkfilter  -co COMPRESS=LZW -ot  Float32    -dx 33 -dy 33   -f mean  -d 33  -i  $RAM/Hansen_GFC2014_treecover2000_${tile}_loss2001.tif  -o $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif

gdal_calc.py --type=Float32 -A  $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif  --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9   --overwrite  --outfile  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif 
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif   $OUTDIR/1km_mn_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif 
rm -f $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif

for YEAR in $(seq 2002 2013) ; do   

YEAR_PREC=$( expr $YEAR - 1 )
YEAR_CLASS=$( expr $YEAR - 2000 )

echo setting the mask for the $YEAR

pksetmask -co COMPRESS=LZW -co ZLEVEL=9 -m $INDIRL_R/Hansen_GFC2014_lossyear_${tile}.tif  -msknodata $YEAR_CLASS -nodata 0 -i  $RAM/Hansen_GFC2014_treecover2000_${tile}_loss$YEAR_PREC.tif  -o $RAM/Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 
rm  $RAM/Hansen_GFC2014_treecover2000_${tile}_loss$YEAR_PREC.tif 
echo aggregation $YEAR

pkfilter -co COMPRESS=LZW -ot Float32    -dx 33 -dy 33   -f mean  -d 33  -i $RAM/Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif -o  $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 

gdal_calc.py  --type=Float32  -A  $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif    --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9   --overwrite  --outfile  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif 
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif   $OUTDIR/1km_mn_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 
rm -f $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif
done

' _ 

rm -rf $RAM/* 

exit 
