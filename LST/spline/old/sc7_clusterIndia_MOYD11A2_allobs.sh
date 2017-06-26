
# oft-calc -ot Byte indiaLST_MOD_akima_day185.tif mask.tif  <<EOF
# 1
# #1 1 > 0 1 ?
# EOF

# stdev=$( pkstat -b 0   --nodata  0  -stats -i indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif  | awk '{ print $8  }' ) 
# mean=$( pkstat -b 0   --nodata  0  -stats -i indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif  | awk '{ print $6  }' ) 

# oft-calc -ot Float32  -um mask.tif  indiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif  normindiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif   > /dev/null <<EOF
# 1
# #1 $mean - $stdev /
# EOF


# stdev=$( pkstat -b 0  --nodata  0  -stats -i  stdev.tif  | awk '{ print $8  }' ) 
# mean=$( pkstat  -b 0  --nodata  0  -stats -i  stdev.tif  | awk '{ print $6  }' ) 

# oft-calc -ot Float32  -um mask.tif  stdev.tif   normstdev.tif   > /dev/null <<EOF
# 1
# #1 $mean - $stdev /
# EOF


# ls indiaLST_MOD_akima_day???.tif   | xargs -n 1 -P 16 bash -c $'
# file=$1
# filename=`basename $file .tif`
# stdev=$( pkstat -b 0   --nodata -1  -stats -i $file  | awk \'{ print $8  }\' )
# mean=$( pkstat -b 0   --nodata  -1  -stats -i $file   | awk \'{ print $6  }\' )

# oft-calc -ot Float32  -um mask.tif  $file   norm$file   > /dev/null <<EOF
# 1
# #1 $mean - $stdev /
# EOF

# ' _

echo extract the training 

oft-gengrid-latlong.bash  mask.tif  100 100 mask_training.txt 
oft-extr -o spec_mask_training.txt  mask_training.txt mask.tif   <<EOF
2
3
EOF

echo cleaning the training 

paste -d " " <(awk '{ print $2, $3}' mask_training.txt  ) <(awk '{ print $6}' spec_mask_training.txt ) | awk '{ if ($3==1) print $1 , $2 }' > training.txt

# gdalbuildvrt -separate  stack.vrt  normindiaLST_MOD_akima_day177.tif  normindiaLST_MOD_akima_day185.tif normindiaLST_MOD_akima_day193.tif normindiaLST_MOD_akima_day201.tif  normindiaLST_MOD_akima_day209.tif  normindiaLST_MOD_akima_day217.tif normindiaLST_MOD_akima_day225.tif normindiaLST_MOD_akima_day233.tif normindiaLST_MOD_akima_day241.tif normstdev.tif normindiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif 

gdalbuildvrt -separate  stack.vrt   normindiaLST_MOD_akima_day209.tif  normstdev.tif  normindiaMOD_LST3k_mask_daySUM_wgs84_allobs.tif   

gdal_translate  -projwin 65 35 90 5  -co BIGTIFF=YES -co COMPRESS=LZW -co ZLEVEL=9 stack.vrt stack.tif 

echo extract the stack layer

oft-extr -o training_stack.txt training.txt stack.tif   <<EOF
1
2
EOF

echo clastering the image

oft-kmeans -um mask.tif -ot Byte -o cluster.tif -i stack.tif <<EOF
training_stack.txt
10
EOF

pkcreatect -min 1 -max 12 > /tmp/color.txt 

pkcreatect -co COMPRESS=LZW -co ZLEVEL=9 -ct /tmp/color.txt -i cluster.tif  -o cluster_ct.tif
