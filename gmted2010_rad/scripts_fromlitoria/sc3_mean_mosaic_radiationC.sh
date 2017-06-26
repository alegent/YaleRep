
#  ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/?_?.tif   | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc3_mean_merge_radiation.sh 
#  ls  /mnt/data2/scratch/GMTED2010/tiles/mn75_grd_tif/{1_1,1_2,2_1,2_2,1_0,2_0}.tif  | xargs -n 1  -P 10  bash /mnt/data2/scratch/GMTED2010/scripts/sc3_mean_mosaic_radiationC.sh 

#  for each tile pkmosaic to calculate the average 

tile=`basename $1 .tif`

INDIR=/mnt/data2/scratch/GMTED2010/grassdb/glob_rad

pkmosaic $( for day in `seq 1 31`; do echo    -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month1_${tile}.tif
pkmosaic $( for day in `seq 32 59`; do echo   -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month2_${tile}.tif
pkmosaic $( for day in `seq 60 90`; do echo   -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month3_${tile}.tif
pkmosaic $( for day in `seq 91 120`; do echo  -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month4_${tile}.tif
pkmosaic $( for day in `seq 121 151`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month5_${tile}.tif
pkmosaic $( for day in `seq 152 181`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month6_${tile}.tif
pkmosaic $( for day in `seq 182 212`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month7_${tile}.tif
pkmosaic $( for day in `seq 213 243`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month8_${tile}.tif
pkmosaic $( for day in `seq 244 273`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month9_${tile}.tif
pkmosaic $( for day in `seq 274 304`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month10_${tile}.tif
pkmosaic $( for day in `seq 305 334`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month11_${tile}.tif
pkmosaic $( for day in `seq 335 365`; do echo -i $INDIR/$day/glob_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/glob_radC_month12_${tile}.tif


pkmosaic $( for day in `seq 1 31`; do echo    -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month1_${tile}.tif
pkmosaic $( for day in `seq 32 59`; do echo   -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month2_${tile}.tif
pkmosaic $( for day in `seq 60 90`; do echo   -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month3_${tile}.tif
pkmosaic $( for day in `seq 91 120`; do echo  -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month4_${tile}.tif
pkmosaic $( for day in `seq 121 151`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month5_${tile}.tif
pkmosaic $( for day in `seq 152 181`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month6_${tile}.tif
pkmosaic $( for day in `seq 182 212`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month7_${tile}.tif
pkmosaic $( for day in `seq 213 243`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month8_${tile}.tif
pkmosaic $( for day in `seq 244 273`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month9_${tile}.tif
pkmosaic $( for day in `seq 274 304`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month10_${tile}.tif
pkmosaic $( for day in `seq 305 334`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month11_${tile}.tif
pkmosaic $( for day in `seq 335 365`; do echo -i $INDIR/$day/beam_radC_day${day}_${tile}.tif; done ) -srcnodata -1 -dstnodata -1 -co COMPRESS=LZW -co ZLEVEL=9  -cr mean -o $INDIR/months/beam_radC_month12_${tile}.tif















