
#  qsub -v SENS=MYD   /u/gamatull/scripts/LST/sc5_fillsplineAkima_MOYD11A2.sh

#PBS -S /bin/bash
#PBS -q devel
#PBS -l select=1:ncpus=8
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS  /u/gamatull/scripts/LST/sc5_fillspline_MOYD11A2.sh 

export  SENS=MYD

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill

export RAMDIR=/dev/shm

export tile=h16v04
geo_string=$(grep $tile /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d.txt | awk '{ print $4 , $7 , $6 , $5 }')

# gdalbuildvrt -te $geo_string  -overwrite  $RAMDIR/OBS_${SENS}_$tile.vrt  /nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_msk/MYD_LST3k_mask_daySUM_wgs84_ct.tif  
# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   $RAMDIR/OBS_${SENS}_$tile.vrt  $OUTSENS/OBS_${SENS}_$tile.tif

# gdalbuildvrt -te $geo_string  -overwrite  $RAMDIR/OBSgrow1p_${SENS}_$tile.vrt  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean_msk/${SENS}_LST3k_mask_daySUM_wgs84_grow1p.tif
# gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/OBSgrow1p_${SENS}_$tile.vrt  $OUTSENS/OBSgrow1p_${SENS}_$tile.tif

# the nr variable addjust the number of day to put at the befining or at the end of the temporal series. 
# nr change in accordance to the BW. controllare il risultato con le vaidation procedure.

export nr=30
export nrt=$(expr 47 - $nr)  # 47 

gdalbuildvrt -te $geo_string   -separate   -overwrite  $RAMDIR/LST_${SENS}_$tile.vrt   $( echo $(awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS  '{ if (NR>nr) { print INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif" } }' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; awk  -v  INSENS=$INSENS -v SENS=$SENS '{ print   INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif"   }' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; awk -v nrt=$nrt  -v  INSENS=$INSENS -v SENS=$SENS   '{ if (NR<=nrt)  print  INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif"   }' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ) ) 

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/LST_${SENS}_$tile.vrt    $RAMDIR/LST_${SENS}_$tile.tif

# pkfilter -of GTiff  -ot Float32  -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp akima    -i $RAMDIR/LST_${SENS}_$tile.tif    -o $OUTSENS/LST_${SENS}_$tile.tif

seq 0 23 | xargs -n 1 -P 20 bash -c $' 
x=$(( $1 * 100 ))


for y in $(seq 0 23) ; do 
y=$(( $y * 100 ))
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   -srcwin  $x $y 100 100  $RAMDIR/LST_${SENS}_${tile}.tif         $RAMDIR/LST_${SENS}_${tile}_x${x}_y${y}.tif 
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9   -srcwin  $x $y 100 100  $OUTSENS/OBSgrow1p_${SENS}_${tile}.tif  $OUTSENS/OBSgrow1p_${SENS}_${tile}_x${x}_y${y}.tif 

echo start the spline for ${tile}  $x $y 

# the akima spline works only on the 0 value 

pkfilter -of GTiff  -ot Float32  -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp akima    -i $RAMDIR/LST_${SENS}_${tile}_x${x}_y${y}.tif    -o $RAMDIR/LST_${SENS}_akima_${tile}_x${x}_y${y}_tmp.tif 

echo start tu build the vrt 

gdal_translate  $(seq  $(( 46-$nr+1 )) $(( 46+(46-$nr) )) |  xargs -n 1 echo -b)    -co COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_akima_${tile}_x${x}_y${y}_tmp.tif    $OUTSENS/LST_${SENS}_akima_${tile}_x${x}_y${y}.tif  

done 

' _

