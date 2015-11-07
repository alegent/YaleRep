# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
#  awk 'NR%4==1 {x="F"++i;}{ print >   "tiles4_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list

# for list in tiles8_listF*.txt; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float.sh ; done

# for list  in  tiles8_listF3.txt  ; do bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float.sh $list  ; done

# for file in `ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/?_?.tif` ; do qsub  -v file=$file  /lustre/home/clien/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_bj_slope.sh  ; done                                                                       

# for file in `ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/?_?.tif` ; do bash  /lustre/home/client/fas/sbsc/ga254\scripts/gmted2010_res_x10/sc5b_dem_variables_bj_slope.sh  ; done

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# list=$1

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list/$list | xargs -n 1 -P 8  bash -c $' 

INDIR_MI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mi75_grd_tif
INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
INDIR_MX=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mx75_grd_tif
INDIR_MN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mn75_grd_tif
TMP=/dev/shm

export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
export filename=$(basename $1 .tif)

# 30 min for this 
echo max of the max with file    $INDIR_MX/$filename.tif 

pkfilter -nodata -32768 -dx 4 -dy 4   -f max -d 4 -i $INDIR_MX/$filename.tif  -o $OUTDIR/altitude/max_of_mx/tiles/${filename}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32  

echo max of the max with file    $INDIR_MI/$filename.tif 
pkfilter -nodata -32768 -dx 4 -dy 4   -f min  -d 4 -i $INDIR_MI/$filename.tif -o $OUTDIR/altitude/min_of_mi/tiles/${filename}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32  

echo mean of the mn with file    $INDIR_MN/$filename.tif 
pkfilter -nodata -32768 -dx 4 -dy 4   -f mean  -d 4 -i $INDIR_MN/$filename.tif -o $OUTDIR/altitude/mean_of_mn/tiles/${filename}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32  

echo meadian of the md with file  $INDIR_MD/$filename.tif 
pkfilter -nodata -32768 -dx 4 -dy 4   -f median  -d 4 -i $INDIR_MD/$filename.tif -o $OUTDIR/altitude/median_of_md/tiles/${filename}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32  

echo stdev of mn with file $INDIR_MN/$filename.tif 

pkfilter -nodata -32768 -dx 4 -dy 4   -f var -d 4 -i $INDIR_MN/$filename.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -o  $TMP/tmp_${filename}.tif  -ot Float32    # max 1552385.000 sqrt(1245.947)
gdal_calc.py   --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND    -A  $TMP/tmp_${filename}.tif   --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/altitude/stdev_of_mn/tiles/${filename}.tif
rm -f $TMP/tmp_${filename}.tif 

echo stdev of md with file $INDIR_MD/$filename.tif 

pkfilter -nodata -32768 -dx 4 -dy 4   -f var -d 4 -i $INDIR_MD/$filename.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -o  $TMP/tmp_${filename}.tif  -ot Float32    # max 1552385.000 sqrt(1245.947)
gdal_calc.py   --NoDataValue=-9999  --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $TMP/tmp_${filename}.tif   --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/altitude/stdev_of_md/tiles/${filename}.tif
rm -f $TMP/tmp_${filename}.tif 


# form here only md will be used

INDIR=$INDIR_MD
mm=md

echo  slope with file   $INDIR/$filename.tif
gdaldem slope  -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/slope/tiles/${filename}_${mm}.tif  
# -s to consider xy in degree and z in meters

# slope median     max value 83.107  
pkfilter -nodata -9999 -dx 4 -dy 4 -f median  -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o $OUTDIR/slope/median/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32

# slope stdev 
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -o $TMP/tmp_${filename}_${mm}.tif  -ot Float32
gdal_calc.py  --NoDataValue=-9999   --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type=Float32  --overwrite --outfile $OUTDIR/slope/stdev/tiles/${filename}_${mm}.tif
rm -f $TMP/tmp_${filename}_${mm}.tif

# slope min 
pkfilter -nodata -9999  -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/min/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   -ot Float32 

# slope max
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/max/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   -ot Float32

# slope mean
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/slope/tiles/${filename}_${mm}.tif -o  $OUTDIR/slope/mean/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

# rm -f  $OUTDIR/slope/tiles/$filename.tif

echo  aspect  with file   $INDIR/$filename.tif

gdaldem aspect  -zero_for_flat -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/aspect/tiles/${filename}_${mm}.tif

# r1 aspect , r2 slope 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" --overwrite --type=Float32

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" --overwrite --type=Float32

echo  aspect sin   cos  Ew  Nw   median 
# sin
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"  &> /dev/null    <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_f.tif"  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_f.tif"  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32  $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_f.tif"  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/median/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 


echo aspect sin   cos  Ew  Nw   mean
# sin
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_f.tif"  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm  $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_f.tif"  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32  $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_f.tif"  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/mean/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm  $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   max
# sin
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32  $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_f.tif"  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"   &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32 $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32  $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_f.tif"   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_f.tif"   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32   $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_f.tif"   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/max/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   min 
# sin
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_f.tif"   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc  -ot Float32   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_f.tif"   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"  &> /dev/null  <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_f.tif"   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
oft-calc -ot Float32   $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_f.tif"   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"  &> /dev/null   <<EOF
1
#1 10000 *
EOF
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/min/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo aspect sin   cos  Ew  Nw   stdev
# stdev   
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_f.tif"  --calc="(sqrt(A))*10000" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif"
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32  $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_sin_t10k.tif"  
rm   $TMP/${filename}_${mm}"_sin_t10k_tmp.tif" 
# cos
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_f.tif"  --calc="(sqrt(A))*10000" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif"
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_cos_t10k.tif" 
rm   $TMP/${filename}_${mm}"_cos_t10k_tmp.tif" 
# Ew
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_f.tif"  --calc="(sqrt(A))*10000" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif"
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Ew_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Ew_t10k_tmp.tif" 
# Nw
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" -o   $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_f.tif" -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_f.tif"  --calc="(sqrt(A))*10000" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif"
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" $OUTDIR/aspect/stdev/tiles/${filename}_${mm}"_Nw_t10k.tif" 
rm   $TMP/${filename}_${mm}"_Nw_t10k_tmp.tif" 

echo  generate a Terrain Ruggedness Index TRI  with file   $file
gdaldem TRI -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND    $INDIR/$filename.tif  $OUTDIR/tri/tiles/${filename}_${mm}.tif

# tri median 
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o $OUTDIR/tri/median/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32

# tri stdev 
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4    -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   -o  $TMP/tmp_${filename}_${mm}.tif
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/tri/stdev/tiles/${filename}_${mm}.tif

rm -f  $TMP/tmp_${filename}_${mm}.tif

# tri min                                                                                                                                             
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/min/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND

# tri max
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/max/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32

# tri mean
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/tri/tiles/${filename}_${mm}.tif -o  $OUTDIR/tri/mean/tiles/${filename}_${mm}.tif -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32

# rm -f  $OUTDIR/tri/tiles/$filename.tif

echo  generate a Topographic Position Index TPI  with file   $INDIR/$filename.tif

gdaldem TPI  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/tpi/tiles/${filename}_${mm}.tif
# tpi has negative number
 
oft-calc -ot Float32   $OUTDIR/tri/tiles/${filename}_${mm}.tif $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"    &> /dev/null   <<EOF
1
#1 10 *
EOF

# tpi median
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"  -o $OUTDIR/tpi/median/tiles/${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND -ot Float32

echo tpi stdev
pkfilter -nodata -9999 -dx 4 -dy 4 -f var -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif"   -o $TMP/tmp_${filename}_${mm}.tif 
gdal_calc.py  --NoDataValue=-9999  --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND   -A  $TMP/tmp_${filename}_${mm}.tif  --calc="sqrt(A)" --type=Float32  --overwrite --outfile $OUTDIR/tpi/stdev/tiles/${filename}_${mm}.tif

rm -f  $TMP/tmp_${filename}_${mm}.tif
# tpi min 
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4  -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/min/tiles/${filename} _${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND    -ot Float32

# tpi max
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4  -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/max/tiles/${filename} _${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

# tpi mean
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/tpi/tiles/${filename}_${mm}"_t10.tif" -o $OUTDIR/tpi/mean/tiles/${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

echo  generate roughness   with file   $INDIR/$filename.tif

gdaldem  roughness   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/roughness/tiles/${filename}_${mm}.tif 

# roughness median                        
pkfilter -nodata -9999 -dx 4 -dy 4 -f median -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/median/tiles/${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

echo roughness stdev
pkfilter -nodata -9999 -dx 4 -dy 4 -f var  -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -co COMPRESS=LZW  -o $TMP/tmp_${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

gdal_calc.py   --NoDataValue=-9999  --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND  -A  $TMP/tmp_${filename}_${mm}.tif --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/roughness/stdev/tiles/${filename}_${mm}.tif

rm -f  $TMP/tmp_${filename}_${mm}.tif

# roughness min
pkfilter -nodata -9999 -dx 4 -dy 4 -f min -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/min/tiles/${file\
name}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

# roughness max                       
pkfilter -nodata -9999 -dx 4 -dy 4 -f max -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/max/tiles/${filename}_${mm}.tif   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32

# roughness mean
pkfilter -nodata -9999 -dx 4 -dy 4 -f mean -d 4 -i $OUTDIR/roughness/tiles/${filename}_${mm}.tif -o $OUTDIR/roughness/mean/tiles/${filename}_${mm}.tif  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND  -ot Float32


' _ 

checkjob -v $PBS_JOBID 

rm -f /dev/shm/* 