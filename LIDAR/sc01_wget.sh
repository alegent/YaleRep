
# http://opentopo.sdsc.edu/datasetMetadata?otCollectionID=OT.042013.26919.1
# Coordinates System: 
#     Horizontal: UTM z19N NAD83 (CORS96) [EPSG: 26919] 
#     Vertical: NAVD88 (Geoid 03) [EPSG: 5703] 

wget --cut-dirs=3   -r -np -R "index.html*" https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/ME07_Snyder/

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26919' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26919' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dsm.tif dsm_wgs84.tif -overwrite 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dtm.tif dtm_wgs84.tif -overwrite 

# http://opentopo.sdsc.edu/datasetMetadata?otCollectionID=OT.012012.26919.2 


# Coordinates System: 
#     Horizontal: UTM n19 N NAD83 (CORS96) [EPSG: 26919] 
#     Vertical: NAVD88 (GEOID03) [EPSG: 5703] 


wget --cut-dirs=3   -r -np -R "index.html*" https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/NH09_Finkelman/
cd ~/tmp/lidar/cloud.sdsc.edu/NH09_Finkelman
for file in *.laz ; do filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file ; done

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26919' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26919' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dsm.tif dsm_wgs84.tif -overwrite 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dtm.tif dtm_wgs84.tif -overwrite 

gdal_translate  -srcwin 10 10 125 60   -co COMPRESS=DEFLATE -co ZLEVEL=9  dtm_wgs84.tif dtm_wgs84_crop.tif
gdal_translate  -srcwin 10 10 125 60   -co COMPRESS=DEFLATE -co ZLEVEL=9  dsm_wgs84.tif dsm_wgs84_crop.tif

# http://opentopo.sdsc.edu/datasetMetadata.jsp?otCollectionID=OT.052013.26912.2 

# Coordinates System: 
#     Horizontal: UTM z12 N NAD83 (CORS96) [EPSG: 26912] 
#     Vertical: NAVD88 (Geoid 03) [EPSG: 5703] 

wget --cut-dirs=3   -r -np -R "index.html*" https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/MT05_05Lorang/

cd  ~/tmp/lidar/cloud.sdsc.edu/MT05_05Lorang
for file in *.laz ; do filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file ; done

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26911' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26911' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

gdal_translate  -srcwin 10 10 145 99    -co COMPRESS=DEFLATE -co ZLEVEL=9  dtm_wgs84.tif dtm_wgs84_crop.tif 

# http://opentopo.sdsc.edu/datasetMetadata.jsp?otCollectionID=OT.012012.26911.1

# Coordinates System: 
#     Horizontal: UTM z11 N NAD83 (CORS96) [EPSG: 26911] 
#     Vertical: NAVD88 (GEOID03) [EPSG: 5703] 

wget --cut-dirs=3   -r -np -R "index.html*"  https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/ID09_Lloyd/
cd ~/tmp/lidar/cloud.sdsc.edu/ID09_Lloyd
for file in *.laz ; do filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file ; done

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26911' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26911' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dsm.tif dsm_wgs84.tif -overwrite 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dtm.tif dtm_wgs84.tif -overwrite 

gdal_translate  -srcwin 280  10  100 38     -co COMPRESS=DEFLATE -co ZLEVEL=9  dtm_wgs84.tif  dtm_wgs84_crop.tif
gdal_translate  -srcwin 280  10  100 38     -co COMPRESS=DEFLATE -co ZLEVEL=9  dsm_wgs84.tif  dsm_wgs84_crop.tif

# gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  $(getCorners4Gtranslate dsm_wgs84.tif )       /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/input_tif/all_tif.vrt  merit.tif 




# http://opentopo.sdsc.edu/datasetMetadata.jsp?otCollectionID=OT.032012.26911.3 

# Coordinates System: 
#     Horizontal: UTM z11N NAD83 [EPSG: 26911] 
#     Vertical: NAVD88 (GEOID03) [EPSG: 5703] 

wget --cut-dirs=3   -r -np -R "index.html*"  https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/OR07_MalheurNF/ 

cd ~/tmp/lidar/cloud.sdsc.edu/OR07_MalheurNF/ 

for file in *.laz ; do filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file ; done

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26911' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26911' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dsm.tif dsm_wgs84.tif -overwrite 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dtm.tif dtm_wgs84.tif -overwrite 

gdal_translate  -srcwin 40  146 100 50     -co COMPRESS=DEFLATE -co ZLEVEL=9  dtm_wgs84.tif  dtm_wgs84_crop.tif
gdal_translate  -srcwin 40  146 100 50     -co COMPRESS=DEFLATE -co ZLEVEL=9  dsm_wgs84.tif  dsm_wgs84_crop.tif



# http://opentopo.sdsc.edu/datasetMetadata.jsp?otCollectionID=OT.122015.26917.1


# Coordinates System: 
#     Horizontal: NAD83 (2011), UTM Zone 17N [EPSG: 26917] 
#     Vertical: NAVD88 (GEOID 12a) [EPSG: 5703] 

wget --cut-dirs=3   -r -np -R "index.html*"  https://cloud.sdsc.edu/v1/AUTH_opentopography/PC_Bulk/SC14_CZO/Part1/


cd ~/tmp/lidar/cloud.sdsc.edu/

for file in *.laz ; do filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file ; done

ls  *.laz | xargs -n 1 -P 3 bash -c $' file=$1 ;  filename=$(basename $file .laz )  ;  laszip -i $file    -o $filename.las ; rm $file  ' _


pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26917' -fir all -comp min -n z -dx 90 -dy 90  -ot Float32 
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26917' -fir all -comp max -n z -dx 90 -dy 90  -ot Float32

pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dsm.tif -a_srs 'epsg:26917' -fir all -comp percentile  -perc 95  -n z -dx 90 -dy 90  -ot Float32
pklas2img  -co COMPRESS=DEFLATE -co ZLEVEL=9   $(for file in *.las; do echo " -i "$file;done)    -o dtm.tif -a_srs 'epsg:26917' -fir all -comp percentile  -perc 5  -n z -dx 90 -dy 90  -ot Float32

gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dsm.tif dsm_wgs84.tif -overwrite 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear    dtm.tif dtm_wgs84.tif -overwrite 

gdal_translate  -srcwin 40  146 100 50     -co COMPRESS=DEFLATE -co ZLEVEL=9  dtm_wgs84.tif  dtm_wgs84_crop.tif
gdal_translate  -srcwin 40  146 100 50     -co COMPRESS=DEFLATE -co ZLEVEL=9  dsm_wgs84.tif  dsm_wgs84_crop.tif


# merge the differnt dsm and dtm 


gdalbuildvrt  dsm.vrt Part1/dsm.tif   Part2/dsm.tif Part3/dsm.tif Part4/dsm.tif Part5/dsm.tif 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear dsm.vrt  dsm_wgs84.tif -overwrite 

gdalbuildvrt  dtm.vrt Part1/dtm.tif   Part2/dtm.tif Part3/dtm.tif Part4/dtm.tif Part5/dtm.tif 
gdalwarp -tap  -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.000833333333333 0.000833333333333 -t_srs EPSG:4326 -r bilinear dtm.vrt  dtm_wgs84.tif -overwrite 

