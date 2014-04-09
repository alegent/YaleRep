# run before the xargs 
# cd /mnt/data2/scratch/GMTED2010/MODALB/
# tar xvf 0.3_5.0.um.00-04.WS.c004.v2.0.tar  
# cd 0.3_5.0.um.00-04.WS.c004.v2.0 
# for file in *.gz ; do echo $file ; gunzip $file ; done
# INDIR=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0 
#  ls  $INDIR/*.hdf  | xargs -n 1 -P 8 bash /mnt/data2/scratch/GMTED2010/scripts/sc1_convert_hdf.sh


INDIR=/mnt/data2/scratch/GMTED2010/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0
cd $INDIR

file=$1
echo $file 

filename=$(basename $file .hdf)

# this actino create a
# Upper Left  (-179.9916687,  89.9916687) 
# Lower Left  (-179.9916687, -89.9916611) 
# Upper Right ( 179.9916687,  89.9916687) 
# Lower Right ( 179.9916687, -89.9916611)
# gdal_translate  -of AAIGrid   HDF4_SDS:UNKNOWN:"${filename}.hdf":1    ${filename}_X.asc
# gdal_translate  -of AAIGrid   HDF4_SDS:UNKNOWN:"${filename}.hdf":0    ${filename}_Y.asc
# rm ${filename}_X.asc.aux.xml   ${filename}_Y.asc.aux.xml 

# ulx=$(awk '{  if (NR==6) print $1  }'  ${filename}_X.asc)
# lrx=$(awk '{  if (NR==6) print $NF }'  ${filename}_X.asc)

# uly=$(awk '{  if (NR==6) print $1  }'  ${filename}_Y.asc)
# lry=$(awk '{  if (NR==6) print $NF  }' ${filename}_Y.asc)

# so in the end decide to run as fix paramaters 

ulx=-180
lrx=+180

uly=+90
lry=-90

gdal_translate   -a_nodata 32767 -a_srs EPSG:4326  -ot Int16    -co COMPRESS=LZW  -co ZLEVEL=9 -a_ullr $ulx $uly $lrx $lry $file  $INDIR/$filename.tif 


