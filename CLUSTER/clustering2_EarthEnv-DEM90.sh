
# ls /lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles/*.bil | xargs -n 1 -P 1 bash /lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles/test1.sh
# create 

file=$1

# funziona oft-cluster-latlong.bash 

export filename=`basename $file .bil`
export INDIR=/lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles
export OUTDIR=/lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90
export TMP=/tmp

gdal_translate  -a_nodata -32768  -co COMPRESS=LZW -co ZLEVEL=9 -ot Int16   $INDIR/$filename.bil   $OUTDIR/tif/$filename.tif 
rm -f $OUTDIR/tif/$filename.tif.aux.xml

gdaldem slope    -s 111120      -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/slope/${filename}.tif 
gdaldem aspect  -zero_for_flat  -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/aspect/${filename}.tif

gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/aspect/${filename}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile $OUTDIR/aspect/${filename}"_sin.tif" --overwrite --type Float32
gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/aspect/${filename}.tif --calc="(cos(A * 3.141592 / 180))"  --outfile $OUTDIR/aspect/${filename}"_cos.tif"  --overwrite --type Float32

# start the normalize action 

for dir in slope ; do 
pkinfo -stats  -i $OUTDIR/$dir/$filename.tif       >       $OUTDIR/$dir/$filename.stat.txt  
mean=$(  awk '{  print $6 }'  $OUTDIR/$dir/$filename.stat.txt)
stdev=$( awk '{  print $8 }'  $OUTDIR/$dir/$filename.stat.txt)

# oft-calc  -ot Float32   $OUTDIR/$dir/$filename.tif    $OUTDIR/$dir/${filename}_norm.tif   >  /dev/null <<EOF
# 1
# #1 $mean - $stdev /
# EOF
rm -f  $OUTDIR/$dir/${filename}_norm.tif
gdal_calc.py -A   $OUTDIR/$dir/$filename.tif  --calc="((A - $mean )/ $stdev)"    --outfile  $OUTDIR/$dir/${filename}_norm.tif    --overwrite  
rm  $OUTDIR/$dir/$filename.stat.txt
done


for dir in sin cos ; do 
pkinfo -stats  -i $OUTDIR/aspect/${filename}_${dir}.tif  > $OUTDIR/tif/$filename.stat.txt 
mean=$(  awk '{  print $6 }'  $OUTDIR/tif/$filename.stat.txt )
stdev=$( awk '{  print $8 }'  $OUTDIR/tif/$filename.stat.txt )
# oft-calc  -ot Float32   $OUTDIR/aspect/$filename.tif    $OUTDIR/aspect/${filename}_${dir}_norm.tif   >  /dev/null <<EOF
# 1
# #1 $mean - $stdev /
# EOF
rm -f $OUTDIR/aspect/${filename}_${dir}_norm.tif  
gdal_calc.py -A     $OUTDIR/aspect/${filename}_${dir}.tif     --overwrite   --calc="((A - $mean )/ $stdev)"    --outfile   $OUTDIR/aspect/${filename}_${dir}_norm.tif  

# rm  $OUTDIR/tif/$filename.stat.txt 
done 



for dir in tif ; do 
pkinfo -stats  -i $OUTDIR/$dir/$filename.tif       >       $OUTDIR/$dir/$filename.stat.txt  
mean=$(  awk '{  print $6 }'  $OUTDIR/$dir/$filename.stat.txt)
stdev=$( awk '{  print $8 }'  $OUTDIR/$dir/$filename.stat.txt)

rm -f  $OUTDIR/$dir/${filename}_norm.tif
gdal_calc.py -A   $OUTDIR/$dir/$filename.tif  --calc="((A - $mean )/ $stdev)"    --outfile  $OUTDIR/$dir/${filename}_norm.tif    --overwrite  
rm  $OUTDIR/$dir/$filename.stat.txt
done



echo starting the clustering action

CLUST=10

gdalbuildvrt  -srcnodata -9999 -vrtnodata -9999 -overwrite   -separate $OUTDIR/tif/$filename.vrt    $OUTDIR/slope/${filename}_norm.tif   $OUTDIR/aspect/${filename}"_cos_norm.tif"  $OUTDIR/aspect/${filename}"_sin_norm.tif"
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/tif/$filename.vrt   $OUTDIR/tif/${filename}_slope_sin_cos.tif 
rm -f EarthEnv-DEM90_N40W125.vrt 
oft-cluster-latlong.bash   $OUTDIR/tif/${filename}_slope_sin_cos.tif   $OUTDIR/tif/${filename}_cluster_${CLUST}.tif  $CLUST 60
oft-clump -i $OUTDIR/tif/${filename}_cluster_${CLUST}.tif -o   $OUTDIR/tif/${filename}_clump_${CLUST}.tif
pkcreatect -min 1 -max $CLUST  >   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt
pkcreatect  -ct   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt  -i  $OUTDIR/tif/${filename}_cluster_${CLUST}.tif -o  $OUTDIR/tif/${filename}_cluster_${CLUST}ct.tif

gdal_translate   -expand rgb -of vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.tif  $OUTDIR/tif/${filename}_cluster_${CLUST}ct_rgb.vrt
gdal2tiles.py -k   $OUTDIR/tif/${filename}_cluster_${CLUST}ct_rgb.vrt   $OUTDIR/kml/${filename}_cluster_${CLUST}ct_rgb.kml
rm -f  $OUTDIR/tif/${filename}_cluster_${CLUST}ct_rgb.vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ct_rgb.vrt 
# to gogle earth 

pkfilter -i   $OUTDIR/tif/${filename}_clump_${CLUST}.tif  -f countid -dy 10 -dx 10  -d 10    -o   $OUTDIR/tif/${filename}_countid_${CLUST}.tif


CLUST=10
gdalbuildvrt  -srcnodata -9999 -vrtnodata -9999 -overwrite   -separate $OUTDIR/tif/$filename.vrt    $OUTDIR/aspect/${filename}"_cos_norm.tif"  $OUTDIR/aspect/${filename}"_sin_norm.tif"   
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/tif/$filename.vrt   $OUTDIR/tif/${filename}_sin_cos.tif 
rm -f EarthEnv-DEM90_N40W125.vrt 
oft-cluster-latlong.bash    $OUTDIR/tif/${filename}_sin_cos.tif   $OUTDIR/tif/${filename}_cluster_${CLUST}noslope.tif  $CLUST 60
oft-clump -i $OUTDIR/tif/${filename}_cluster_${CLUST}.tif -o   $OUTDIR/tif/${filename}_clump_${CLUST}_noslope.tif
pkcreatect -min 1 -max $CLUST  >   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt
pkcreatect  -ct   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt  -i  $OUTDIR/tif/${filename}_cluster_${CLUST}noslope.tif -o  $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope.tif

gdal_translate   -expand rgb -of vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope.tif  $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope_rgb.vrt
gdal2tiles.py -k   $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope_rgb.vrt   $OUTDIR/kml/${filename}_cluster_${CLUST}ctnoslope_rgb.kml
rm -f  $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope_rgb.vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ctnoslope_rgb.vrt

pkfilter -i   $OUTDIR/tif/${filename}_clump_${CLUST}_noslope.tif  -f countid -dy 10 -dx 10  -d 10    -o   $OUTDIR/tif/${filename}_countid_${CLUST}_noslope.tif

CLUST=10
gdalbuildvrt  -srcnodata -9999 -vrtnodata -9999 -overwrite   -separate $OUTDIR/tif/$filename.vrt    $OUTDIR/tif/${filename}_norm.tif   $OUTDIR/slope/${filename}_norm.tif   $OUTDIR/aspect/${filename}"_cos_norm.tif"  $OUTDIR/aspect/${filename}"_sin_norm.tif"   
gdal_translate -ot Float32  -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/tif/$filename.vrt   $OUTDIR/tif/${filename}_sin_cos.tif 
rm -f EarthEnv-DEM90_N40W125.vrt 
oft-cluster-latlong.bash    $OUTDIR/tif/${filename}_sin_cos.tif   $OUTDIR/tif/${filename}_cluster_${CLUST}alt.tif  $CLUST 60
oft-clump -i $OUTDIR/tif/${filename}_cluster_${CLUST}.tif -o   $OUTDIR/tif/${filename}_clump_${CLUST}_alt.tif
pkcreatect -min 1 -max $CLUST  >   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt
pkcreatect  -ct   $OUTDIR/tif/${filename}_cluster_${CLUST}ct.txt  -i  $OUTDIR/tif/${filename}_cluster_${CLUST}alt.tif -o  $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt.tif

gdal_translate   -expand rgb -of vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt.tif  $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt_rgb.vrt
gdal2tiles.py -k   $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt_rgb.vrt   $OUTDIR/kml/${filename}_cluster_${CLUST}ctalt_rgb.kml
rm -f  $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt_rgb.vrt   $OUTDIR/tif/${filename}_cluster_${CLUST}ctalt_rgb.vrt

pkfilter -i   $OUTDIR/tif/${filename}_clump_${CLUST}_alt.tif  -f countid -dy 10 -dx 10  -d 10    -o   $OUTDIR/tif/${filename}_countid_${CLUST}_alt.tif


















dir=slope 

pkinfo -stats  -i $OUTDIR/$dir/$filename.tif       >       $OUTDIR/$dir/$filename.stat.txt  
mean=$(  awk '{  print $6 }'  $OUTDIR/$dir/$filename.stat.txt)
stdev=$( awk '{  print $8 }'  $OUTDIR/$dir/$filename.stat.txt)
rm -f $OUTDIR/$dir/${filename}_norm_oft.tif 

oft-calc  -ot Float32   $OUTDIR/$dir/$filename.tif    $OUTDIR/$dir/${filename}_norm_oft.tif   >  /dev/null <<EOF
1
#1 $mean - $stdev /
EOF

rm -f  $OUTDIR/$dir/${filename}_norm_gdal.tif
gdal_calc.py -A   $OUTDIR/$dir/$filename.tif  --calc="((A - $mean )/ $stdev)"    --outfile  $OUTDIR/$dir/${filename}_norm_gdal.tif    --overwrite  

rm  $OUTDIR/$dir/$filename.stat.txt







pkinfo -stats  -i $filename.tif       >   $filename.stat.txt  
mean=$(  awk '{  print $6 }'  $filename.stat.txt)
stdev=$( awk '{  print $8 }'  $filename.stat.txt)
rm -f $OUTDIR/$dir/${filename}_norm_oft.tif 

oft-calc  -ot Float32   $filename.tif    ${filename}_norm_oft.tif   >  /dev/null <<EOF
1
#1 $mean - $stdev /
EOF

rm -f  ${filename}_norm_gdal.tif
gdal_calc.py -A  $filename.tif  --calc="((A - $mean )/ $stdev)"    --outfile  ${filename}_norm_gdal.tif    --overwrite  

rm  $filename.stat.txt











dir=sin
pkinfo -stats  -i ${filename}_${dir}.tif  > $filename.stat.txt 
mean=$(  awk '{  print $6 }'  $filename.stat.txt )
stdev=$( awk '{  print $8 }'  $filename.stat.txt )
rm -f ${filename}_${dir}_norm_oft.tif 
oft-calc  -ot Float32   $filename.tif    ${filename}_${dir}_norm_oft.tif   >  /dev/null <<EOF
1
#1 $mean - $stdev /
EOF
rm -f ${filename}_${dir}_norm_gdal.tif  
gdal_calc.py -A     ${filename}_${dir}.tif     --overwrite   --calc="((A - $mean )/ $stdev)"    --outfile   ${filename}_${dir}_norm_gdal.tif  



rm  $OUTDIR/tif/$filename.stat.txt 


