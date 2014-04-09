
#  ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif   | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc3_mean_merge_radiation.sh 
#  ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc3_mean_merge_radiation.sh 

#  for each tile pkmosaic to calculate the average 

tile=`basename $1 .tif`

INDIR=/mnt/data2/scratch/GMTED2010/grassdb/glob_rad

pkmosaic $( for day in `seq 1 31`; do echo    -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month1_${tile}.tif
pkmosaic $( for day in `seq 32 59`; do echo   -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month2_${tile}.tif
pkmosaic $( for day in `seq 60 90`; do echo   -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month3_${tile}.tif
pkmosaic $( for day in `seq 91 120`; do echo  -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month4_${tile}.tif
pkmosaic $( for day in `seq 121 151`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month5_${tile}.tif
pkmosaic $( for day in `seq 152 181`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month6_${tile}.tif
pkmosaic $( for day in `seq 182 212`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month7_${tile}.tif
pkmosaic $( for day in `seq 213 243`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month8_${tile}.tif
pkmosaic $( for day in `seq 244 273`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month9_${tile}.tif
pkmosaic $( for day in `seq 274 304`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month10_${tile}.tif
pkmosaic $( for day in `seq 305 334`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month11_${tile}.tif
pkmosaic $( for day in `seq 335 365`; do echo -i $INDIR/$day/glob_rad_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_rad_month12_${tile}.tif


# gdal_merge.py -n -1   -co COMPRESS=LZW -co ZLEVEL=9   -ul_lr -180 +90 +180 -90  -o $INDIR/glob_rad_day${day}.tif $INDIR/glob_rad_day${day}_?_?.tif


