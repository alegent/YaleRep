module load Tools/CDO/1.6.4  

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING

cd $DIR

cleanram
rm -f   $DIR/piecewise/*/*/*.*

export RAM=/dev/shm 

ls  $DIR/input/*/*/*G4*.nc | grep -v oned  | xargs -n 1 -P 1  bash -c $'

file=$1
filename=$(basename $file .nc) 
dirinput=$(dirname $file)

dir=$( basename $( dirname  $dirinput ) )


echo change the temperature to  celsius and calculate the temporal piecewise 

if [ ${filename:0:3} = "tas"   ] ; then 
cdo addc,-273.15   -selyear$(for year in $(seq 2020 2069 ) ; do echo -n ,$year ; done)    $file   $RAM/${filename}_transf.nc  
par=${filename:0:3}
fi 

if [ ${filename:0:3} = "pr_"   ] ; then 
cdo mulc,2592000   -selyear$(for year in $(seq 2020  2069 ) ; do echo -n ,$year ; done)   $file    $RAM/${filename}_transf.nc  
par=${filename:0:2}
fi 

cdo yearmean  $RAM/${filename}_transf.nc   $RAM/${filename}_year_mean.nc  
cp   $RAM/${filename}_year_mean.nc   $DIR/piecewise/$dir/$par/${filename}_year_mean.nc 

rm  -f  $RAM/${filename}_year_mean_band*.vrt  $RAM/${filename}_transf.nc  

for band in $(seq 1 50) ; do
     echo vfr $band band 
     gdalbuildvrt   -b $band   $RAM/${filename}_year_mean_band$band.vrt   $RAM/${filename}_year_mean.nc    -overwrite
done 

echo pk composite precipitation

# band 1 contain the minimum value and band 2 contain the file number that leter on will transform in year adding 2020
pkcomposite  -co  COMPRESS=LZW -co ZLEVEL=9   -of GTiff  -cr minband  -file 2  $( for band in $( seq 1 50) ; do  echo  -i  $RAM/${filename}_year_mean_band$band.vrt ; done ) -o  $RAM/${filename}_year_min2B.tif
rm  -f  $RAM/${filename}_year_mean_band*.vrt

echo invert left to right 

gdal_translate -ot Float32  -srcwin 0 0  360 360   -a_ullr    0 +90 180 -90     -co COMPRESS=LZW -co ZLEVEL=9      $RAM/${filename}_year_min2B.tif $RAM/${filename}_year_min_right.tif
gdal_translate -ot Float32  -srcwin 360 0  360 360 -a_ullr -180 +90 0 -90  -co COMPRESS=LZW -co ZLEVEL=9      $RAM/${filename}_year_min2B.tif $RAM/${filename}_year_min_left.tif

gdalbuildvrt  -a_srs EPSG:4326  -te -180 -90 180 +90  -tr 0.5 0.5 -b 1  $RAM/${filename}_year_min.vrt    $RAM/${filename}_year_min_right.tif $RAM/${filename}_year_min_left.tif  -overwrite
gdalbuildvrt  -a_srs EPSG:4326  -te -180 -90 180 +90  -tr 0.5 0.5 -b 2  $RAM/${filename}_year_minOBS.vrt $RAM/${filename}_year_min_right.tif $RAM/${filename}_year_min_left.tif  -overwrite

echo split the band in minimum and year observation 

gdal_translate -a_nodata -32768 -ot Float32 -of GTiff   -a_srs EPSG:4326 -a_ullr  -180 +90 +180 -90  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/${filename}_year_min.vrt      $DIR/piecewise/$dir/$par/${filename}_year_min.tif
gdal_translate -a_nodata -32768 -ot Int16   -of GTiff   -a_srs EPSG:4326 -a_ullr  -180 +90 +180 -90  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/${filename}_year_minOBS.vrt   $RAM/${filename}_year_minOBS.tif

gdal_calc.py --outfile=$RAM/${filename}_year_minOBSY.tif     -A    $RAM/${filename}_year_minOBS.tif  --calc="( A + 2020 )"  --overwrite  --type=Int16

mv $RAM/${filename}_year_minOBSY.tif $DIR/piecewise/$dir/$par/${filename}_year_minOBSY.tif

rm -f  $RAM/${filename}_year_min_right.tif  $RAM/${filename}_year_min_left.tif  $RAM/${filename}_year_min.vrt $RAM/${filename}_year_minOBS.vrt   $RAM/${filename}_year_minOBS.tif  $RAM/${filename}_year_min2B.tif     $RAM/${filename}_year_minOBSY.tif

# start here the Lili procedure 


cdo timmin   $RAM/${filename}_year_mean.nc  $RAM/${filename}_month_min.nc
cdo sub   $RAM/${filename}_year_mean.nc  $RAM/${filename}_month_min.nc  $RAM/${filename}_zeroPos.nc
cdo ifnotthen  $RAM/${filename}_zeroPos.nc  $RAM/${filename}_year_mean.nc  $RAM/${filename}_minTime.nc

# The file  $RAM/${filename}_minTime.nc contain for each leyer-year  the minimum values recorded in that year 

mv $RAM/${filename}_minTime.nc    $DIR/piecewise/$dir/$par/${filename}_minTime.nc 

' _ 

cleanram

# mean of the 3 model run

ls   $DIR/piecewise/*/*/*r?i1p1*_year_mean.nc  | xargs -n 3 -P 8  bash -c $' 

r1=$(basename $1 .nc )
r2=$(basename $2 .nc )
r3=$(basename $3 .nc )

dir=$(dirname  $1 )
mod=$( basename $( dirname   $dir) )
filename=$(echo $r1 | awk \'{ gsub ("r1i1p1" ,  "ensamble" ) ; print $0  }\')
ensamble=$( basename $filename .nc ) 

if [ ${ensamble:0:3} = "tas"   ] ; then par=${ensamble:0:3} ; fi 
if [ ${ensamble:0:3} = "pr_"   ] ; then par=${ensamble:0:2} ; fi 

# ensamble model

cdo ensmean   $dir/$r1.nc $dir/$r2.nc  $dir/$r3.nc $RAM/${ensamble}.nc
cp $RAM/${ensamble}.nc  $DIR/piecewise/$mod/$par/${ensamble}.nc

for band in $(seq 1 50) ; do
     echo vfr $band band 
     gdalbuildvrt   -b $band   $RAM/${ensamble}_year_mean_band$band.vrt   $RAM/${ensamble}.nc    -overwrite
done 

echo composite the minimum 
pkcomposite  -co  COMPRESS=LZW -co ZLEVEL=9   -of GTiff  -cr minband  -file 2  $( for band in $( seq 1 50) ; do  echo  -i  $RAM/${ensamble}_year_mean_band$band.vrt  ; done ) -o  $RAM/${r1}_year_min2B.tif
rm  -f     $RAM/${r1}_band$band.vrt    $RAM/${r2}_band$band.vrt   $RAM/${r3}_band$band.vrt

echo invert left to right 

gdal_translate -ot Float32  -srcwin 0 0  360 360   -a_ullr    0 +90 180 -90     -co COMPRESS=LZW -co ZLEVEL=9      $RAM/${r1}_year_min2B.tif $RAM/${r1}_year_min_right.tif
gdal_translate -ot Float32  -srcwin 360 0  360 360 -a_ullr -180 +90 0 -90  -co COMPRESS=LZW -co ZLEVEL=9      $RAM/${r1}_year_min2B.tif $RAM/${r1}_year_min_left.tif

gdalbuildvrt  -a_srs EPSG:4326  -te -180 -90 180 +90  -tr 0.5 0.5 -b 1  $RAM/${r1}_year_min.vrt    $RAM/${r1}_year_min_right.tif $RAM/${r1}_year_min_left.tif  -overwrite
gdalbuildvrt  -a_srs EPSG:4326  -te -180 -90 180 +90  -tr 0.5 0.5 -b 2  $RAM/${r1}_year_minOBS.vrt $RAM/${r1}_year_min_right.tif $RAM/${r1}_year_min_left.tif  -overwrite

echo split the band in minimum and year observation 

gdal_translate -a_nodata -32768 -ot Float32 -of GTiff   -a_srs EPSG:4326 -a_ullr  -180 +90 +180 -90  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/${r1}_year_min.vrt      $DIR/piecewise/$mod/$par/${ensamble}_year_min.tif
gdal_translate -a_nodata -32768 -ot Int16   -of GTiff   -a_srs EPSG:4326 -a_ullr  -180 +90 +180 -90  -co COMPRESS=LZW -co ZLEVEL=9  $RAM/${r1}_year_minOBS.vrt   $RAM/${r1}_year_minOBS.tif

gdal_calc.py --outfile=$RAM/${r1}_year_minOBSY.tif     -A    $RAM/${r1}_year_minOBS.tif  --calc="( A + 2020 )"  --overwrite  --type=Int16

mv $RAM/${r1}_year_minOBSY.tif $DIR/piecewise/$mod/$par/${ensamble}_year_minOBSY.tif

rm -f  $RAM/${r1}_year_min_right.tif  $RAM/${r1}_year_min_left.tif  $RAM/${r1}_year_min.vrt $RAM/${r1}_year_minOBS.vrt   $RAM/${r1}_year_minOBS.tif  $RAM/${r1}_year_min2B.tif     $RAM/${r1}_year_minOBSY.tif


' _ 

cleanram 

exit 

