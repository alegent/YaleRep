# before the sc7_spline_MOYD11A2.sh 

# cd /tmp/ ;  for SENS in MYD MOD ; do for DN in Day Nig ; do  qsub  -v SENS=$SENS,DN=$DN   /u/gamatull/scripts/LST/spline/sc8_maskoutIndia-Patag_merge.sh ; done ; done ; cd - 

# mask preparation 
# pkcomposite  -co COMPRESS=LZW -co ZLEVEL=9   -ot Float32 --crule maxband   -i glob_ID0_rast.tif  -i IndiaMya_maskLargWeight.tif  -o globeIndiaMya_maskLargWeight.tif 

# coefficente ti sovrastima non funziona 
# gdal_translate -projwin 65.0000000  33.0000000 98.0000000   7.9166667 -co COMPRESS=LZW -co ZLEVEL=9  LST_MYD_akima_day209_allobs.tif LST_MYD_akima_day209_allobs_crop.tif
# gdal_translate -projwin 65.0000000  33.0000000 98.0000000   7.9166667 -co COMPRESS=LZW -co ZLEVEL=9  LST_MYD_akima_day209_allobs.tiforig LST_MYD_akima_day209_allobs_crop.tiforig

# pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -msknodata 0 -nodata -1  -i LST_MYD_akima_day209_allobs_crop.tif  -m /nobackupp8/gamatull/dataproces/LST/MASK/IndiaMya_maskLargWeight.tif  -o LST_MYD_akima_day209_allobs_cropMask.tif
# pksetmask   -co COMPRESS=LZW -co ZLEVEL=9  -msknodata 0  -nodata -1 -i LST_MYD_akima_day209_allobs_crop.tiforig  -m /nobackupp8/gamatull/dataproces/LST/MASK/IndiaMya_maskLargWeight.tif  -o   LST_MYD_akima_day209_allobs_cropMask.tiforig

# gdalbuildvrt  -separate   -overwrite pkstat.vrt LST_MYD_akima_day209_allobs_cropMask.tif   LST_MYD_akima_day209_allobs_cropMask.tiforig
# pkstat --regerr -i pkstat.vrt -b 0 -b 1 -nodata -1 

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=24:model=has
#PBS -l walltime=2:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr
#PBS -N sc8_maskoutIndia-Patag_merge.sh 

echo /u/gamatull/scripts/LST/spline/sc8_maskoutIndia-Patag_merge.sh 

export  SENS=${SENS}
export  DN=${DN}

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_splinefill_merge
export RAM=/dev/shm



cleanram 

if [[ $DN = Day ]] ; then
echo 153 161 169 177 185 193 201 209 217 225 | xargs -n 1 -P 24 bash -c $' 
DAY=$1

rm -f $RAM/allobs${DAY}.vrt  
gdalbuildvrt  -separate   -overwrite $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_Fill5obs_maskoutIndia.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_Fill5obs.tif  /nobackupp8/gamatull/dataproces/LST/MASK/globeIndiaMya_maskLargWeight.tif 

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif <<EOF
1
#1 #3 *
EOF

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif 
rm -f $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif <<EOF
1
1 #3 - #2 *
EOF

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif
rm -f $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif

gdalbuildvrt  -separate   -overwrite $RAM/sum${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif 
oft-calc  $RAM/sum${DAY}.vrt   $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif <<EOF
1
#1 #2 + 
EOF

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_MskIndia.tif
rm -f  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif

' _ 

fi 

if [[ $DN = Nig ]] ; then

cat /nobackup/gamatull/dataproces/LST/geo_file/list_day_Pat$SENS.txt /nobackup/gamatull/dataproces/LST/geo_file/list_day_India.txt | sort | uniq -c | xargs -n 2 -P 24 bash -c $' 
MSK=$1
DAY=$2

if [[ $MSK = 1 ]] ; then 

ININD=$(grep $DAY /nobackup/gamatull/dataproces/LST/geo_file/list_day_India.txt) 
if [[ -n $ININD ]]  ; then FILEMSK=/nobackupp8/gamatull/dataproces/LST/MASK/globeIndiaMya_maskLargWeight.tif  ; fi 

INPAT=$(grep $DAY /nobackup/gamatull/dataproces/LST/geo_file/list_day_Pat$SENS.txt) 
if [[ -n $INPAT  ]]  ; then FILEMSK=/nobackupp8/gamatull/dataproces/LST/MASK/patagonia_maskLargWeight.tif  ; fi 

fi 

if [[ $MSK = 2 ]] ; then 
FILEMSK=/nobackupp8/gamatull/dataproces/LST/MASK/PatInd_maskLargWeight.tif 
fi 

rm -f $RAM/allobs${DAY}.vrt      
gdalbuildvrt -separate -overwrite $RAM/allobs${DAY}.vrt $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_Fill5obs_maskoutIndia.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_Fill5obs.tif  $FILEMSK

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif <<EOF
1
#1 #3 *
EOF

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif 
rm -f $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tmtmp.tif

oft-calc  $RAM/allobs${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif <<EOF
1
1 #3 - #2 *
EOF

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif
rm -f $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmtmp.tif

gdalbuildvrt  -separate   -overwrite $RAM/sum${DAY}.vrt  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif 
oft-calc  $RAM/sum${DAY}.vrt   $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif <<EOF
1
#1 #2 + 
EOF

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_MskIndia.tif
rm -f  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tmfinaltmp.tif  $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobsorig_tm.tif $OUTSENS/LST_${SENS}_akima_${DN}_day${DAY}_allobs_tm.tif

' _ 

fi 

rm $OUTSENS/*.eq
cleanram



qsub  -v SENS=$SENS,DN=$DN  /u/gamatull/scripts/LST/spline/sc9_spline15_IndPat_MOYD11A2.sh 