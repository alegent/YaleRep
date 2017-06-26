
#  qsub -v SENS=MYD  /u/gamatull/scripts/LST/sc5_fillspline_MOYD11A2.sh 

#PBS -S /bin/bash
#PBS -q long
#PBS -l select=1:ncpus=24
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS   /u/gamatull/scripts/LST/sc5_fillspline_MOYD11A2.sh 

export  SENS=$SENS

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill

export RAMDIR=/dev/shm


# replicate the dataset 3 times    ( in case of using the full data series add the first day at the end of the series ; echo .... )

# define tiles with lst data

# echo 0 0 0 255 255    >   /tmp/table
# echo 1 255 0 0 255  >>  /tmp/table

# awk '{ if (NR>1)  print $1   }' /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d.txt  | xargs -n 1 -P  24  bash -c $'
# tile=$1  
# geo_string=$(grep $tile /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d.txt | awk \'{ print $4 , $5 , $6, $7}\' ) 
# gdal_translate -a_nodata -1    -co COMPRESS=LZW -co ZLEVEL=9   -projwin  $geo_string   /nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_msk/MOD_SEA_mask_wgs84.tif    /nobackupp8/gamatull/dataproces/LST/mask/tile$tile.tif

# gdal_edit.py -a_nodata -1 /nobackupp8/gamatull/dataproces/LST/mask/tile$tile.tif
# min=$(pkinfo -min -i   /nobackupp8/gamatull/dataproces/LST/mask/tile$tile.tif  | awk \'{ print  $2 }\') 
# if [ $min -eq 0 ] ; then 
# echo $tile > /nobackupp8/gamatull/dataproces/LST/mask/$tile.txt 
# pkcreatect  -ct /tmp/table  -i /nobackupp8/gamatull/dataproces/LST/mask/tile$tile.tif   -o  /nobackupp8/gamatull/dataproces/LST/mask/tile${tile}_ct.tif 
# else
# rm /nobackupp8/gamatull/dataproces/LST/mask/tile$tile.tif  
# fi 
#  ' _ 

# cat /nobackupp8/gamatull/dataproces/LST/mask/??????.txt > /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d_land.txt
# rm  /nobackupp8/gamatull/dataproces/LST/mask/*

rm -f /dev/shm/*

cat  /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d_land.txt   | xargs -n 1 -P  24  bash -c $' 

# india tile ul=h24v06  ll=h24v08  ur=h26v06 lr=h26v08 

tile=$1

geo_string=$(grep $tile /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d.txt | awk \'{ print $4 , $7 , $6 , $5 }\')
# geo_string="70 10 80 20"
# geo_string=$(echo -161 70 -160 71 )   # insert for validation 

# the nr variable addjust the number of day to put at the befining or at the end of the temporal series. 
# nr change in accordance to the BW. controllare il risultato con le vaidation procedure.

nr=1
nrt=$(expr 47 - $nr)

gdalbuildvrt -te $geo_string   -separate   -overwrite  $RAMDIR/LST_${SENS}_$tile.vrt   $( echo $(awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS  \'{ if (NR>nr) { print INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif" } }\' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; awk  -v  INSENS=$INSENS -v SENS=$SENS \'{ print   INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif"   }\' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; awk -v nrt=$nrt  -v  INSENS=$INSENS -v SENS=$SENS   \'{ if (NR<=nrt)  print  INSENS "/LST_" SENS "_QC_day" $1 "_wgs84_fillspat.tif"   }\' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ) ) 

echo start the spline for $tile  

pkfilter -of GTiff -ot Float32 -co BIGTIFF=YES -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp cspline  -i  $RAMDIR/LST_${SENS}_$tile.vrt   -o $OUTSENS/LST_${SENS}_cspline_${tile}_tmp.tif
# create the vrt only with the usefull band (restore the initial dataset by delating the beginning and end) 
gdalbuildvrt    -overwrite   $(seq  $(( 46-$nr+1 )) $(( 46+(46-$nr) )) |  xargs -n 1 echo -b)  $RAMDIR/LST_${SENS}_cspline_$tile.vrt   $OUTSENS/LST_${SENS}_cspline_${tile}_tmp.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES  $RAMDIR/LST_${SENS}_cspline_$tile.vrt  $OUTSENS/LST_${SENS}_cspline_$tile.tif
rm -f $OUTSENS/LST_${SENS}_cspline_${tile}_tmp.tif $RAMDIR/LST_${SENS}_cspline_$tile.vrt 

pkfilter -of GTiff  -ot Float32  -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp akima    -i  $RAMDIR/LST_${SENS}_$tile.vrt   -o $OUTSENS/LST_${SENS}_akima_${tile}_tmp.tif
gdalbuildvrt    -overwrite   $(seq  $(( 46-$nr+1 )) $(( 46+(46-$nr) )) |  xargs -n 1 echo -b)  $RAMDIR/LST_${SENS}_akima_$tile.vrt   $OUTSENS/LST_${SENS}_akima_${tile}_tmp.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES  $RAMDIR/LST_${SENS}_akima_$tile.vrt  $OUTSENS/LST_${SENS}_akima_$tile.tif
rm -f $OUTSENS/LST_${SENS}_akima_${tile}_tmp.tif  $RAMDIR/LST_${SENS}_akima_$tile.vrt 

# $RAMDIR/LST_${SENS}_spline_$tile.tif
# validation procedure .  se si campbia il bw controllareil nr 

# gdalbuildvrt  -overwrite  -te $geo_string   -separate   -overwrite  $RAMDIR/LST_orig${SENS}_$tile.vrt   $( echo $(awk  -v  INSENS=$INSENS -v SENS=$SENS \'{ print   INSENS "/LST_" SENS "_QC_day" $1 "_wgs84.tif"   }\' /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt) )  
# gdal_translate $RAMDIR/LST_orig${SENS}_$tile.vrt  $RAMDIR/LST_orig${SENS}_$tile.tif 

# paste <(cat  /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt )  <(   gdallocationinfo   -geoloc -valonly  $RAMDIR/LST_orig${SENS}_$tile.tif  76.7236 17.1832  )  <(gdallocationinfo   -geoloc  $OUTSENS/LST_${SENS}_spline_$tile.tif  76.7236 17.1832  -valonly ) >  /tmp/test_akima.txt

# cat  /tmp/test.txt

# head -1  month_serie.txt
# tail -1  month_serie.txt


' _ 

# rm -f /dev/shm/*
