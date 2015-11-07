#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# for list  in  tiles8_listF?.txt  tiles8_listF??.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_treecover_lossyear2014.sh   ; done 

# bash  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc1_aggregation_treecover_lossyear2014.sh   tiles8_listF52.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=23:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export  INDIRL=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif
export  INDIRT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif
export  OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/lossyear/tif_1km
export  RAM=/dev/shm

rm -rf $RAM/*

export list=$list

echo process $list 

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/$list | xargs -n 1 -P 8  bash -c $' 
tile=$1
# 50N_070E

pkinfo -te   -i  $INDIRL/Hansen_GFC2014_lossyear_${tile}.tif > $RAM/te_$tile.txt 
# echo -te 78 48 80 50  > $RAM/te_$tile.txt  
xmin=$(awk \'{ print $2 -0.02  }\'   $RAM/te_$tile.txt )  
ymin=$(awk \'{ print $3 -0.02  }\'   $RAM/te_$tile.txt )  
xmax=$(awk \'{ print $4 +0.02  }\'   $RAM/te_$tile.txt )  
ymax=$(awk \'{ print $5 +0.02  }\'   $RAM/te_$tile.txt )  

gdalbuildvrt     -te $xmin $ymin $xmax $ymax  -o $RAM/Hansen_GFC2014_lossyear_${tile}.vrt      $INDIRL/Hansen_GFC2014_lossyear_*.tif
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $RAM/Hansen_GFC2014_lossyear_${tile}.vrt      $RAM/Hansen_GFC2014_lossyear_${tile}.tif

gdalbuildvrt     -te $xmin $ymin $xmax $ymax  -o $RAM/Hansen_GFC2014_treecover2000_${tile}.vrt      $INDIRT/Hansen_GFC2014_treecover2000_*.tif
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   $RAM/Hansen_GFC2014_treecover2000_${tile}.vrt      $RAM/Hansen_GFC2014_treecover2000_${tile}.tif

echo masking $RAM/Hansen_GFC2014_lossyear_${tile}.tif

pksetmask -co COMPRESS=LZW -co ZLEVEL=9 -m $RAM/Hansen_GFC2014_lossyear_${tile}.tif -msknodata 1 -nodata 0 -i $RAM/Hansen_GFC2014_treecover2000_${tile}.tif -o $RAM/Hansen_GFC2014_treecover2000_${tile}_loss2001.tif
rm -f  $RAM/Hansen_GFC2014_treecover2000_${tile}.tif

python /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/Aggregation.py  -m "mean"  -no 255  -o $RAM  -ref /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID0_rast.tif  -qa $RAM/Hansen_GFC2014_treecover2000_${tile}_loss2001.tif 

gdal_calc.py  --type=Float32  -A  $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif  --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9   --overwrite  --outfile  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif 
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif   $OUTDIR/1km_mn_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif 
rm -f mean100_Hansen_GFC2014_treecover2000_${tile}_loss2001_tmp.tif $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss2001.tif

for YEAR in $(seq 2002 2013) ; do   

YEAR_PREC=$( expr $YEAR - 1 )
YEAR_CLASS=$( expr $YEAR - 2000 )

echo setting the mask for the $YEAR

pksetmask -co COMPRESS=LZW -co ZLEVEL=9 -m $RAM/Hansen_GFC2014_lossyear_${tile}.tif -msknodata $YEAR_CLASS -nodata 0 -i $RAM/Hansen_GFC2014_treecover2000_${tile}_loss$YEAR_PREC.tif -o $RAM/Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 

echo aggregation $YEAR

python /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/Aggregation.py  -m "mean"  -no 255  -o $RAM  -ref /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID0_rast.tif  -qa $RAM/Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 
gdal_calc.py  --type=Float32  -A  $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif    --calc="(A * 100 )" --co=COMPRESS=LZW  --co=ZLEVEL=9   --overwrite  --outfile  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif 
gdal_translate -ot UInt16  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif   $OUTDIR/1km_mn_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif 
rm -f $RAM/mean100_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}_tmp.tif $RAM/mean_Hansen_GFC2014_treecover2000_${tile}_loss${YEAR}.tif
done

' _ 

rm -rf $RAM/* 

exit 
