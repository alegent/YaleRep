


pkcreatect   -min 1 -max 255  >  color.txt
cat /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt | xargs -n 1 -P 10 bash -c  $'
DAYc=$1
gdal_translate -scale  0 5000 1 255  -ot Byte -a_nodata 0   AOD_550_mean_day${DAYc}.tif  AOD_550_mean_day${DAYc}_byte.tif

pkcreatect  -ct   color.txt -co COMPRESS=LZW -co ZLEVEL=9  -i  AOD_550_mean_day${DAYc}_byte.tif -o   AOD_550_mean_day${DAYc}_byte_ct.tif

' _ 


cat /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt xargs -n 1 echo AOD_550_mean_day${$1}_byte_ct.tif 



convert -scale 50%  -delay 200 -loop 0 $(head -40 /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt | xargs -n 1 bash -c $' echo 'AOD_550_mean_day'$1'_byte_ct.tif'  ' _ ) test.gif 


