
# solo fatto il co iniziare il calcolo della varianza nel temporal domain

 

# for DAY in $(cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt  ) ; do qsub -v DAY=$DAY,SENS=MOD /u/gamatull/scripts/LST/preprocess/sc2_meanSD_yesQC_MOYD11A2.sh  ; done

# for Nr in $(seq 27 27 ) ; do qsub -v Nr=$Nr /u/gamatull/scripts/LST/preprocess/sc2_meanSD_yesQC_MOYD11A2.sh  ; done 

# temp_wind=5 ; (tail -$temp_wind  /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; cat /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt ; head -$temp_wind /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt) > /nobackup/gamatull/dataproces/LST/geo_file/list_day_replicate$temp_wind.txt

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=16
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr

Nr=27

export IN2SENS=/nobackupp6/aguzman4/climateLayers/???11A2.005/???11A2
export INMYD=/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2
export INMOD=/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2
export OUTMOD=/nobackupp8/gamatull/dataproces/LST/MOD11A2_mean_sdmsk
export OUTMOD=/nobackupp8/gamatull/dataproces/LST/MYD11A2_mean_sdmsk

export RAMDIR=/dev/shm

# rm -f $RAMDIR/*


echo start the pkcomposite for $DAY $SENS

echo 0         0 5400 10800 a  >  $RAMDIR/tiles_xoff_yoff.txt
echo 5400      0 5400 10800 b  >> $RAMDIR/tiles_xoff_yoff.txt
echo 10800     0 5400 10800 c  >> $RAMDIR/tiles_xoff_yoff.txt
echo 16200     0 5400 10800 d  >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600     0 5400 10800 e  >> $RAMDIR/tiles_xoff_yoff.txt
echo 30000  7000 1400 1800 f  >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400     0 5400 10800 g  >> $RAMDIR/tiles_xoff_yoff.txt
echo 37800     0 5400 10800 h  >> $RAMDIR/tiles_xoff_yoff.txt
echo 0      10800 5400 10800 i  >> $RAMDIR/tiles_xoff_yoff.txt
echo 5400   10800 5400 10800 l  >> $RAMDIR/tiles_xoff_yoff.txt
echo 10800  10800 5400 10800 m  >> $RAMDIR/tiles_xoff_yoff.txt
echo 16200  10800 5400 10800 n  >> $RAMDIR/tiles_xoff_yoff.txt
echo 21600  10800 5400 10800 o  >> $RAMDIR/tiles_xoff_yoff.txt
echo 27000  10800 5400 10800 p  >> $RAMDIR/tiles_xoff_yoff.txt
echo 32400  10800 5400 10800 q  >> $RAMDIR/tiles_xoff_yoff.txt
echo 37800  10800 5400 10800 r  >> $RAMDIR/tiles_xoff_yoff.txt

export temp_wind=5
export start_wind=$(expr $Nr  )
export end_wind=$(expr $temp_wind + $Nr + $temp_wind  )
export DAY=$( awk -v Nr=$Nr  '{ if (NR==Nr)  print $1  }'  /nobackup/gamatull/dataproces/LST/geo_file/list_day.txt )


echo start_wind  $start_wind  DAY $DAY  end_wind     $end_wind

awk  -v start_wind=$start_wind -v end_wind=$end_wind  '{ if ( NR>=start_wind  &&  NR<=end_wind) print $1 }' /nobackup/gamatull/dataproces/LST/geo_file/list_day_replicate$temp_wind.txt  | xargs  -n 1 bash -c $'  ls   $IN2SENS/????/???11A2.A2???$1.tif  ' _  > $RAMDIR/listfile.txt 

head -6  $RAMDIR/tiles_xoff_yoff.txt  | tail -1   | xargs -n 5 -P 16 bash -c $' 

export xoff=$1
export yoff=$2
export xsize=$3
export ysize=$4
export tile=$5

# cat $RAMDIR/listfile.txt   | xargs -n 1 -P 24 bash -c $\'
# file=$1
# filename=$(basename $file .tif)
# gdal_translate    -co  COMPRESS=LZW -co ZLEVEL=9   -srcwin  $xoff $yoff $xsize $ysize   $file   $RAMDIR/${filename}_tile${tile}.tif
# \' _ 

echo start the pcomposite sens ${SENS} day ${DAY} tile ${tile}

# # -b not usede if not the b2 can not be used   see fir qc /nobackupp8/gamatull/dataproces/LST/MYD11A2/QC_decimal_bynary.txt 
# #  in this case  -bndnodata 1 e la 2 banda

echo start the composite 
rm -f  $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.vrt 
gdalbuildvrt -b 1  -overwrite -separate $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.vrt $( ls  $RAMDIR/???11A2.A2??????_tile${tile}.tif  ) 

# pkcomposite $( ls  $RAMDIR/???11A2.A2??????_tile${tile}.tif  | xargs -n 1 echo -i )  -file 1  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0  -bndnodata 1 \
# -srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.tif 


# pkcomposite $( ls  $RAMDIR/???11A2.A2??????_tile${tile}.tif  | xargs -n 1 echo -i  )  -file 1  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr stdev  -dstnodata 0  -bndnodata 1 \
# -srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_2SENS_sd_day${DAY}_tile${tile}.tif 

# pkcomposite $( ls  $RAMDIR/MYD11A2.A2???${DAY}_tile${tile}.tif   | xargs -n 1 echo -i )  -file 1  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0  -bndnodata 1 \
# -srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif

rm -f  $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.vrt
gdalbuildvrt -b 1  -overwrite -separate $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.vrt  $( ls  $RAMDIR/MYD11A2.A2???${DAY}_tile${tile}.tif ) 

# pkcomposite $( ls  $RAMDIR/MOD11A2.A2???${DAY}_tile${tile}.tif   | xargs -n 1 echo -i )  -file 1  -ot Float32   -co  COMPRESS=LZW -co ZLEVEL=9  -cr mean -dstnodata 0  -bndnodata 1 \
# -srcnodata 2 -srcnodata 3  -srcnodata  193 -srcnodata 209 -srcnodata 225       -o $RAMDIR/LST_MOD_mean_day${DAY}_tile${tile}.tif 

# rm -f $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}.vrt 
# gdalbuildvrt -overwrite -separate  $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}.vrt    $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.tif -b 1 $RAMDIR/LST_2SENS_sd_day${DAY}_tile${tile}.tif  -b 1 $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif -b 1 

# rm -f $RAMDIR/LST_stackMOD_day${DAY}_tile${tile}.vrt
# gdalbuildvrt -overwrite -separate  $RAMDIR/LST_stackMOD_day${DAY}_tile${tile}.vrt    $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.tif -b 1 $RAMDIR/LST_2SENS_sd_day${DAY}_tile${tile}.tif  -b 1 $RAMDIR/LST_MOD_mean_day${DAY}_tile${tile}.tif -b 1 

# pkgetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -min 10 -max 10000000 -b 1   -i $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif   -o $RAMDIR/LST_MYD_meanMSK_day${DAY}_tile${tile}.tif

# oft-calc -ot Float32  -um $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif   $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}.vrt $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt.tif <<EOF
# 1
#2 1 #1 * + #3 > 1 2 ? # 
# EOF


gdal_calc.py --type=Float32 --overwrite -A $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.tif --A_band 1 -B $RAMDIR/LST_2SENS_sd_day${DAY}_tile${tile}.tif --B_band 1 -C $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif --C_band 1 \
--calc="( (A - ( B * 2 ) ) - C )"  --outfile $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt.tif 

pkgetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -min 0.0001 -max 100000  -data 255   -nodata 0  -max -0.0001 -min -100000  -data  100 -nodata 0      -i  $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt.tif  -o   $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt_b.tif 

# pksetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -i $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt_b.tif -m $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif -msknodata 1 -p "<"  -nodata 0  -o $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt_bmsk.tif


gdal_calc.py --type=Float32 --overwrite -A $RAMDIR/LST_2SENS_mean_day${DAY}_tile${tile}.tif --A_band 1 -B $RAMDIR/LST_2SENS_sd_day${DAY}_tile${tile}.tif --B_band 1 -C $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif --C_band 1 \
--calc="( (A + ( B * 1 ) ) - C )"  --outfile $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt.tif 

pkgetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -min 0.0001 -max 100000  -data 255   -nodata 0  -max -0.0001 -min -100000  -data  100 -nodata 0      -i  $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt.tif  -o   $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt_b.tif 

# pksetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9  -i $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt_b.tif -m $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif -msknodata 1 -p "<"  -nodata 0  -o $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}gt_bmsk.tif

# pksetmask -ot Byte  -co  COMPRESS=LZW -co ZLEVEL=9   -i $RAMDIR/LST_MOD_mean_day${DAY}_tile${tile}.tif  -m $RAMDIR/LST_MOD_mean_day${DAY}_tile${tile}.tif -msknodata 1 -p "<"   -nodata 1  -o $RAMDIR/LST_MOD_meanMSK_day${DAY}_tile${tile}.tif

# oft-calc -inv   -ot Float32  -um $RAMDIR/LST_MYD_mean_day${DAY}_tile${tile}.tif  $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}.vrt $RAMDIR/LST_stackMYD_day${DAY}_tile${tile}lt.tif <<EOF
# 1
# #2 2 * #1 - #3 - 
# EOF


' _


exit 




rm -f $RAMDIR/tiles_xoff_yoff.txt

gdalbuildvrt  -overwrite  -b 1 -b 3      $RAMDIR/LST_${SENS}_QC_day${DAY}.vrt      $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif
gdal_translate  -srcwin 0 0 43200 21600     -co  COMPRESS=LZW -co ZLEVEL=9  $RAMDIR/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/LST_${SENS}_QC_day$DAY.tif 
rm -f $RAMDIR/LST_${SENS}_QC_day${DAY}_tile?.tif

echo warp the lst  yes qc

gdalbuildvrt  -overwrite  -b 1  $OUTSENS/LST_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  

gdalwarp  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90  -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day$DAY.vrt     $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif 
rm -f $OUTSENS/LST_${SENS}_QC_day$DAY.vrt  

gdalwarp  -srcnodata 0 -dstnodata 0  -t_srs EPSG:4326  -r average  -te -180 -90 +180 +90 -tr 0.08333333333333 0.08333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif

gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif     $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif
gdal_translate -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10.tif
rm -f $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84t.tif   $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84k10t.tif 

echo warp the obs yes  qc

gdalbuildvrt  -overwrite  -b 2  $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $OUTSENS/LST_${SENS}_QC_day${DAY}.tif  
gdalwarp  -srcnodata 0 -dstnodata 0   -t_srs EPSG:4326  -r near  -te -180 -90 +180 +90   -tr 0.008333333333333 0.008333333333333   -multi  -overwrite -co BIGTIFF=YES  -co  COMPRESS=LZW -co ZLEVEL=9    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt

gdal_translate -ot Byte   -co  COMPRESS=LZW -co ZLEVEL=9    $RAMDIR/OBS_${SENS}_QC_day${DAY}_wgs84.tif  $OUTSENS/OBS_${SENS}_QC_day${DAY}_wgs84.tif

rm -f  $RAMDIR/*.tif $OUTSENS/LST_${SENS}_QC_day$DAY.vrt    $OUTSENS/OBS_${SENS}_QC_day$DAY.vrt   
