 
# for DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  ) ; do qsub -v DAY=$DAY,SENS=MOD /u/gamatull/scripts/LST/preprocess/sc2_mean_yesQCweight_MOYD11A2.sh  ; done

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=8
#PBS -l walltime=6:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

export DAY=MOD
export SENS=$SENS
export INSENS=/nobackupp6/aguzman4/climateLayers/${SENS}11A2.005/${SENS}11A2
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean

export RAMDIR=/dev/shm

rm -f $RAMDIR/*.tif 

echo start the pkcomposite for $DAY 

echo 0         0 10800 10800 a  > $RAMDIR/tiles_xoff_yoff.txt
echo 10800     0 10800 10800 b >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600     0 10800 10800 c >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400     0 10800 10800 d >> $RAMDIR/tiles_xoff_yoff.txt
echo 0     10800 10800 10800 e >> $RAMDIR/tiles_xoff_yoff.txt
echo 10800 10800 10800 10800 f >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600 10800 10800 10800 g >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400 10800 10800 10800 h >> $RAMDIR/tiles_xoff_yoff.txt

cat $RAMDIR/tiles_xoff_yoff.txt | head  | xargs -n 5 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4
tile=$5

for file in $INSENS/*/${SENS}11A2.A*${DAY}.tif ; do 

filename=$(basename $file .tif)
gdal_translate    -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize   $file   $RAMDIR/${filename}_tile${tile}.tif
done 

echo start the pcomposite sens ${SENS} day ${DAY} tile ${tile}

# -b not usede if not the b2 can not be used   see fir qc /nobackupp8/gamatull/dataproces/LST/MYD11A2/QC_decimal_bynary.txt 
#  in this case  -bndnodata 1 e la 2 banda

# Bit - LST Error - EMIS Error - Data Quality - Mandatory QA
# 2 00 00 00 10     Average LST error <= 1K   discarded 
# 3 00 00 00 11     Average LST error <= 1K   discarded 
# 17 00 01 00 01    Average LST error <= 1K   weight 3
# 33 00 10 00 01    Average LST error <= 1K   weight 3
# 65 01 00 00 01    Average LST error <= 2K   weight 2
# 81 01 01 00 01    Average LST error <= 2K   weight 2
# 97 01 10 00 01    Average LST error <= 2K   weight 2
# 129 10 00 00 01   Average LST error <= 3K   weight 1
# 145 10 01 00 01   Average LST error <= 3K   weight 1
# 161 10 10 00 01   Average LST error <= 3K   weight 1 
# 193 11 00 00 01   Average LST error > 3K    discarded 
# 209 11 01 00 01   Average LST error > 3K    discarded 
# 225 11 10 00 01   Average LST error > 3K    discarded 

# error <= 1K 
pkcomposite $(ls $RAMDIR/${SENS}11A2.A*${DAY}_tile${tile}.tif | xargs -n 1 echo -i )  -file   -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr sum -dstnodata 0  -bndnodata 1 \
-srcnodata 2 -srcnodata 3 -srcnodata 65 -srcnodata 81 -srcnodata 97 -srcnodata 129 -srcnodata 145 -srcnodata 161 -srcnodata 193 -srcnodata 209 -srcnodata 225 -o $RAMDIR/LST_${SENS}_QCw3_day${DAY}_tile${tile}.tif 

# error <= 2k
pkcomposite $(ls $RAMDIR/${SENS}11A2.A*${DAY}_tile${tile}.tif | xargs -n 1 echo -i )  -file   -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr sum -dstnodata 0  -bndnodata 1 \
-srcnodata 2 -srcnodata 3 -srcnodata 17 -srcnodata 33 -srcnodata 129 -srcnodata 145 -srcnodata 161 -srcnodata 193 -srcnodata 209 -srcnodata 225 -o $RAMDIR/LST_${SENS}_QCw2_day${DAY}_tile${tile}.tif  

# error <= 3k
pkcomposite $(ls $RAMDIR/${SENS}11A2.A*${DAY}_tile${tile}.tif | xargs -n 1 echo -i )  -file   -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr sum -dstnodata 0  -bndnodata 1 \
-srcnodata 2 -srcnodata 3 -srcnodata 17 -srcnodata 33 -srcnodata 65 -srcnodata 81 -srcnodata 97 -srcnodata 193 -srcnodata 209 -srcnodata 225 -o $RAMDIR/LST_${SENS}_QCw1_day${DAY}_tile${tile}.tif  

for W in 1 2 3 ; do 
oft-calc -ot Float32  $RAMDIR/LST_${SENS}_QCw${W}_day${DAY}_tile${tile}.tif $RAMDIR/LST_${SENS}_QCw${W}sum_day${DAY}_tile${tile}.tif  &> /dev/null <<EOF
2
#1 $W *
#3 $W *
EOF
done 

# rm 

gdal_calc.py  --NoDataValue=0 --overwrite  --type=Float32  --creation-option=COMPRESS=LZW  --co=ZLEVEL=9  -A $RAMDIR/LST_${SENS}_QCw1sum_day${DAY}_tile${tile}.tif  -B $RAMDIR/LST_${SENS}_QCw2sum_day${DAY}_tile${tile}.tif -C $RAMDIR/LST_${SENS}_QCw3sum_day${DAY}_tile${tile}.tif  -D $RAMDIR/LST_${SENS}_QCw1sum_day${DAY}_tile${tile}.tif -E $RAMDIR/LST_${SENS}_QCw2sum_day${DAY}_tile${tile}.tif -F $RAMDIR/LST_${SENS}_QCw3sum_day${DAY}_tile${tile}.tif  --A_band 1 --B_band 1 --C_band 1 --D_band 2   --E_band 2 --F_band 2 --calc="(( A + B + C ) / (D + E + F) )"  --outfile=   $OUTSENS/LST_${SENS}_QCweight_day$DAY.tif

' _ 

exit 

rm -f $RAMDIR/tiles_xoff_yoff.txt

gdalbuildvrt  -overwrite  -b 1 -b 3      $RAMDIR/LST_${SENS}_QC_day${DAY}.vrt      $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif
gdal_translate  -srcwin 0 0 43200 21600     -co  COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/LST_${SENS}_QC_day$DAY.tif 
rm -f $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif

echo warp the lst  yes qc

gdalbuildvrt  -overwrite  -b 1  $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  

gdalwarp -overwrite  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r cubic  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif 
rm -f $OUTSENS/LST_${SENS}_QC_day$DAY.vrt  
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif
rm -f $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif 

echo warp the obs yes  qc

gdalbuildvrt  -overwrite  -b 2  $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  
gdalwarp -overwrite   -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif
rm -f $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt

gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif  $OUTSENS/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f  $RAMDIR/*.tif $OUTSENS/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   
