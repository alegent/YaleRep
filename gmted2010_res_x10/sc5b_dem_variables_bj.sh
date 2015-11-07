# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls *.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 

# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ; 


# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in `ls /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/md75_grd_tif/?_?.tif` ; do qsub  -v file=$file  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc5b_dem_variables_bj.sh ; done 

# for file in `ls /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/md75_grd_tif/?_?.tif` ; do bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc5b_dem_variables_bj.sh $file   ; done 
# file=$1   

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=5:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout/dem_var 
#PBS -e /lustre0/scratch/ga254/stderr/dem_var


# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

file=${file}

INDIR_MI=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/mi75_grd_tif
INDIR_MD=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/md75_grd_tif
INDIR_MX=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/mx75_grd_tif
INDIR_MN=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/mn75_grd_tif
TMP=/tmp

export OUTDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010

export filename=`basename $file .tif`

time ( 
# 30 min for this 
echo max of the max with file    $INDIR_MX/$filename.tif 
/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f max -d 4 -i $INDIR_MX/$filename.tif  -o $OUTDIR/altitude/max_of_mx/tiles/${filename}.tif  -co COMPRESS=LZW -ot Int16  

echo max of the max with file    $INDIR_MI/$filename.tif 
/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f min  -d 4 -i $INDIR_MI/$filename.tif -o $OUTDIR/altitude/min_of_mi/tiles/${filename}.tif  -co COMPRESS=LZW -ot Int16  

echo mean of the mn with file    $INDIR_MN/$filename.tif 
/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f mean  -d 4 -i $INDIR_MN/$filename.tif -o $OUTDIR/altitude/mean_of_mn/tiles/${filename}.tif  -co COMPRESS=LZW -ot Int16  

echo meadian of the md with file  $INDIR_MD/$filename.tif 
/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f median  -d 4 -i $INDIR_MD/$filename.tif -o $OUTDIR/altitude/median_of_md/tiles/${filename}.tif  -co COMPRESS=LZW -ot Int16  

echo stdev of mn with file $INDIR_MN/$filename.tif 

/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f var -d 4 -i $INDIR_MN/$filename.tif  -co COMPRESS=LZW  -o  $TMP/tmp_${filename}.tif  -ot Int32   # max 1552385.000 sqrt(1245.947)
gdal_calc.py  --co=COMPRESS=LZW    -A  $TMP/tmp_${filename}.tif   --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/altitude/stdev_of_mn/tiles/${filename}.tif
rm -f $TMP/tmp_${filename}.tif 

echo stdev of md with file $INDIR_MD/$filename.tif 

/home2/ga254/bin/pkfilter -nodata -32768 -dx 4 -dy 4   -f var -d 4 -i $INDIR_MD/$filename.tif  -co COMPRESS=LZW  -o  $TMP/tmp_${filename}.tif  -ot Int32   # max 1552385.000 sqrt(1245.947)
gdal_calc.py  --co=COMPRESS=LZW -A  $TMP/tmp_${filename}.tif   --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/altitude/stdev_of_md/tiles/${filename}.tif
rm -f $TMP/tmp_${filename}.tif 


# form here only md will be used

INDIR=$INDIR_MD
mm=md

# starting to use gdaldem to compute variables. Gdaldem use -9999 as no data. 

echo  slope with file   $INDIR/$filename.tif
gdaldem slope  -s 111120 -co COMPRESS=LZW   $INDIR/$filename.tif  $OUTDIR/slope/tiles/${filename}_${mm}.tif  # -s to consider xy in degree and z in meters
# slope median 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median  -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o $OUTDIR/slope/median/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Byte
# slope stdev 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif  -co COMPRESS=LZW  -o $TMP/tmp_${filename}_${mm}.tif  -ot Int32
gdal_calc.py  --co=COMPRESS=LZW -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/slope/stdev/tiles/${filename}_${mm}.tif
rm -f $TMP/tmp_${filename}_${mm}.tif
# slope min 
/home2/ga254/bin/pkfilter -nodata -9999  -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/min/tiles/${filename}_${mm}.tif -co COMPRESS=LZW   -ot Byte 
# slope max
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/max/tiles/${filename}_${mm}.tif -co COMPRESS=LZW   -ot Byte 
# slope mean
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/mean/tiles/${filename}_${mm}.tif -co COMPRESS=LZW  -ot Byte 

# rm -f  $OUTDIR/slope/tiles/$filename.tif


##########################################################################################

echo  generate a Terrain Ruggedness Index TRI  with file   $file
gdaldem TRI  -co COMPRESS=LZW   $INDIR/$filename.tif  $OUTDIR/tri/tiles/${filename}_${mm}.tif
# tri median 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o $OUTDIR/tri/median/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16
# tri stdev 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4    -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -co COMPRESS=LZW  -o  $TMP/tmp_${filename}_${mm}.tif
gdal_calc.py  --co=COMPRESS=LZW -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type Int16 --overwrite --outfile $OUTDIR/tri/stdev/tiles/${filename}_${mm}.tif
rm -f  $TMP/tmp_${filename}_${mm}.tif
# tri min 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/min/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16  
# tri max
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/max/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16
# tri mean
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/mean/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16

# rm -f  $OUTDIR/tri/tiles/$filename.tif

echo  generate a Topographic Position Index TPI  with file   $INDIR/$filename.tif

gdaldem TPI  -co COMPRESS=LZW   $INDIR/$filename.tif  $OUTDIR/tpi/tiles/${filename}_${mm}.tif      # tpi has negative number 

/home2/ga254/bin/oft-calc -ot Float32   $OUTDIR/tri/tiles/${filename}_${mm}.tif $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"    &> /dev/null   <<EOF
1
#1 10 *
EOF

# tpi median 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"  -o $OUTDIR/tpi/median/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16
echo tpi stdev 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"  -co COMPRESS=LZW    -o $TMP/tmp_${filename}_${mm}.tif 
gdal_calc.py  --co=COMPRESS=LZW -A  $TMP/tmp_${filename}_${mm}.tif  --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/tpi/stdev/tiles/${filename}_${mm}.tif
rm -f  $TMP/tmp_${filename}_${mm}.tif
# tpi min 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4  -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/min/tiles/${filename}_${mm}.tif   -co COMPRESS=LZW -ot Int16
# tpi max
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4  -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/max/tiles/${filename}_${mm}.tif   -co COMPRESS=LZW -ot Int16
# tpi mean
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/mean/tiles/${filename}_${mm}.tif  -co COMPRESS=LZW -ot Int16

echo  generate roughness   with file   $INDIR/$filename.tif

gdaldem  roughness  -co COMPRESS=LZW   $INDIR/$filename.tif  $OUTDIR/roughness/tiles/${filename}_${mm}.tif

# roughness median 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/median/tiles/${filename}_${mm}.tif -co COMPRESS=LZW -ot Int16
echo roughness stdev 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var  -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -co COMPRESS=LZW  -o $TMP/tmp_${filename}_${mm}.tif  
gdal_calc.py  --co=COMPRESS=LZW -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type Int32 --overwrite --outfile $OUTDIR/roughness/stdev/tiles/${filename}_${mm}.tif
rm -f  $TMP/tmp_${filename}_${mm}.tif
# roughness min 
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/min/tiles/${filename}_${mm}.tif    -co COMPRESS=LZW -ot Int16
# roughness max
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/max/tiles/${filename}_${mm}.tif    -co COMPRESS=LZW -ot Int16
# roughness mean
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/mean/tiles/${filename}_${mm}.tif  -co COMPRESS=LZW -ot Int16

# rm -f   $OUTDIR/roughness/tiles/${filename}_${mm}.tif

echo  aspect  with file   $INDIR/$filename.tif

gdaldem aspect  -zero_for_flat -co COMPRESS=LZW   $INDIR/$filename.tif  $OUTDIR/aspect/tiles/${filename}_${mm}.tif

# r1 aspect , r2 slope 

gdal_calc.py  --co=COMPRESS=LZW --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" --overwrite --type Float32
gdal_calc.py  --co=COMPRESS=LZW --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" --overwrite --type Float32

gdal_calc.py  --co=COMPRESS=LZW --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" --overwrite --type Float32
gdal_calc.py  --co=COMPRESS=LZW --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" --overwrite --type Float32

echo  aspect sin   cos  Ew  Nw   median 
# sin
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"  &> /dev/null    <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_f.tif"  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_f.tif"  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16  $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_f.tif"  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 


echo aspect sin   cos  Ew  Nw   mean
# sin
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_f.tif"  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_f.tif"  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16  $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_f.tif"  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   max
# sin
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16  $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"   &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16 $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16  $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_f.tif"   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_f.tif"   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_f.tif"   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   min 
# sin
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_f.tif"   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc  -ot Int16   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_f.tif"   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_f.tif"   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
/home2/ga254/bin/oft-calc -ot Int16   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_f.tif"   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   stdev
# stdev   
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py  --co=COMPRESS=LZW -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py  --co=COMPRESS=LZW -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py  --co=COMPRESS=LZW -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
/home2/ga254/bin/pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=LZW -ot Float32
gdal_calc.py  --co=COMPRESS=LZW -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_f.tif"  --calc="(sqrt(A))*10000" --type Int16 --overwrite --outfile   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"
gdal_translate  -co COMPRESS=LZW  -ot Int16   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

# Look for lines such as "Max Util Resources Per Task" in the output file from your job.  


)

checkjob -v $PBS_JOBID 
