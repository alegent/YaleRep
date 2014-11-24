
# ls /lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles/*.bil | xargs -n 1 -P 1 bash /lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles/test.sh
# create 

file=$1

# funziona oft-cluster-latlong.bash 

export filename=`basename $file .bil`
export INDIR=/lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tiles
export OUTDIR=/lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90
export TMP=/tmp

gdal_translate  -a_nodata -32768  -co COMPRESS=LZW -co ZLEVEL=9 -ot Int16   $INDIR/$filename.bil   $OUTDIR/tif/$filename.tif 

gdaldem slope    -s 111120      -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/slope/${filename}.tif 
gdaldem aspect  -zero_for_flat  -co COMPRESS=LZW   $OUTDIR/tif/$filename.tif  $OUTDIR/aspect/${filename}.tif

gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/aspect/${filename}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile $OUTDIR/aspect/${filename}"_sin.tif" --overwrite --type Float32
gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/aspect/${filename}.tif --calc="(cos(A * 3.141592 / 180))"  --outfile $OUTDIR/aspect/${filename}"_cos.tif"  --overwrite --type Float32


echo eastenes  

gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/slope/${filename}.tif -B $OUTDIR/aspect/${filename}_sin.tif --calc="((sin(A))*B)" --outfile $OUTDIR/aspect/${filename}"_Ew.tif" --overwrite --type Float32

oft-calc -ot Int16 $OUTDIR/aspect/${filename}"_Ew.tif"  $TMP/${filename}"_Ew_tmp.tif" &> /dev/null <<EOF
1
#1 10000 *
EOF
gdal_translate -a_nodata -32768 -co COMPRESS=LZW -ot Int16 $TMP/${filename}"_Ew_tmp.tif"   $OUTDIR/aspect/${filename}"_Ew.tif"

rm -f $TMP/${filename}"_Ew_tmp.tif" 

echo northnes 

gdal_calc.py --co=COMPRESS=LZW --NoDataValue -32768 -A $OUTDIR/slope/${filename}.tif -B $OUTDIR/aspect/${filename}_cos.tif --calc="((sin(A))*B)" --outfile $OUTDIR/aspect/${filename}"_Nw.tif" --overwrite --type Float32

oft-calc -ot Int16  $OUTDIR/aspect/${filename}"_Nw.tif"   $TMP/${filename}"_Nw_tmp.tif"   &> /dev/null <<EOF
1
#1 10000 *
EOF
gdal_translate  -a_nodata -32768 -co COMPRESS=LZW -ot Int16  $TMP/${filename}"_Nw_tmp.tif"  $OUTDIR/aspect/${filename}"_Nw.tif"

rm -f $TMP/${filename}"_Nw_tmp.tif" 

echo multiband

gdalbuildvrt -overwrite  -separate $OUTDIR/tif/$filename.vrt  $OUTDIR/tif/$filename.tif    $OUTDIR/aspect/${filename}"_Nw.tif" $OUTDIR/aspect/${filename}"_Ew.tif" 
gdal_translate -ot Int16 -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/tif/$filename.vrt         $OUTDIR/tif/${filename}_multiband.tif 

echo starting the clustering action

oft-cluster.bash    $OUTDIR/tif/${filename}_multiband.tif   $OUTDIR/tif/${filename}_cluster.tif  12 1 


# crete multy band only with sine and cosine 

oft-calc -ot Int16  $OUTDIR/aspect/${filename}"_sin.tif"  $OUTDIR/aspect/${filename}"_sin_10k.tif"    &> /dev/null <<EOF
1
#1 10000 *
EOF

oft-calc -ot Int16  $OUTDIR/aspect/${filename}"_cos.tif"  $OUTDIR/aspect/${filename}"_cos_10k.tif"    &> /dev/null <<EOF
1
#1 10000 *
EOF

gdalbuildvrt -overwrite  -separate $OUTDIR/tif/$filename.vrt  $OUTDIR/tif/$filename.tif   $OUTDIR/slope/${filename}.tif      $OUTDIR/aspect/${filename}"_sin_10k.tif"  $OUTDIR/aspect/${filename}"_cos_10k.tif"
gdal_translate -ot Int16 -co COMPRESS=LZW -co ZLEVEL=9   $OUTDIR/tif/$filename.vrt        $OUTDIR/tif/${filename}_multiband_aspect.tif 

echo starting the clustering action

oft-cluster-latlong.bash    $OUTDIR/tif/${filename}_multiband_aspect.tif   $OUTDIR/tif/${filename}_cluster_aspect8.tif  8 1 
oft-clump -i $OUTDIR/tif/${filename}_cluster_aspect8.tif -o   $OUTDIR/tif/${filename}_clump_aspect8.tif





# comparison with the reprojection 

gdalwarp -t_srs  "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"   $OUTDIR/tif/${filename}_multiband_aspect.tif  $OUTDIR/tif/${filename}_multiband_aspect_proj.tif
oft-cluster.bash    $OUTDIR/tif/${filename}_multiband_aspect_proj.tif $OUTDIR/tif/${filename}_multiband_aspect_cluster_proj.tif 12 1 



# oft-clump -um  UA$UA"_mskw_BGmsk255_popDmsk_-1.tif"   UA$UA"_mskw_12classes1perc.tif"   UA$UA"clumpIDsegments.tif"    >  /dev/null 
# 
# nseg=`pkinfo -mm -i UA$UA"clumpIDsegments.tif" | awk '{  print $4 }'`
# 
# npix=`pkinfo --hist -i UA$UA"_mskw_BGmsk255_popDmsk_-1.tif"  | awk '{ if($1==1) print $2 }'`
# awk -v UA=$UA  -v nseg=$nseg -v n=$n   -v   npix=$npix  'BEGIN { print UA, nseg / ( npix * 900 / 1000000 )  }'  > UA$UA"_NsegKm2.txt" 







echo '"X","Y","ID"' > point.csv
awk '{  print $2","$3","$1 }' /lustre0/scratch/ga254/dem_bj/EarthEnv-DEM90/tif/point.txt  >> point.csv

echo "<OGRVRTDataSource>" > point.vrt
echo "    <OGRVRTLayer name=\"point\">" >>  point.vrt
echo "        <SrcDataSource>point.csv</SrcDataSource>"  >>  point.vrt 
echo "	      <GeometryType>wkbPoint</GeometryType>"  >>  point.vrt  
echo "	      <GeometryField encoding=\"PointFromColumns\" x=\"X\" y=\"Y\" z=\"ID\" /> "  >>  point.vrt 
echo "    </OGRVRTLayer>"  >>   point.vrt  
echo "</OGRVRTDataSource>"  >>   point.vrt 

rm point.shp point.shx point.dbf
ogr2ogr point.shp  point.vrt


