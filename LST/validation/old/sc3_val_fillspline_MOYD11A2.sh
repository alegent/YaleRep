
#  qsub -v SENS=MOD  /u/gamatull/scripts/LST/sc3_val_fillspline_MOYD11A2.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=4
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo $SENS   /u/gamatull/scripts/LST/sc5_fillspline_MOYD11A2.sh 

export  SENS=${SENS}

export  INSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_spline4fill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/MOD11A2_val/${SENS}11A2_splinefill

export RAMDIR=/dev/shm


rm -f /dev/shm/*

for HOL in 1 2 3 4 5 6 7 8 9     ; do 

export HOL

echo  h24v08  
echo  h24v06  h26v06  h26v08  h24v08    | xargs -n 1 -P  4  bash -c $' 

# india tile ul=h24v06  ll=h24v08  ur=h26v06 lr=h26v08 

tile=$1

geo_string=$(grep $tile /nobackupp8/gamatull/dataproces/LST/geo_file/tile_lat_long_20d.txt | awk \'{ print $4 , $7 , $6 , $5 }\')
# geo_string="70 10 80 20"
# geo_string=$(echo -161 70 -160 71 )   # insert for validation 

# the nr variable addjust the number of day to put at the befining or at the end of the temporal series. 
# nr change in accordance to the BW. controllare il risultato con le vaidation procedure.

nr=1
nrt=$(expr 47 - $nr)

# create txt file having the right holl file number

awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS  \'{ if (NR>nr) { print INSENS "/LST_" SENS "_QC_day" $1 "_wgs84.tif" } }\' <(join -v 2  -1 1 -2 1   <( grep " $HOL"  $INSENS/../day_holl_numb | awk \'{ print $1  }\'  ) /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt)  > $OUTSENS/list1_$tile.txt
awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS -v HOL=$HOL \'{  print INSENS "_" HOL  "hole/LST_" SENS "_QC_day" $1 "_wgs84.tif"  }\' <( grep " $HOL" $INSENS/../day_holl_numb | awk \'{ print $1  }\'  )  >> $OUTSENS/list1_$tile.txt
awk \'{ gsub ("QC_day", " " )  ; print $1 , $2   }\'  $OUTSENS/list1_$tile.txt | sort -k 2,2 -g | awk \'{ gsub (" " , "QC_day")  ; print $1    }\' >  $OUTSENS/list_sort1_$tile.txt


awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS  \'{ print INSENS "/LST_" SENS "_QC_day" $1 "_wgs84.tif"  }\' <(join -v 2  -1 1 -2 1   <( grep " $HOL"  $INSENS/../day_holl_numb | awk \'{ print $1  }\' ) /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt)  > $OUTSENS/list2_$tile.txt
awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS -v HOL=$HOL \'{  print INSENS "_" HOL  "hole/LST_" SENS "_QC_day" $1 "_wgs84.tif"  }\' <( grep " $HOL"  $INSENS/../day_holl_numb | awk \'{ print $1  }\'  )  >> $OUTSENS/list2_$tile.txt
awk \'{ gsub ("QC_day", " " )  ; print $1 , $2   }\'  $OUTSENS/list2_$tile.txt | sort -k 2,2 -g | awk \'{ gsub (" " , "QC_day")  ; print $1    }\' > $OUTSENS/list_sort2_$tile.txt


awk -v nrt=$nrt -v  INSENS=$INSENS -v SENS=$SENS  \'{ if (NR<=nrt) { print INSENS "/LST_" SENS "_QC_day" $1 "_wgs84.tif" } }\' <(join -v 2  -1 1 -2 1   <( grep " $HOL"  $INSENS/../day_holl_numb | awk \'{ print $1  }\'  ) /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt)  > $OUTSENS/list3_$tile.txt
awk -v nr=$nr -v  INSENS=$INSENS -v SENS=$SENS -v HOL=$HOL \'{  print INSENS "_" HOL  "hole/LST_" SENS "_QC_day" $1 "_wgs84.tif"  }\' <( grep " $HOL"  $INSENS/../day_holl_numb | awk \'{ print $1  }\'  )  >> $OUTSENS/list3_$tile.txt
awk \'{ gsub ("QC_day", " " )  ; print $1 , $2   }\'  $OUTSENS/list3_$tile.txt | sort -k 2,2 -g | awk \'{ gsub (" " , "QC_day")  ; print $1    }\' > $OUTSENS/list_sort3_$tile.txt


gdalbuildvrt -te $geo_string   -separate   -overwrite  $RAMDIR/LST_${SENS}_$tile.vrt    $(cat $OUTSENS/list_sort1_$tile.txt  $OUTSENS/list_sort2_$tile.txt $OUTSENS/list_sort3_$tile.txt )

echo start the spline for $tile  
rm -f ${OUTSENS}_${HOL}hole/LST_${SENS}_cspline_${tile}_tmp.tif

pkfilter -of GTiff  -ot Float32 -co BIGTIFF=YES    -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp cspline  -i  $RAMDIR/LST_${SENS}_$tile.vrt   -o ${OUTSENS}_${HOL}hole/LST_${SENS}_cspline_${tile}_tmp.tif
# create the vrt only with the usefull band (restore the initial dataset by delating the beginning and end) 
gdalbuildvrt    -overwrite   $(seq  $(( 46-$nr+1 )) $(( 46+(46-$nr) )) |  xargs -n 1 echo -b)  $RAMDIR/LST_${SENS}_cspline_$tile.vrt   ${OUTSENS}_${HOL}hole/LST_${SENS}_cspline_${tile}_tmp.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES  $RAMDIR/LST_${SENS}_cspline_$tile.vrt  ${OUTSENS}_${HOL}hole/LST_${SENS}_cspline_$tile.tif
rm -f ${OUTSENS}_${HOL}hole/LST_${SENS}_cspline_${tile}_tmp.tif $RAMDIR/LST_${SENS}_cspline_$tile.vrt 

rm -f ${OUTSENS}_${HOL}hole/LST_${SENS}_akima_${tile}_tmp.tif

pkfilter -of GTiff  -ot Float32  -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9 -nodata 0  -f smoothnodata  -dz 1   -interp akima    -i  $RAMDIR/LST_${SENS}_$tile.vrt   -o ${OUTSENS}_${HOL}hole/LST_${SENS}_akima_${tile}_tmp.tif
gdalbuildvrt    -overwrite   $(seq  $(( 46-$nr+1 )) $(( 46+(46-$nr) )) |  xargs -n 1 echo -b)  $RAMDIR/LST_${SENS}_akima_$tile.vrt   ${OUTSENS}_${HOL}hole/LST_${SENS}_akima_${tile}_tmp.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -co BIGTIFF=YES  $RAMDIR/LST_${SENS}_akima_$tile.vrt  ${OUTSENS}_${HOL}hole/LST_${SENS}_akima_$tile.tif
rm -f ${OUTSENS}_${HOL}hole/LST_${SENS}_akima_${tile}_tmp.tif  $RAMDIR/LST_${SENS}_akima_$tile.vrt 



' _ 

done 

# rm -f /dev/shm/*
