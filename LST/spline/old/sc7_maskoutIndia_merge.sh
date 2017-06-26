# mask preparation 
# pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32 --crule maxband   -i glob_ID0_rast.tif  -i IndiaMya_maskLargWeight.tif  -o globeIndiaMya_maskLargWeight.tif 

# coefficente ti sovrastima non funziona 
# gdal_translate -projwin 65.0000000  33.0000000 98.0000000   7.9166667 -co COMPRESS=LZW -co ZLEVEL=9  LST_MYD_akima_day209_allobs.tif LST_MYD_akima_day209_allobs_crop.tif
# gdal_translate -projwin 65.0000000  33.0000000 98.0000000   7.9166667 -co COMPRESS=LZW -co ZLEVEL=9  LST_MYD_akima_day209_allobs.tiforig LST_MYD_akima_day209_allobs_crop.tiforig

# pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -msknodata 0 -nodata -1  -i LST_MYD_akima_day209_allobs_crop.tif  -m /nobackupp8/gamatull/dataproces/LST/MASK/IndiaMya_maskLargWeight.tif  -o LST_MYD_akima_day209_allobs_cropMask.tif
# pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -msknodata 0  -nodata -1 -i LST_MYD_akima_day209_allobs_crop.tiforig  -m /nobackupp8/gamatull/dataproces/LST/MASK/IndiaMya_maskLargWeight.tif  -o   LST_MYD_akima_day209_allobs_cropMask.tiforig

# gdalbuildvrt  -separate   -overwrite pkstat.vrt LST_MYD_akima_day209_allobs_cropMask.tif   LST_MYD_akima_day209_allobs_cropMask.tiforig
# pkstat --regerr -i pkstat.vrt -b 0 -b 1 -nodata -1 



#  qsub -v SENS=MYD /u/gamatull/scripts/LST/spline/sc7_maskoutIndia_merge.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=10
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

export  SENS=${SENS}

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill_merge
export RAM=/dev/shm



echo 153 161 169 177 185 193 201 209 217 225 | xargs -n 1 -P 10 bash -c $' 
DAY=$1

gdalbuildvrt  -separate   -overwrite $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs.tif  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs.tiforig  /nobackupp8/gamatull/dataproces/LST/MASK/globeIndiaMya_maskLargWeight.tif 

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tmtmp.tif <<EOF
1
#1 #3 *
EOF

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tmtmp.tif $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tm.tif 
rm -f $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tmtmp.tif

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmtmp.tif <<EOF
1
1 #3 - #2 *
EOF

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmtmp.tif  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tm.tif
rm -f $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmtmp.tif

gdalbuildvrt  -separate   -overwrite $RAM/sum${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tm.tif 
oft-calc   $RAM/sum${DAY}.vrt   $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmfinaltmp.tif <<EOF
1
#1 #2 + 
EOF

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmfinaltmp.tif $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_MskIndia.tif
rm -f  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tmfinaltmp.tif  $OUTSENS/LST_${SENS}_akima_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_day${DAY}_allobs_tm.tif

' _ 

rm $OUTSENS/*.eq
rm -fr /dev/shm/*