# bsub -W 4:00 -n 4 -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc03_rasterize.sh.%J.out -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc03_rasterize.sh.%J.err bash /gpfs/home/fas/sbsc/ga254/scripts/NHDplus/sc03_rasterize.sh

# FCODE
# STREAM/RIVER  46000  feature type only: no attributes
# STREAM/RIVER  46003  Hydrographic Category|intermittent
# STREAM/RIVER  46006  Hydrographic Category|perennial
# STREAM/RIVER  46007  Hydrographic Category|ephemeral
# FType 460 
# FType 558   ARTIFICIAL PATH 

# NHDplus  https://nhd.usgs.gov/userGuide/Robohelpfiles/NHD_User_Guide/Feature_Catalog/Hydrography_Dataset/Complete_FCode_List.htm  

#   FTYPE (String) = ArtificialPath
#   FTYPE (String) = CanalDitch
#   FTYPE (String) = Connector
#   FTYPE (String) = Pipeline
#   FTYPE (String) = StreamRiver

export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NHDplus

echo rasteri the full network 
# rm -f $DIR/tmp/select.*  $DIR/tif/*.tif  /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/NHDplus/NHDplus_H_250m.tif 

# ls $DIR/shp/*/NHDFlowline.shp  | xargs -n 1 -P 4 bash -c  $'
# file=$1
#     dirname=$(basename $( dirname   $file ))  

#     ogr2ogr  -where  "FTYPE = \'ArtificialPath\' OR FTYPE = \'StreamRiver\' " $DIR/tmp/$dirname.shp  $file
#     gdal_rasterize  -ot  Byte -a_nodata 0   -co COMPRESS=DEFLATE -co ZLEVEL=9 -tap -tr  0.002083333333333 0.002083333333333    -burn 1  $DIR/tmp/$dirname.shp   $DIR/tif/$dirname.tif
#     rm  -f  $DIR/tmp/$dirname.{dbf,prj,shp,shp.xml,shx}
# ' _

# echo start to merge the file 

# gdalbuildvrt  -te  -126 25 -66 50.6312500  -overwrite   -srcnodata 0  -vrtnodata 0    -overwrite $DIR/output.vrt   $DIR/tif/*.tif

# pkcreatect  -co COMPRESS=DEFLATE -co ZLEVEL=9   -min 0 -max 1 -i     $DIR/output.vrt  -o     $DIR/NHDplus_H_250m.tif 
# rm $DIR/output.vrt 

echo raster river order number 1 
rm -f $DIR/tmp/select.*    $DIR/tif/*.tif    /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/NHDplus/NHDplus_H_250m_order1.tif 

ls $DIR/shp/*/NHDFlowline.shp  | xargs -n 1 -P 4 bash -c  $'
file=$1
    dirname=$(basename $( dirname   $file ))  

    ogr2ogr  -where  "StreamOrde = 1 " $DIR/tmp/${dirname}_tmp.shp  $file
    ogr2ogr  -where  "FTYPE = \'ArtificialPath\' OR FTYPE = \'StreamRiver\' " $DIR/tmp/$dirname.shp   $DIR/tmp/${dirname}_tmp.shp 
    gdal_rasterize  -ot  Byte -a_nodata 0   -co COMPRESS=DEFLATE -co ZLEVEL=9 -tap -tr  0.002083333333333 0.002083333333333    -burn 1  $DIR/tmp/$dirname.shp   $DIR/tif/$dirname.tif
    rm  -f  $DIR/tmp/$dirname.{dbf,prj,shp,shp.xml,shx}   $DIR/tmp/${dirname}_tmp.{dbf,prj,shp,shp.xml,shx}
' _

echo start to merge the file 

gdalbuildvrt  -te  -126 25 -66 50.6312500  -overwrite   -srcnodata 0  -vrtnodata 0    -overwrite $DIR/output.vrt   $DIR/tif/*.tif

pkcreatect  -co COMPRESS=DEFLATE -co ZLEVEL=9   -min 0 -max 1 -i     $DIR/output.vrt  -o     $DIR/NHDplus_H_250m_order1.tif 
rm $DIR/output.vrt 

