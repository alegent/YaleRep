# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html#gdaldem_slope 
# to check ls tif/Smoothed*.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 


# find /mnt/data2/dem_variables/{altitude,aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ; 

# ls /mnt/data/jetzlab/Data/environ/global/dem/tiles/Smoothed_*.bil | xargs -n 1 -P 12 bash  /mnt/data2/dem_variables/scripts/sc1_dem_variables.sh

# scandinavia 
# ls /mnt/data/jetzlab/Data/environ/global/dem/tiles/Smoothed_N{55,60,65,70}E0{05,10,15,20,25,30}.bil | xargs -n 1 -P 12 bash /mnt/data2/dem_variables/scripts/sc1_dem_variables.sh

export OUTDIR=/mnt/data2/dem_variables
export file=$1
export filename=`basename $file .bil` 

(

# gdal_translate -ot Int16  -co COMPRESS=LZW  $file $OUTDIR/tif/$filename.tif

echo altitude variables with file    $OUTDIR/tif/$filename.tif

# # median 
# pkfilter -m -32768   -dx 10 -dy 10   -f median -d 10 -i  $OUTDIR/tif/$filename.tif    -o  $OUTDIR/altitude/median/tiles/$filename.tif     -co COMPRESS=LZW -ot Int16  
# # stdev
# pkfilter -m -32768 -dx 10 -dy 10   -f var -d 10 -i $OUTDIR/tif/$filename.tif   -o  $OUTDIR/altitude/stdev/tiles/tmp_$filename.tif  -co COMPRESS=LZW -ot Int32   # max 1552385.000 sqrt(1245.947)
# gdal_calc.py -A  $OUTDIR/altitude/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/altitude/stdev/tiles/$filename.tif
# rm -f   $OUTDIR/altitude/stdev/tiles/tmp_$filename
# # min 
# pkfilter -m -32768  -dx 10 -dy 10   -f min -d 10 -i $OUTDIR/tif/$filename.tif   -o  $OUTDIR/altitude/min/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16  
# # max
# pkfilter -m -32768 -dx 10 -dy 10   -f max -d 10 -i $OUTDIR/tif/$filename.tif   -o  $OUTDIR/altitude/max/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16  
# # mean
# pkfilter -m -32768 -dx 10 -dy 10   -f mean -d 10 -i $OUTDIR/tif/$filename.tif   -o  $OUTDIR/altitude/mean/tiles/$filename.tif  -co COMPRESS=LZW  -ot Int16  

# # starting to use gdaldem to compute variables. Gdaldem use -9999 as no data. 

# echo  slope with file   $OUTDIR/tif/$filename.tif
# gdaldem slope  -s 111120 -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/slope/tiles/$filename.tif  # -s to consider xy in degree and z in meters
# # slope median 
# pkfilter -m -9999 -dx 10 -dy 10 -f median  -d 10 -i $OUTDIR/slope/tiles/$filename.tif -o $OUTDIR/slope/median/tiles/$filename.tif -co COMPRESS=LZW -ot Byte
# # slope stdev 
# pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW -ot Int32
# gdal_calc.py -A  $OUTDIR/slope/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/slope/stdev/tiles/$filename.tif
# rm -f  $OUTDIR/slope/stdev/tiles/tmp_$filename
# # slope min 
# pkfilter -m -9999  -dx 10 -dy 10 -f min -d 10 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/min/tiles/$filename.tif -co COMPRESS=LZW   -ot Byte 
# # slope max
# pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/max/tiles/$filename.tif -co COMPRESS=LZW   -ot Byte 
# # slope mean
# pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i $OUTDIR/slope/tiles/$filename.tif -o  $OUTDIR/slope/mean/tiles/$filename.tif -co COMPRESS=LZW  -ot Byte 

# rm -f  $OUTDIR/slope/tiles/$filename.tif

# echo  generate a Terrain Ruggedness Index TRI  with file   $file
# gdaldem TRI  -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/tri/tiles/$filename.tif
# # tri median 
# pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i $OUTDIR/tri/tiles/$filename.tif -o $OUTDIR/tri/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16  
# # tri stdev 
# pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
# gdal_calc.py -A  $OUTDIR/tri/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/tri/stdev/tiles/$filename.tif
# rm -f  $OUTDIR/tri/stdev/tiles/tmp_$filename
# # tri min 
# pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/min/tiles/$filename.tif -co COMPRESS=LZW -ot Int16  
# # tri max
# pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/max/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
# # tri mean
# pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i $OUTDIR/tri/tiles/$filename.tif -o  $OUTDIR/tri/mean/tiles/$filename.tif -co COMPRESS=LZW -ot Int16

# rm -f  $OUTDIR/tri/tiles/$filename.tif


echo  generate a Topographic Position Index TPI  with file   $OUTDIR/tif/$filename.tif
# gdaldem TPI  -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/tpi/tiles/$filename.tif       # tpi has negative number 

oft-calc -ot Float32   $OUTDIR/tpi/tiles/$filename.tif $OUTDIR/tpi/tiles/$filename"_t10.tif"  &> /dev/null    <<EOF
1
#1 10 *
EOF

# tpi median 
pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i $OUTDIR/tpi/tiles/$filename"_t10.tif"  -o $OUTDIR/tpi/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
echo tpi stdev 
pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i $OUTDIR/tpi/tiles/$filename"_t10.tif"  -o $OUTDIR/tpi/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
gdal_calc.py -A  $OUTDIR/tpi/stdev/tiles/tmp_$filename.tif  --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/tpi/stdev/tiles/$filename.tif
rm -f  $OUTDIR/tpi/stdev/tiles/tmp_$filename
# tpi min 
pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10  -i $OUTDIR/tpi/tiles/$filename"_t10.tif" -o $OUTDIR/tpi/min/tiles/$filename.tif   -co COMPRESS=LZW -ot Int16
# tpi max
pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10  -i $OUTDIR/tpi/tiles/$filename"_t10.tif" -o $OUTDIR/tpi/max/tiles/$filename.tif   -co COMPRESS=LZW -ot Int16
# tpi mean
pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i $OUTDIR/tpi/tiles/$filename"_t10.tif" -o $OUTDIR/tpi/mean/tiles/$filename.tif  -co COMPRESS=LZW -ot Int16





# echo  generate roughness   with file   $OUTDIR/tif/$filename.tif

# gdaldem  roughness  -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/roughness/tiles/$filename.tif

# # roughness median 
# pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/median/tiles/$filename.tif -co COMPRESS=LZW -ot Int16
# echo roughness stdev 
# pkfilter -m -9999 -dx 10 -dy 10 -f var  -d 10 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/stdev/tiles/tmp_$filename.tif -co COMPRESS=LZW 
# gdal_calc.py -A  $OUTDIR/roughness/stdev/tiles/tmp_$filename.tif --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/roughness/stdev/tiles/$filename.tif

# rm -f  $OUTDIR/roughness/stdev/tiles/tmp_$filename

# # roughness min 
# pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/min/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# # roughness max
# pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/max/tiles/$filename.tif    -co COMPRESS=LZW -ot Int16
# # roughness mean
# pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i $OUTDIR/roughness/tiles/$filename.tif -o $OUTDIR/roughness/mean/tiles/$filename.tif  -co COMPRESS=LZW -ot Int16

# rm -f   $OUTDIR/roughness/tiles/$filename.tif



echo  aspect  with file   $OUTDIR/tif/$filename.tif

gdaldem aspect  -zero_for_flat -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/aspect/tiles/$filename.tif

# r1 aspect , r2 slope 

gdal_calc.py --NoDataValue -9999 -A $OUTDIR/aspect/tiles/$filename.tif --calc="(sin(A))" --outfile   $OUTDIR/aspect/tiles/$filename"_sin.tif" --overwrite --type Float32
gdal_calc.py --NoDataValue -9999 -A $OUTDIR/aspect/tiles/$filename.tif --calc="(cos(A))" --outfile   $OUTDIR/aspect/tiles/$filename"_cos.tif" --overwrite --type Float32

gdal_calc.py --NoDataValue -9999 -A $OUTDIR/slope/tiles/$filename.tif -B  $OUTDIR/aspect/tiles/$filename"_sin.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/$filename"_Ew.tif" --overwrite --type Float32
gdal_calc.py --NoDataValue -9999 -A $OUTDIR/slope/tiles/$filename.tif -B  $OUTDIR/aspect/tiles/$filename"_cos.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/$filename"_Nw.tif" --overwrite --type Float32

echo  aspect sin   cos  Ew  Nw   median 
# sin
pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i   $OUTDIR/aspect/tiles/$filename"_sin.tif" -o   $OUTDIR/aspect/median/tiles/$filename"_sin_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/median/tiles/$filename"_sin_f.tif"  $OUTDIR/aspect/median/tiles/$filename"_sin_t10k_tmp.tif"  &> /dev/null    <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/median/tiles/$filename"_sin_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/$filename"_sin_t10k.tif"  
rm  $OUTDIR/aspect/median/tiles/$filename"_sin_t10k_tmp.tif" 
# cos
pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i   $OUTDIR/aspect/tiles/$filename"_cos.tif" -o   $OUTDIR/aspect/median/tiles/$filename"_cos_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16   $OUTDIR/aspect/median/tiles/$filename"_cos_f.tif"  $OUTDIR/aspect/median/tiles/$filename"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/median/tiles/$filename"_cos_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/$filename"_cos_t10k.tif" 
rm  $OUTDIR/aspect/median/tiles/$filename"_cos_t10k_tmp.tif" 
# Ew
pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Ew.tif" -o   $OUTDIR/aspect/median/tiles/$filename"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/median/tiles/$filename"_Ew_f.tif"  $OUTDIR/aspect/median/tiles/$filename"_Ew_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/median/tiles/$filename"_Ew_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/$filename"_Ew_t10k.tif" 
rm  $OUTDIR/aspect/median/tiles/$filename"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -m -9999 -dx 10 -dy 10 -f median -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Nw.tif" -o   $OUTDIR/aspect/median/tiles/$filename"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16  $OUTDIR/aspect/median/tiles/$filename"_Nw_f.tif"  $OUTDIR/aspect/median/tiles/$filename"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/median/tiles/$filename"_Nw_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/$filename"_Nw_t10k.tif" 
rm  $OUTDIR/aspect/median/tiles/$filename"_Nw_t10k_tmp.tif" 


echo aspect sin   cos  Ew  Nw   mean
# sin
pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i   $OUTDIR/aspect/tiles/$filename"_sin.tif" -o   $OUTDIR/aspect/mean/tiles/$filename"_sin_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/$filename"_sin_f.tif"  $OUTDIR/aspect/mean/tiles/$filename"_sin_t10k_tmp.tif" &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/mean/tiles/$filename"_sin_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/$filename"_sin_t10k.tif"  
rm  $OUTDIR/aspect/mean/tiles/$filename"_sin_t10k_tmp.tif" 
# cos
pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i   $OUTDIR/aspect/tiles/$filename"_cos.tif" -o   $OUTDIR/aspect/mean/tiles/$filename"_cos_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/$filename"_cos_f.tif"  $OUTDIR/aspect/mean/tiles/$filename"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/mean/tiles/$filename"_cos_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/$filename"_cos_t10k.tif" 
rm  $OUTDIR/aspect/mean/tiles/$filename"_cos_t10k_tmp.tif" 
# Ew
pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Ew.tif" -o   $OUTDIR/aspect/mean/tiles/$filename"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/$filename"_Ew_f.tif"  $OUTDIR/aspect/mean/tiles/$filename"_Ew_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/mean/tiles/$filename"_Ew_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/$filename"_Ew_t10k.tif" 
rm  $OUTDIR/aspect/mean/tiles/$filename"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -m -9999 -dx 10 -dy 10 -f mean -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Nw.tif" -o   $OUTDIR/aspect/mean/tiles/$filename"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16  $OUTDIR/aspect/mean/tiles/$filename"_Nw_f.tif"  $OUTDIR/aspect/mean/tiles/$filename"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/mean/tiles/$filename"_Nw_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/$filename"_Nw_t10k.tif" 
rm  $OUTDIR/aspect/mean/tiles/$filename"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   max
# sin
pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i   $OUTDIR/aspect/tiles/$filename"_sin.tif" -o   $OUTDIR/aspect/max/tiles/$filename"_sin_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_sin_f.tif"  $OUTDIR/aspect/max/tiles/$filename"_sin_t10k_tmp.tif"   &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_sin_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/$filename"_sin_t10k.tif"  
rm  $OUTDIR/aspect/max/tiles/$filename"_sin_t10k_tmp.tif" 
# cos
pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i   $OUTDIR/aspect/tiles/$filename"_cos.tif" -o   $OUTDIR/aspect/max/tiles/$filename"_cos_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_cos_f.tif"  $OUTDIR/aspect/max/tiles/$filename"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_cos_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/$filename"_cos_t10k.tif" 
rm  $OUTDIR/aspect/max/tiles/$filename"_cos_t10k_tmp.tif" 
# Ew
pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Ew.tif" -o   $OUTDIR/aspect/max/tiles/$filename"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16   $OUTDIR/aspect/max/tiles/$filename"_Ew_f.tif"  $OUTDIR/aspect/max/tiles/$filename"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_Ew_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/$filename"_Ew_t10k.tif" 
rm  $OUTDIR/aspect/max/tiles/$filename"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -m -9999 -dx 10 -dy 10 -f max -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Nw.tif" -o   $OUTDIR/aspect/max/tiles/$filename"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16   $OUTDIR/aspect/max/tiles/$filename"_Nw_f.tif"  $OUTDIR/aspect/max/tiles/$filename"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/max/tiles/$filename"_Nw_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/$filename"_Nw_t10k.tif" 
rm  $OUTDIR/aspect/max/tiles/$filename"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   min 
# sin
pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i   $OUTDIR/aspect/tiles/$filename"_sin.tif" -o   $OUTDIR/aspect/min/tiles/$filename"_sin_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16   $OUTDIR/aspect/min/tiles/$filename"_sin_f.tif"  $OUTDIR/aspect/min/tiles/$filename"_sin_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/min/tiles/$filename"_sin_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/$filename"_sin_t10k.tif"  
rm  $OUTDIR/aspect/min/tiles/$filename"_sin_t10k_tmp.tif" 
# cos
pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i   $OUTDIR/aspect/tiles/$filename"_cos.tif" -o   $OUTDIR/aspect/min/tiles/$filename"_cos_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc  -ot Int16   $OUTDIR/aspect/min/tiles/$filename"_cos_f.tif"  $OUTDIR/aspect/min/tiles/$filename"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/min/tiles/$filename"_cos_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/$filename"_cos_t10k.tif" 
rm  $OUTDIR/aspect/min/tiles/$filename"_cos_t10k_tmp.tif" 
# Ew
pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Ew.tif" -o   $OUTDIR/aspect/min/tiles/$filename"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/min/tiles/$filename"_Ew_f.tif"  $OUTDIR/aspect/min/tiles/$filename"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/min/tiles/$filename"_Ew_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/$filename"_Ew_t10k.tif" 
rm  $OUTDIR/aspect/min/tiles/$filename"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -m -9999 -dx 10 -dy 10 -f min -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Nw.tif" -o   $OUTDIR/aspect/min/tiles/$filename"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
oft-calc -ot Int16   $OUTDIR/aspect/min/tiles/$filename"_Nw_f.tif"  $OUTDIR/aspect/min/tiles/$filename"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/min/tiles/$filename"_Nw_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/$filename"_Nw_t10k.tif" 
rm  $OUTDIR/aspect/min/tiles/$filename"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   stdev
# stdev   
pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i   $OUTDIR/aspect/tiles/$filename"_sin.tif" -o   $OUTDIR/aspect/stdev/tiles/$filename"_sin_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py -A  $OUTDIR/aspect/stdev/tiles/$filename"_sin_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile  $OUTDIR/aspect/stdev/tiles/$filename"_sin_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/stdev/tiles/$filename"_sin_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/$filename"_sin_t10k.tif"  
rm  $OUTDIR/aspect/stdev/tiles/$filename"_sin_t10k_tmp.tif" 
# cos
pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i   $OUTDIR/aspect/tiles/$filename"_cos.tif" -o   $OUTDIR/aspect/stdev/tiles/$filename"_cos_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py -A  $OUTDIR/aspect/stdev/tiles/$filename"_cos_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile  $OUTDIR/aspect/stdev/tiles/$filename"_cos_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/stdev/tiles/$filename"_cos_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/$filename"_cos_t10k.tif" 
rm  $OUTDIR/aspect/stdev/tiles/$filename"_cos_t10k_tmp.tif" 
# Ew
pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Ew.tif" -o   $OUTDIR/aspect/stdev/tiles/$filename"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py -A  $OUTDIR/aspect/stdev/tiles/$filename"_Ew_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile  $OUTDIR/aspect/stdev/tiles/$filename"_Ew_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/stdev/tiles/$filename"_Ew_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/$filename"_Ew_t10k.tif" 
rm  $OUTDIR/aspect/stdev/tiles/$filename"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -m -9999 -dx 10 -dy 10 -f var -d 10 -i   $OUTDIR/aspect/tiles/$filename"_Nw.tif" -o   $OUTDIR/aspect/stdev/tiles/$filename"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py -A  $OUTDIR/aspect/stdev/tiles/$filename"_Nw_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile  $OUTDIR/aspect/stdev/tiles/$filename"_Nw_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16  $OUTDIR/aspect/stdev/tiles/$filename"_Nw_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/$filename"_Nw_t10k.tif" 
rm  $OUTDIR/aspect/stdev/tiles/$filename"_Nw_t10k_tmp.tif" 

) 2>&1 | tee   /mnt/data2/dem_variables/log.txt
