
# echo  001 017 033 049 065 081 097 113 129 145 161 177 193 209 225 241 257 273 289 305 321 337 353 |  xargs -n 1  -P 4  bash /mnt/data2/scratch/GMTED2010/scripts/sc3_merge_solar_radiation.sh

day=$1
INDIR=/media/data/grassdb1/glob_rad_$day

rm -f $INDIR/glob_rad_day${day}.tif
gdal_merge.py -n -1   -co COMPRESS=LZW -co ZLEVEL=9   -ul_lr -180 +90 +180 -90  -o $INDIR/glob_rad_day${day}.tif $INDIR/glob_rad_day${day}_?_?.tif


