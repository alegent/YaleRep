# for list in /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/list/tiles8_list12000F*.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc2a_dem_variables_float_noMult_vrmgrass.sh    ; done 

# 16 hour for all the variables

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# list=$1

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
export RAM=/dev/shm
export list=$list


# the first and second tiles 

# than only ones
#                                                 872 files
# gdalbuildvrt   -overwrite  $INDIR/all_tif.vrt   $INDIR/*.tif 

# Size is 432001 144001
# Pixel Size = (0.000833333333333, -0.000833333333333)
# Upper Left  (-180.0004167,  60.0004172)
# Lower Left  (-180.0004167, -60.0004162)
# Upper Right ( 180.0004166,  60.0004172)
# Lower Right ( 180.0004166, -60.0004162)
# NoData Value=-32768    ( sea ) 

# cut  1 pixel at the end
# gdal_translate  -of VRT  -a_ullr   -180 +60 +180 -60  -srcwin 0 0 432000 144000  $INDIR/all_tif.vrt    $INDIR/all_tif_cut.vrt  

# Size is 432000, 144000 
#       x =   72 *  6000   y = 24 *  6000 
#       x =   36 * 12000   y = 12 * 12000 

# build up the new tiles sistem 
#  for xn in $(seq 0 35 ) ; do  for yn in $(seq 0 11 ) ; do echo $( expr $xn \* 12000 ) $( expr $yn \* 12000 ) 12000 12000   ; done ; done  > /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/tiles_12000.txt 

# cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/tiles_12000.txt   | xargs -n 4  -P 8 bash -c $'  

# gdal_translate -of VRT  -srcwin $1 $2 12000 12000    $INDIR/all_tif_cut.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/tiles_${1}_${2}.vrt 
# max=$(pkstat -max  -i  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/tiles_${1}_${2}.vrt | awk \' { print $2  }\') 
# if  [ $max -eq -32768 ] ; then rm -f   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/tiles_${1}_${2}.vrt ; fi 
# ' _ 
# gdaltindex  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/srtm_tiles.shp  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/*.vrt 

# ls  *.vrt >   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/tiles_12000.txt 
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file 
# awk 'NR%8==1 {x="F"++i;}{ print >  "tiles8_list12000"x".txt" }' tiles_12000.txt 

cat $list  | xargs -n 1 -P 8  bash -c $' 

file=$1
filename=$(basename $file .vrt )

# take the coridinates from the orginal files and increment on 1 pixels
# ulx=$(gdalinfo $INDIR/vrt/$file | grep "Upper Left"  | awk \'{ gsub ("[(),]","") ; printf ("%.16f"  $3  -  0.000833333333333 ) }\')
# uly=$(gdalinfo $INDIR/vrt/$file | grep "Upper Left"  | awk \'{ gsub ("[(),]","") ; printf ("%.16f"  $4  +  0.000833333333333 ) }\')
# lrx=$(gdalinfo $INDIR/vrt/$file | grep "Lower Right" | awk \'{ gsub ("[(),]","") ; printf ("%.16f"  $3  +  0.000833333333333 ) }\')
# lry=$(gdalinfo $INDIR/vrt/$file | grep "Lower Right" | awk \'{ gsub ("[(),]","") ; printf ("%.16f"  $4  -  0.000833333333333 ) }\')

# gdal_translate -a_nodata none  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  -projwin  $ulx $uly $lrx $lry  $INDIR/all_tif_cut.vrt $INDIR/tif_overlup/$filename.tif
# pkreclass  -of GTiff -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -c -32768 -r 0 -i  $INDIR/tif_overlup/$filename.tif  -o $OUTDIR/altitude/tiles/$filename.tif  

# force the nodata to be -32768. gdaldem any number that is labeled to nodata will convert it in -9999 

# gdal_edit.py -a_nodata -32768  $OUTDIR/altitude/tiles/$filename.tif

# echo  slope with file  
# gdaldem slope    -s 111120 -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND   $OUTDIR/altitude/tiles/$filename.tif $RAM/slope_${filename}.tif 
# gdal_translate   -srcwin 1 1 12000 12000   -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/slope_${filename}.tif  $OUTDIR/slope/tiles/${filename}.tif  
# rm $RAM/slope_${filename}.tif 
# -s to consider xy in degree and z in meters

# echo  aspect  with file 

# gdaldem aspect  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  $OUTDIR/altitude/tiles/$filename.tif   $RAM/aspect_${filename}.tif  
# gdal_translate   -srcwin 1 1 12000 12000   -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND   $RAM/aspect_${filename}.tif  $OUTDIR/aspect/tiles/${filename}.tif
# rm $RAM/aspect_${filename}.tif 

# echo sin and cos of slope and aspect  

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $OUTDIR/aspect/tiles/${filename}.tif --calc="(sin(A.astype(float) * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_sin.tif --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $OUTDIR/aspect/tiles/${filename}.tif --calc="(cos(A.astype(float) * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_cos.tif --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $OUTDIR/slope/tiles/${filename}.tif  --calc="(sin(A.astype(float) * 3.141592 / 180))" --outfile   $OUTDIR/slope/tiles/${filename}_sin.tif  --overwrite --type=Float32
# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9  --co=INTERLEAVE=BAND -A $OUTDIR/slope/tiles/${filename}.tif  --calc="(cos(A.astype(float) * 3.141592 / 180))" --outfile   $OUTDIR/slope/tiles/${filename}_cos.tif  --overwrite --type=Float32

# echo   Ew  Nw   median  

# gdal_calc.py --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $OUTDIR/slope/tiles/${filename}.tif -B $OUTDIR/aspect/tiles/${filename}_sin.tif --calc="((sin(A.astype(float) * 3.141592 / 180)) * B.astype(float))" --outfile  $OUTDIR/aspect/tiles/${filename}_Ew.tif --overwrite --type=Float32
# gdal_calc.py --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $OUTDIR/slope/tiles/${filename}.tif -B $OUTDIR/aspect/tiles/${filename}_cos.tif --calc="((sin(A.astype(float) * 3.141592 / 180)) * B.astype(float))" --outfile  $OUTDIR/aspect/tiles/${filename}_Nw.tif --overwrite --type=Float32

###############  VRM  ########################################

echo VRM ${filename}.tif
#     A                  B             C                  A             D
#  z=cos (slope  )  x= sin(aspect ) * sin(slope)   y =  sin(slope) * cos(aspect )   ;  | r | sqrt ( (sum x)^2  + (sum y)^2 + (sum z)^2  )  

# echo z 

# pkfilter -nodata -9999 -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND  -ot Float32   -i   $OUTDIR/slope/tiles/${filename}_cos.tif -o   $RAM/${filename}_sumz.tif

# echo x      slope does not have no data -9999

# pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND  -ot Float32  -c -9999  -r 0  -i $OUTDIR/aspect/tiles/${filename}_sin.tif     -o $OUTDIR/aspect/tiles/${filename}_sin_0.tif

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A  $OUTDIR/aspect/tiles/${filename}_sin_0.tif   -B  $OUTDIR/slope/tiles/${filename}_sin.tif  --calc="(A.astype(float) * B.astype(float))" --type=Float32 --overwrite --outfile   $RAM/${filename}_x.tif

# pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND   -ot Float32  -c -9999  -r 0  -i   $RAM/${filename}_x.tif -o   $RAM/${filename}_x0.tif

# pkfilter  -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Float32   -i   $RAM/${filename}_x0.tif -o   $RAM/${filename}_sumx0.tif 

# echo y 

# pkreclass  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND  -ot Float32  -c -9999  -r 0  -i $OUTDIR/aspect/tiles/${filename}_cos.tif     -o $OUTDIR/aspect/tiles/${filename}_cos_1.tif

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A  $OUTDIR/slope/tiles/${filename}_sin.tif -B $OUTDIR/aspect/tiles/${filename}_cos_1.tif --calc="(A.astype(float) * B.astype(float))" --type=Float32 --overwrite --outfile   $RAM/${filename}_y.tif

# pkreclass -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND -ot Float32 -c -9999  -r 0  -i   $RAM/${filename}_y.tif -o   $RAM/${filename}_y0.tif

# pkfilter -nodata -9999 -dx 3 -dy 3 -f sum  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Float32 -i $RAM/${filename}_y0.tif -o $RAM/${filename}_sumy0.tif 

# # vrm 

# gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 --co=INTERLEAVE=BAND -A $RAM/${filename}_sumx0.tif  -B  $RAM/${filename}_sumy0.tif  -C  $RAM/${filename}_sumz.tif  --calc="( 1 - ( (sqrt ( ( A.astype(float) * A.astype(float) ) + (B.astype(float) * B.astype(float) ) + ( C.astype(float) * C.astype(float) ) )) / 9 ) )" --type=Float32 --overwrite --outfile   $RAM/${filename}.tif 

# pksetmask  -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND    -msknodata 0 -nodata 0 -p  "<" -m $RAM/${filename}.tif -i  $RAM/${filename}.tif -o   $OUTDIR/vrm/tiles/${filename}.tif

# rm -f  $RAM/${filename}_sumx0.tif   $RAM/${filename}_sumy0.tif   $RAM/${filename}_sumz1.tif $RAM/${filename}_*.tif


#########################3 vrm grass #################################
echo start grass  $OUTDIR/vrm/tiles/loc_$filename
rm -rf $OUTDIR/vrm/tiles/loc_$filename
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh $OUTDIR/vrm/tiles  loc_$filename  $OUTDIR/altitude/tiles/$filename.tif 
~/.grass7/addons/bin/r.vector.ruggedness.py      elevation=$filename   output=${filename}_vrm  
r.out.gdal -c  createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff type=Float64  input=${filename}_vrm  output=$OUTDIR/vrm/tiles/${filename}_"gr.tif" --o

rm -rf $OUTDIR/vrm/tiles/loc_$filename

###############

# echo  generate a Terrain Ruggedness Index TRI  with file   $file
# gdaldem TRI -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND $OUTDIR/altitude/tiles/$filename.tif  $RAM/tri_${filename}.tif
# gdal_translate   -srcwin 1 1 12000 12000   -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND $RAM/tri_${filename}.tif  $OUTDIR/tri/tiles/${filename}.tif
# rm $RAM/tri_${filename}.tif
# echo  generate a Topographic Position Index TPI  with file  $filename.tif

# gdaldem TPI  -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND $OUTDIR/altitude/tiles/$filename.tif $RAM/tpi_${filename}.tif
# gdal_translate   -srcwin 1 1 12000 12000   -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND $RAM/tpi_${filename}.tif  $OUTDIR/tpi/tiles/${filename}.tif
# rm $RAM/tpi_${filename}.tif

echo  generate roughness   with file   $filename.tif

# gdaldem  roughness   -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND  $OUTDIR/altitude/tiles/$filename.tif  $RAM/roughness_${filename}.tif
# gdal_translate   -srcwin 1 1 12000 12000   -co COMPRESS=LZW -co ZLEVEL=9  -co INTERLEAVE=BAND $RAM/roughness_${filename}.tif  $OUTDIR/roughness/tiles/${filename}.tif
# rm $RAM/roughness_${filename}.tif


' _ 

exit 

# start the aggregation in automatic using the same list 

for km in 1 5 10 50 100 ; do qsub  -v km=$km,list=$list   /home/fas/sbsc/ga254/scripts/SRTM/sc3a_dem_variables_float_noMult_resKM.sh ; done 

checkjob -v $PBS_JOBID 

rm -f /dev/shm/* 

