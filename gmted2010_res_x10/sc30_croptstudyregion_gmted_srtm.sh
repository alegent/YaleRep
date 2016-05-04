# qsub /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc30_croptstudyregion_gmted_srtm.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l mem=34gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
export GMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED

# andes borneo 

echo  alps andes borneo  | xargs -n 1 -P 3 bash -c $'

AREA=$1

if [  $AREA = "alps"  ] ; then geo_string="6 48 11 45" ; fi 
if [  $AREA = "andes"  ] ; then geo_string="-80 -4 -75 -7" ; fi 
if [  $AREA = "borneo"  ] ; then geo_string="114 6 117 0" ; fi 

gdal_translate -a_nodata "none" -co COMPRESS=LZW -co ZLEVEL=9 -projwin ${geo_string}  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/md75_grd_tif.vrt $OUTDIR/GMTED/$AREA/md75_grd_tif.tif
gdal_translate -a_nodata "none" -co COMPRESS=LZW -co ZLEVEL=9 -projwin ${geo_string}  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/vrt/tiles.vrt $OUTDIR/SRTM/$AREA/srtm_tif.tif 

for MAT in max mean median min stdev ; do 

if [ $MAT = "max"    ]  ; then MAT2="mx"   ; fi
if [ $MAT = "min"    ]  ; then MAT2="mi"   ; fi
if [ $MAT = "mean"   ]  ; then MAT2="mn"   ; fi
if [ $MAT = "median" ]  ; then MAT2="md"   ; fi
if [ $MAT = "stdev"  ]  ; then MAT2="sd"   ; fi

for km in 1 5 10 50 100 ; do 
    for dir1 in slope tri tpi roughness vrm ; do 
	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9    $SRTM/${dir1}/${MAT}/${dir1}_${MAT}_km${km}.tif  $OUTDIR/SRTM/$AREA/${dir1}_${MAT}_SRTM_km${km}.tif
 	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${dir1}/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/$AREA/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif
    done 

     for var in cos sin Ew Nw ; do 
 	gdal_translate -a_nodata "none" -projwin $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif) -co COMPRESS=LZW -co ZLEVEL=9  $SRTM/aspect/${MAT}/aspect_${MAT}_${var}_km${km}.tif  $OUTDIR/SRTM/$AREA/aspect_${var}_${MAT}_SRTM_km${km}.tif
 	if [ $var = "cos" ]  ; then var2=aspect-cosine    ; fi 
 	if [ $var = "sin" ]  ; then var2=aspect-sine      ; fi 
 	if [ $var = "Ew" ]   ; then var2=eastness         ; fi 
 	if [ $var = "Nw" ]   ; then var2=northness        ; fi
 	gdal_translate -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )   -co COMPRESS=LZW  -co ZLEVEL=9   $GMTED/final/aspect/${var2}_${MAT2}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/$AREA/${var2}_${MAT2}_GMTED2010_md_km${k}.tif
     done 
done 

done 

for km in 1 5 10 50 100 ; do 
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )    -co COMPRESS=LZW  -co ZLEVEL=9  $SRTM/altitude/stdev/altitude_stdev_km${km}.tif                   $OUTDIR/SRTM/$AREA/elevation_psd_SRTM_km${km}.tif
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )    -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/stdev_pulled/elevation_psd_GMTED2010_sd_km${km}.tif  $OUTDIR/GMTED/$AREA/elevation_psd_GMTED_km${km}.tif

for var in min max median mean ; do 

    gdal_translate -a_nodata "none"  -projwin  $(getCorners4Gtranslate    $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )  -co COMPRESS=LZW  -co ZLEVEL=9  $SRTM/altitude/${var}/altitude_${var}_km${km}.tif    $OUTDIR/SRTM/$AREA/elevation_${var1}_SRTM_km${km}.tif

     if [ $var = "min" ]      ; then var2=min_of_mi    ;  var1=mi ; fi 
     if [ $var = "max" ]      ; then var2=max_of_mx    ;  var1=mx ; fi 
     if [ $var = "mean" ]     ; then var2=mean_of_mn   ;  var1=mn ; fi 
     if [ $var = "median" ]   ; then var2=median_of_md ;  var1=md ; fi
 
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )   -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${var2}/elevation_${var1}_GMTED2010_${var1}_km${km}.tif  $OUTDIR/GMTED/$AREA/elevation_${var1}_GMTED2010_${var1}_km${km}.tif

done 
done 

###############################

for km in 1 5 10 50 100 ; do
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/stdev_pulled/elevation_psd_GMTED2010_sd_km${km}.tif  $OUTDIR/GMTED/$AREA/elevation_psd_GMTED2010_sd_km${km}.tif
gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/stdev_of_md/elevation_sd_GMTED2010_md_km${km}.tif    $OUTDIR/GMTED/$AREA/elevation_sd_GMTED2010_md_km${km}.tif
done 


############### cuvature #######################


for MAT in max mean median min stdev ; do 

if [ $MAT = "max"    ]  ; then MAT2="mx"   ; fi
if [ $MAT = "min"    ]  ; then MAT2="mi"   ; fi
if [ $MAT = "mean"   ]  ; then MAT2="mn"   ; fi
if [ $MAT = "median" ]  ; then MAT2="md"   ; fi
if [ $MAT = "stdev"  ]  ; then MAT2="sd"   ; fi

for km in 1 5 10 50 100 ; do 
    for dir1 in dx dxx dy dyy pcurv tcurv    ; do 
	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${dir1}/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/$AREA/${dir1}_${MAT2}_GMTED2010_md_km${km}.tif
    done 
done 
done 

geomorphon #####################################


for km in 1 5 10 50 100 ; do 
    for dir1 in uni count ent majority shannon ; do 
	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif  ) -co COMPRESS=LZW  -co ZLEVEL=9  $GMTED/final/${dir1}/geomorphic_${dir1}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/$AREA/geomorphic_${dir1}_GMTED2010_md_km${km}.tif
    done 
done 

##################    ########################

for km in 1 5 10 50 100 ; do
    for class in $(seq 1 10 ); do
	gdal_translate  -a_nodata "none"  -projwin  $(getCorners4Gtranslate  $OUTDIR/GMTED/$AREA/md75_grd_tif.tif) -co COMPRESS=LZW -co ZLEVEL=9 $GMTED/final/percent/geomorphic_class${class}_GMTED2010_md_km${km}.tif  $OUTDIR/GMTED/$AREA/geomorphic_class${class}_GMTED2010_md_km${km}.tif
    done
done

########################################## 

echo  original resolution SRTM  $AREA    original resolution SRTM  $AREA    original resolution SRTM  $AREA    original resolution SRTM  $AREA     original resolution SRTM  $AREA    original resolution SRTM  $AREA   

for dir in  altitude  aspect  roughness  slope  tpi  tri  vrm ; do 
    gdalbuildvrt -overwrite  /tmp/$AREA.vrt   $SRTM/${dir}/tiles/tiles_*_*.tif  
    gdal_translate -projwin   $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )  /tmp/$AREA.vrt $OUTDIR/SRTM/$AREA/SRTM_90/${dir}_SRTM.tif 
done 
rm  /tmp/$AREA.vrt


for var in cos sin Ew Nw ; do 
     gdalbuildvrt -overwrite   /tmp/$AREA.vrt    $SRTM/aspect/tiles/tiles_*_*_${var}.tif  
     gdal_translate -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )   /tmp/$AREA.vrt  $OUTDIR/SRTM/$AREA/SRTM_90/aspect_${var}_SRTM.tif 
done 
rm  /tmp/$AREA.vrt 

echo  orignal resolution GMTED  $AREA   orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA    orignal resolution GMTED  $AREA  

gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif ) $GMTED/tiles/md75_grd_tif/md75_grd_tif.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/altitude_GMTED.tif

for dir in   aspect  roughness  slope  tpi  tri vrm  ; do    
     gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )  $GMTED/${dir}/tiles/${dir}_md.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/${dir}_GMTED.tif
done 

for var in cos sin Ew Nw ; do 
    gdal_translate  -projwin  $(getCorners4Gtranslate   $OUTDIR/GMTED/$AREA/md75_grd_tif.tif )  $GMTED/aspect/tiles/${var}_md.vrt    $OUTDIR/GMTED/$AREA/GMTED_250/aspect_${var}_GMTED.tif
done 


' _ 