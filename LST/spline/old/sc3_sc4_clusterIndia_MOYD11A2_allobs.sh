# growing the lst of 1 pixel
# qsub  -v SENS=MYD  /u/gamatull/scripts/LST/spline/sc3_sc4_clusterIndia_MOYD11A2_allobs.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=23
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo   /u/gamatull/scripts/LST/spline/sc3_sc4_clusterIndia_MOYD11A2_allobs.sh 
export SENS=$1
export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTBOL=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_cluster
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm

rm -f /dev/shm/*

echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249  | xargs -n 1 -P  23   bash -c $'   
DAY=$1
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5   $OUTBOL/LST_${SENS}_QC_day${DAY}_wgs84_allobsBolean.tif   $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBolean.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5   $INSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif                 $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif 

pksetmask -co COMPRESS=LZW -co ZLEVEL=9   -i    /nobackupp8/gamatull/dataproces/LST/MASK/mask_4cluster2.tif  -msknodata 0 -nodata  0  -m   $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBolean.tif -o $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif

pksetmask  -co COMPRESS=LZW -co ZLEVEL=9 -msknodata 0 -nodata  0  -m $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif -i  $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif -o  $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif

stdev=$( pkstat -b 0   --nodata 0  -stats -i $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif  2> /dev/null  | awk \'{ print $8  }\' )
mean=$(  pkstat -b 0   --nodata 0  -stats -i $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif  2> /dev/null   | awk \'{ print $6  }\' )

echo normalize the  $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif 

oft-calc -ot Float32  -um $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif $OUTSENS/normindiaLST_${SENS}_QC_day${DAY}_wgs84.tif  > /dev/null <<EOF
1
#1 $mean - $stdev /
EOF
rm -f $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif.eq
' _



# echo start the composite   start the composite start the composite start the composite start the composite start the composite start the composite 

# pkcomposite -srcnodata  0 -cr stdev  $( ls $OUTSENS/indiaLST_${SENS}_QC_day???_wgs84.tif  | xargs -n 1 echo -i ) -o $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif
# pkcomposite -srcnodata  0 -cr minband    $( ls $OUTSENS/indiaLST_${SENS}_QC_day???_wgs84.tif  | xargs -n 1 echo -i ) -o $OUTSENS/indiaLSTmin_${SENS}_QC_day137_249_wgs84.tif 
# pkcomposite -srcnodata  0 -cr maxband    $( ls $OUTSENS/indiaLST_${SENS}_QC_day???_wgs84.tif  | xargs -n 1 echo -i ) -o $OUTSENS/indiaLSTmax_${SENS}_QC_day137_249_wgs84.tif  
# pkcomposite -srcnodata  0 -cr mean   $( ls $OUTSENS/indiaLST_${SENS}_QC_day???_wgs84.tif  | xargs -n 1 echo -i ) -o $OUTSENS/indiaLSTmean_${SENS}_QC_day137_249_wgs84.tif  

# echo  range 
# rm -f $RAMDIR/${SENS}_range.vrt 
# gdalbuildvrt -overwrite -separate $RAMDIR/${SENS}_range.vrt    $OUTSENS/indiaLSTmax_${SENS}_QC_day137_249_wgs84.tif    $OUTSENS/indiaLSTmin_${SENS}_QC_day137_249_wgs84.tif 
# oft-calc -ot Float32  -um  $OUTSENS/indiaLSTmax_${SENS}_QC_day137_249_wgs84.tif $RAMDIR/${SENS}_range.vrt  $OUTSENS/indiaLSTrange_${SENS}_QC_day137_249_wgs84.tif   <<EOF
# 1
# #1 #2 -
# EOF
# rm -f $OUTSENS/indiaLSTrange_${SENS}_QC_day137_249_wgs84.tif.eq 

# echo  cv 
# rm -f $RAMDIR/${SENS}_cv.vrt 
# gdalbuildvrt -overwrite -separate $RAMDIR/${SENS}_cv.vrt    $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif    $OUTSENS/indiaLSTmean_${SENS}_QC_day137_249_wgs84.tif
# oft-calc -ot Float32  -um  $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif $RAMDIR/${SENS}_cv.vrt  $OUTSENS/indiaLSTcv_${SENS}_QC_day137_249_wgs84.tif   > /dev/null <<EOF
# 1
# #1 #2 /
# EOF
# rm -f  $OUTSENS/indiaLSTcv_${SENS}_QC_day137_249_wgs84.tif.eq 

# echo stdev range cv stdev range cv normalization stdev range cv normalization stdev range cv normalizationstdev range cv normalization stdev range cv normalization stdev range cv normalization
# echo stdev range cv stdev range cv normalization stdev range cv normalization stdev range cv normalizationstdev range cv normalization stdev range cv normalization stdev range cv normalization
# echo stdev range cv stdev range cv normalization stdev range cv normalization stdev range cv normalizationstdev range cv normalization stdev range cv normalization stdev range cv normalization
# echo stdev range cv stdev range cv normalization stdev range cv normalization stdev range cv normalizationstdev range cv normalization stdev range cv normalization stdev range cv normalization

# echo stdev range cv | xargs -n 1 -P 3 bash -c $' 
# PRED=$1

# stdev_var=$( pkstat -b 0   --nodata  0  -stats -i $OUTSENS/indiaLST${PRED}_${SENS}_QC_day137_249_wgs84.tif 2> /dev/null   | awk \'{ print $8  }\' ) 
# mean_var=$(  pkstat -b 0   --nodata  0  -stats -i $OUTSENS/indiaLST${PRED}_${SENS}_QC_day137_249_wgs84.tif 2> /dev/null   | awk \'{ print $6  }\' ) 

# oft-calc -ot Float32 -um $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif $OUTSENS/indiaLST${PRED}_${SENS}_QC_day137_249_wgs84.tif $OUTSENS/normindiaLST${PRED}_${SENS}_QC_day137_249_wgs84.tif > /dev/null <<EOF
# 1
# #1 $mean_var - $stdev_var /
# EOF
# rm -f $OUTSENS/indiaLST${PRED}_${SENS}_QC_day137_249_wgs84.tif.eq 
# ' _ 

# echo compute the day - mean of the other sensor 

# echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249  | xargs -n 1 -P  23   bash -c $'
# DAY=$1

# if [ $SENS = MYD ] ; then OTHER="MOD" ; fi 
# if [ $SENS = MOD ] ; then OTHER="MYD" ; fi 
# rm -f  $RAMDIR/indiaLST_${SENS}_minusmean_day${DAY}.vrt 
# gdalbuildvrt -overwrite -separate $RAMDIR/indiaLST_${SENS}_minusmean_day${DAY}.vrt  $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84.tif  /nobackupp8/gamatull/dataproces/LST/${OTHER}11A2_cluster/indiaLSTmean_${OTHER}_QC_day137_249_wgs84.tif 
# oft-calc -ot Float32 -um $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif $RAMDIR/indiaLST_${SENS}_minusmean_day${DAY}.vrt  $OUTSENS/indiaLST_${SENS}_minusmean_day${DAY}.tif  > /dev/null <<EOF
# 1
# #1 #2 - 
# EOF
# rm -r $OUTSENS/indiaLST_${SENS}_minusmean_day${DAY}.tif.eq

# stdev_var=$(  pkstat -b 0   --nodata  0  -stats -i  $OUTSENS/indiaLST_${SENS}_minusmean_day${DAY}.tif  2> /dev/null  | awk \'{ print $8  }\' )
# mean_var=$(  pkstat -b 0   --nodata  0  -stats -i  $OUTSENS/indiaLST_${SENS}_minusmean_day${DAY}.tif  2> /dev/null  | awk \'{ print $6  }\' )

# echo 

# oft-calc -ot Float32 -um $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif $OUTSENS/indiaLST_${SENS}_minusmean_day${DAY}.tif   $OUTSENS/normindiaLST_${SENS}_minusmean_day${DAY}.tif > /dev/null  <<EOF
# 1
# #1 $mean_var - $stdev_var /
# EOF
# rm -f $OUTSENS/normindiaLST_${SENS}_minusmean_day${DAY}.tif.eq
# ' _ 

# # echo  crop the digital elevation model
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/elevation_md_GMTED2010_md.tif  $OUTSENS/indiaelevation_md_GMTED2010_md.tif
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/aspect-cosine_md_GMTED2010_md.tif  $OUTSENS/indiaaspect-cosine_md_GMTED2010_md.tif
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/aspect-sine_md_GMTED2010_md.tif    $OUTSENS/indiaaspect-sine_md_GMTED2010_md.tif
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/eastness_md_GMTED2010_md.tif       $OUTSENS/indieastness_md_GMTED2010_md.tif
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/northness_md_GMTED2010_md.tif      $OUTSENS/northness_md_GMTED2010_md.tif
# # gdal_translate -ot Float32 -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5 /nobackupp8/gamatull/dataproces/GMTED2010/slope_md_GMTED2010_md.tif          $OUTSENS/slope_md_GMTED2010_md.tif

# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indiaelevation_md_GMTED2010_mdmsk.tif  -i $OUTSENS/indiaelevation_md_GMTED2010_md.tif
# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indiaaspect-cosine_md_GMTED2010_mdmsk.tif  -i $OUTSENS/indiaaspect-cosine_md_GMTED2010_md.tif
# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indiaaspect-sine_md_GMTED2010_mdmsk.tif    -i $OUTSENS/indiaaspect-sine_md_GMTED2010_md.tif
# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indieastness_md_GMTED2010_mdmsk.tif        -i $OUTSENS/indieastness_md_GMTED2010_md.tif
# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indianorthness_md_GMTED2010_mdmsk.tif           -i $OUTSENS/northness_md_GMTED2010_md.tif
# # pksetmask  -m $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif   -msknodata 0  -nodata -9999 -o $OUTSENS/indiaslope_md_GMTED2010_mdmsk.tif               -i $OUTSENS/slope_md_GMTED2010_md.tif

# # echo Normalize the GMTED

# # ls  $OUTSENS/india*GMTED2010_mdmsk.tif  | xargs -n 1 -P 10 bash -c $' 
# # file=$1

# # stdev_var=$( pkstat -b 0   --nodata -9999  -stats -i $file  2> /dev/null   | awk \'{ print $8  }\' ) 
# # mean_var=$(  pkstat -b 0   --nodata -9999  -stats -i $file  2> /dev/null   | awk \'{ print $6  }\' ) 

# # oft-calc -ot Float32 -um $OUTSENS/indiaLSTstdev_${SENS}_QC_day137_249_wgs84.tif $file  $OUTSENS/norm$(basename $file) > /dev/null <<EOF
# # 1
# # #1 $mean_var - $stdev_var /
# # EOF
# # rm -f $OUTSENS/norm$(basename $file).eq
# # ' _ 


echo CLUSTER  CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER 
echo CLUSTER  CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER 
echo CLUSTER  CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER CLUSTER 

echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249  | xargs -n 1 -P  20   bash -c $'
DAY=$1     
echo extract the training  $DAY     

oft-gengrid-latlong.bash   $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif  1 1  $RAMDIR/india${SENS}_day${DAY}_Bolean_mask_training.txt 
oft-extr -o $RAMDIR/india${SENS}_day${DAY}_Bolean_spec_mask_training.txt  $RAMDIR/india${SENS}_day${DAY}_Bolean_mask_training.txt   $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif    <<EOF
2
3
EOF

echo cleaning the training 

paste -d " " <(awk \'{ print $2, $3}\' $RAMDIR/india${SENS}_day${DAY}_Bolean_mask_training.txt   ) <(awk \'{ print $6}\' $RAMDIR/india${SENS}_day${DAY}_Bolean_spec_mask_training.txt ) | awk \'{ if ($3==1) print $1 , $2 }\' > $RAMDIR/india${SENS}_day${DAY}_Bolean_training.txt

# echo extract the stack layer

# stack the layer 
rm -f $RAMDIR/stack_${SENS}_QC_day${DAY}.vrt
gdalbuildvrt -separate $RAMDIR/stack_${SENS}_QC_day${DAY}.vrt  $OUTSENS/normindiaLST_${SENS}_QC_day${DAY}_wgs84.tif   $OUTSENS/normindiaLSTrange_${SENS}_QC_day137_249_wgs84.tif #  $OUTSENS/normindiaLST_${SENS}_minusmean_day${DAY}.tif # $OUTSENS/norm*GMTED2010_mdmsk.tif

gdal_translate  -projwin 65 35 100 5  -co BIGTIFF=YES -co COMPRESS=LZW -co ZLEVEL=9 $RAMDIR/stack_${SENS}_QC_day${DAY}.vrt $RAMDIR/stack_${SENS}_QC_day${DAY}.tif

oft-extr -o  $RAMDIR/india${SENS}_day${DAY}_stack_training.txt       $RAMDIR/india${SENS}_day${DAY}_Bolean_training.txt      $RAMDIR/stack_${SENS}_QC_day${DAY}.tif            <<EOF
1
2
EOF

echo clastering the image
CLASS=8

oft-kmeans -um $OUTSENS/indiaLST_${SENS}_QC_day${DAY}_wgs84_allobsBoleanSmall.tif  -ot Byte -o $OUTSENS/indiaCluster_${SENS}_QC_day${DAY}.tif  -i $RAMDIR/stack_${SENS}_QC_day${DAY}.tif   <<EOF
$RAMDIR/india${SENS}_day${DAY}_stack_training.txt
$CLASS
EOF

pkcreatect -min 0 -max $CLASS > /tmp/color.txt 
pkcreatect -co COMPRESS=LZW -co ZLEVEL=9 -ct /tmp/color.txt -i $OUTSENS/indiaCluster_${SENS}_QC_day${DAY}.tif   -o $OUTSENS/indiaClusterCT_${SENS}_QC_day${DAY}.tif
# rm -f $RAMDIR/stack_${SENS}_QC_day${DAY}.tif
' _ 

rm -f $OUTSENS/*.eq


exit 



gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9   -projwin  65 35 100 5   ../MOD11A2_mean_msk/MOD_LST3k_mask_daySUM_wgs84_allobs.tif  indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif




