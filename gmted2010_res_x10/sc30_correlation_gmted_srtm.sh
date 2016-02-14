



SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
GMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED

gdal_translate -a_nodata "none" -co COMPRESS=LZW -co ZLEVEL=9 -projwin 6 48 11 45 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/md75_grd_tif.vrt $OUTDIR/GMTED/md75_grd_tif.tif
gdal_translate -a_nodata "none" -co COMPRESS=LZW -co ZLEVEL=9 -projwin 6 48 11 45 /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/tiles.vrt $OUTDIR/SRTM/srtm_tif.tif 


for MAT in max mean median min stdev ; do 

if [ $MAT = "max"    ]  ; then MAT2="mx"   ; fi
if [ $MAT = "min"    ]  ; then MAT2="mi"   ; fi
if [ $MAT = "mean"   ]  ; then MAT2="mn"   ; fi
if [ $MAT = "median" ]  ; then MAT2="md"   ; fi
if [ $MAT = "stdev"  ]  ; then MAT2="sd"   ; fi

for km in 1 5 10 50 100 ; do 
    
    for dir1 in slope tri tpi roughness vrm ; do 
	gdal_translate  -a_nodata "none"  -projwin 6 48 11 45  -co COMPRESS=LZW  -co ZLEVEL=9    $SRTM/${dir1}/${MAT}/${dir1}_${MAT}_km${km}.tif  $OUTDIR/SRTM/${dir1}_${MAT}_SRTM_km${km}.tif
	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/md75_grd_tif.tif  )  -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${dir1}/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif
    done 

    echo aspect 

    for var in cos sin Ew Nw ; do 
	gdal_translate  -a_nodata "none" -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/md75_grd_tif.tif )  -co COMPRESS=LZW  -co ZLEVEL=9    $SRTM/aspect/${MAT}/aspect_${MAT}_${var}_km${km}.tif     $OUTDIR/SRTM/aspect_${var}_SRTM_km${km}.tif
	if [ $var = "cos" ]  ; then var2=aspect-cosine    ; fi 
	if [ $var = "sin" ]  ; then var2=aspect-sine      ; fi 
	if [ $var = "Ew" ]   ; then var2=eastness         ; fi 
	if [ $var = "Nw" ]   ; then var2=northness        ; fi
    gdal_translate -a_nodata "none"   -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/md75_grd_tif.tif )   -co COMPRESS=LZW  -co ZLEVEL=9   $GMTED/final/aspect/${var2}_${MAT2}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/${var2}_${MAT2}_GMTED2010_md_km${km}.tif
done 
    
done 
done 



for km in 1 5 10 50 100 ; do 
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/md75_grd_tif.tif )    -co COMPRESS=LZW  -co ZLEVEL=9  $SRTM/altitude/stdev/altitude_stdev_km${km}.tif                   $OUTDIR/SRTM/elevation_psd_SRTM_km${km}.tif
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/md75_grd_tif.tif )    -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/stdev_pulled/elevation_psd_GMTED2010_sd_km${km}.tif  $OUTDIR/GMTED/elevation_psd_GMTED_km${km}.tif

for var in min max median mean ; do 

    gdal_translate -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/md75_grd_tif.tif )  -co COMPRESS=LZW  -co ZLEVEL=9  $SRTM/altitude/${var}/altitude_${var}_km${km}.tif    $OUTDIR/SRTM/elevation_${var1}_SRTM_km${km}.tif

    if [ $var = "min" ]      ; then var2=min_of_mi    ;  var1=mi ; fi 
    if [ $var = "max" ]      ; then var2=max_of_mx    ;  var1=mx ; fi 
    if [ $var = "mean" ]     ; then var2=mean_of_mn   ;  var1=mn ; fi 
    if [ $var = "median" ]   ; then var2=median_of_md ;  var1=md ; fi
 
    gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif )   -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${var2}/elevation_${var1}_GMTED2010_${var1}_km${km}.tif  $OUTDIR/GMTED/elevation_${var1}_GMTED2010_${var1}_km${km}.tif

done 
done 


# original resolution SRTM

for dir in  altitude  aspect  roughness  slope  tpi  tri  vrm ; do 
    gdalbuildvrt -overwrite  test.vrt   $SRTM/${dir}/tiles/tiles_216000_12000.tif  $SRTM/${dir}/tiles/tiles_228000_12000.tif 
    gdal_translate -projwin   $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif )   test.vrt $OUTDIR/SRTM/SRTM_90/${dir}_SRTM.tif 
done 
rm  test.vrt


for var in cos sin Ew Nw ; do 
    gdalbuildvrt -overwrite  test.vrt   $SRTM/aspect/tiles/tiles_216000_12000_${var}.tif  $SRTM/aspect/tiles/tiles_228000_12000_${var}.tif 
    gdal_translate -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif )   test.vrt $OUTDIR/SRTM/SRTM_90/aspect_${var}_SRTM.tif 
done 
rm  test.vrt

# orignal resolution GMTED 
    gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif ) $GMTED/tiles/md75_grd_tif/5_1.tif    $OUTDIR/GMTED/GMTED_250/altitude_GMTED.tif

for dir in   aspect  roughness  slope  tpi  tri  vrm ; do    
    gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif )  $GMTED/${dir}/tiles/5_1_md.tif    $OUTDIR/GMTED/GMTED_250/${dir}_GMTED.tif
done 

for var in cos sin Ew Nw ; do 
    gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/md75_grd_tif.tif )  $GMTED/aspect/tiles/5_1_md_${var}.tif    $OUTDIR/GMTED/GMTED_250/aspect_${var}_GMTED.tif
done 


