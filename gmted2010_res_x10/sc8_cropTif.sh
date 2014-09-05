

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/*/max/*.tif  | xargs -n 1 -P 8 bash -c $' file=$1 ;    gdal_translate  -projwin -180 +84  +180 -56     -co  COMPRESS=LZW -co ZLEVEL=9 $file ${file}f ;  gdal_edit.py -a_ullr  -180 +84  +180 -56   ${file}f  ; mv  ${file}f  ${file}  ' _ 


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/*/elevation_*_GMTED2010_*.tif   | xargs -n 1 -P 8 bash -c $' file=$1 ;    gdal_translate  -projwin -180 +84  +180 -56     -co  COMPRESS=LZW -co ZLEVEL=9 $file ${file}f ;  gdal_edit.py -a_ullr  -180 +84  +180 -56   ${file}f  ; mv  ${file}f  ${file}  ' _ 