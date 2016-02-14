
# Tue Nov 24 10:54:37 EST 2015
# sono stati tolti tutti i pkfilter solo per computatione variabili non e'stato fatto correre. 


# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
#  awk 'NR%4==1 {x="F"++i;}{ print >   "tiles4_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list

# for list in tiles8_listF*.txt; do qsub -v list=$list /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult.sh ; done

# for list  in  tiles8_listF3.txt  ; do bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult.sh   $list  ; done


#PBS -S /bin/bash 
#PBS -q fas_high
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

# form here only md will be used

INDIR=$INDIR_MD
mm=md

echo  slope with file   $INDIR/$filename.tif
gdaldem slope  -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/slope/tiles/${filename}_${mm}.tif  

# -s to consider xy in degree and z in meters

echo  aspect  with file   $INDIR/$filename.tif

gdaldem aspect  -zero_for_flat -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/aspect/tiles/${filename}_${mm}.tif

# r1 aspect , r2 slope 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" --overwrite --type=Float32


####
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/slope/tiles/${filename}_${mm}"_sin.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/slope/tiles/${filename}_${mm}"_cos.tif" --overwrite --type=Float32

#### sin   cos  Ew  Nw   median 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9 --co=PREDICTOR=3 --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" --overwrite --type=Float32

###############  VRM  ########################################

####
gdaldem  slope   -s 111120  -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR_MD/${filename}.tif   $OUTDIR/slope/tiles/${filename}_ct_tmp.tif
# cut the border
pkgetmask -ot Byte  -min -9990 -max 10000000  -co COMPRESS=LZW  -co ZLEVEL=9   -i $OUTDIR/slope/tiles/${filename}_ct_tmp.tif -o $RAM/${filename}_msk.tif
geo_string=$(oft-bb $RAM/${filename}_msk.tif  1   | grep BB | awk \'{ print    $6,$7,$8,$9   }\' )
xoff=$( echo $geo_string |  awk \'{  print $1 }\'   )
yoff=$( echo $geo_string | awk \'{  print $2 }\'   )
xsize=$(  echo $geo_string |  awk \'{  print $3 - $1 }\'   )
ysize=$(  echo $geo_string | awk \'{  print $4 - $2 }\'   )
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -srcwin  $xoff $yoff $xsize $ysize   $OUTDIR/slope/tiles/${filename}_ct_tmp.tif    $OUTDIR/slope/tiles/${filename}_ct.tif   
rm  $RAM/${filename}_msk.tif  $OUTDIR/slope/tiles/${filename}_ct_tmp.tif

gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9  --NoDataValue -9999 -A  $OUTDIR/slope/tiles/${filename}_ct.tif   --calc="(sin(A * 3.141592 / 180))" --outfile $OUTDIR/slope/tiles/${filename}_${mm}"_sin_ct.tif" --overwrite --type=Float32
gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9  --NoDataValue -9999 -A  $OUTDIR/slope/tiles/${filename}_ct.tif   --calc="(cos(A * 3.141592 / 180))" --outfile $OUTDIR/slope/tiles/${filename}_${mm}"_cos_ct.tif" --overwrite --type=Float32

echo slope 

gdaldem  aspect  -s 111120  -zero_for_flat    -co COMPRESS=LZW  -co ZLEVEL=9  $INDIR_MD/${filename}.tif   $OUTDIR/aspect/tiles/${filename}_ct_tmp.tif
# cut the border with the slope file 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -srcwin  $xoff $yoff $xsize $ysize   $OUTDIR/aspect/tiles/${filename}_ct_tmp.tif    $OUTDIR/aspect/tiles/${filename}_ct.tif   

# rm  $RAM/${filename}_msk.tif $OUTDIR/aspect/tiles/${filename}_ct_tmp.tif

gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9  --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_ct.tif --calc="(sin(A * 3.141592 / 180))" --outfile $OUTDIR/aspect/tiles/${filename}_${mm}"_sin_ct.tif" --overwrite --type=Float32
gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9  --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_ct.tif --calc="(cos(A * 3.141592 / 180))" --outfile $OUTDIR/aspect/tiles/${filename}_${mm}"_cos_ct.tif" --overwrite --type=Float32


###############  ${filename}_${mm}.tif
echo VRM ${filename}_${mm}.tif
#     A                  B             C                  A             D
# z=cos (slope )  x= sin(slope) * sin(aspect)   y =  sin(slope) * cos(aspect)   ;  | r | sqrt ( (sum x)^2  + (sum y)^2 + (sum z)^2  )  

echo z 
pkfilter -nodata -9999 -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9  -ot Float32   -i   $OUTDIR/slope/tiles/${filename}_${mm}"_cos_ct.tif" -o   $TMP/${filename}_${mm}"_sumz.tif" 

 
echo x 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A  $OUTDIR/slope/tiles/${filename}_${mm}"_sin_ct.tif"   -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_sin_ct.tif"  --calc="(A * B)" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_x.tif"

pkfilter -nodata -9999 -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Float32   -i   $TMP/${filename}_${mm}"_x.tif" -o   $TMP/${filename}_${mm}"_sumx.tif" 

echo y 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A  $OUTDIR/slope/tiles/${filename}_${mm}"_sin_ct.tif"   -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_cos_ct.tif"  --calc="(A * B)" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}"_y.tif"

pkfilter -nodata -9999 -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Float32   -i   $TMP/${filename}_${mm}"_y.tif" -o   $TMP/${filename}_${mm}"_sumy.tif" 

# vrm 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $TMP/${filename}_${mm}"_sumx.tif"  -B  $TMP/${filename}_${mm}"_sumy.tif"  -C  $TMP/${filename}_${mm}"_sumz.tif"  --calc="( 1 - ( (sqrt ( ( A * A ) + (B * B ) + ( C * C ) )) / 8 ) )" --type=Float32 --overwrite --outfile   $TMP/${filename}_${mm}".tif" 

rm -f  $TMP/${filename}_${mm}"_sumx.tif"   $TMP/${filename}_${mm}"_sumy.tif"   $TMP/${filename}_${mm}"_sumz.tif"
cp  $TMP/${filename}_${mm}".tif"  $OUTDIR/vrm/tiles/${filename}_${mm}".tif"


###############

echo  generate a Terrain Ruggedness Index TRI  with file   $file
gdaldem TRI -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND    $INDIR/$filename.tif  $OUTDIR/tri/tiles/${filename}_${mm}.tif

echo  generate a Topographic Position Index TPI  with file   $INDIR/$filename.tif

gdaldem TPI  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/tpi/tiles/${filename}_${mm}.tif

echo  generate roughness   with file   $INDIR/$filename.tif

gdaldem  roughness   -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=3 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/roughness/tiles/${filename}_${mm}.tif 

' _ 

checkjob -v $PBS_JOBID 

rm -f /dev/shm/* 