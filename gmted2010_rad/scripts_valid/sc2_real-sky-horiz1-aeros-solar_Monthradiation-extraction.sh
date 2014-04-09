
# using the shape nsrdb  extract information from the month data radiation dif


export INTIF=/mnt/data2/scratch/GMTED2010/grassdb/
export SHPIN=/mnt/data2/scratch/GMTED2010/solar_radiation/shp
export SHPOUT=/mnt/data2/scratch/GMTED2010/grassdb/shp


rm  -f $SHPOUT/p-ext-real-sky-glob-horiz1.*
pkextract -i  $INTIF/glob_rad/months_merge_horiz1_aeros/glob_HradCA_months.tif  -ft Integer  -lt  String -bn glob  -s   $SHPIN/point_nsrdb.shp   -o $SHPOUT/p-ext-real-sky-glob-horiz1-aeros.shp 

rm  -f $SHPOUT/p-ext-real-sky-glob-diff-horiz1.*
pkextract -i  $INTIF/diff_rad/months_merge_horiz1_aeros/diff_HradCA_months.tif  -ft Integer  -lt  String -bn diff  -s  $SHPOUT/p-ext-real-sky-glob-horiz1-aeros.shp   -o $SHPOUT/p-ext-real-sky-glob-diff-horiz1-aeros.shp 
               
rm  -f $SHPOUT/p-ext_real-sky-glob-diff-beam-horiz1.*
pkextract -i  $INTIF/beam_rad/months_merge_horiz1_aeros/beam_HradCA_months.tif  -ft Integer  -lt  String -bn beam  -s  $SHPOUT/p-ext-real-sky-glob-diff-horiz1-aeros.shp  -o $SHPOUT/p-ext-real-sky-glob-diff-beam-horiz1-aeros.shp  


