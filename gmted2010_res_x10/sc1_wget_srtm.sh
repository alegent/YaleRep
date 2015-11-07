


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles

# downlad the data 
echo $(for x in $(seq 0 9) ; do  for y in $(seq 0 9) ; do echo 0${x}_0$y ; done ; done ; for x in $(seq 10 72) ; do  for y in $(seq  10  24) ; do echo ${x}_$y ; done ; done ) | xargs  -n 1  -P 4  bash -c $' wget   http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_${1}.zip -q   ' _


ls   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/srtm_??_??.zip  |  xargs  -n 1  -P 4  bash -c $'
file=$1
rm -f  $filename.tfw   $filename.hdr  $filename.tif 
unzip -o  $1 
filename=$(basename $1 .zip)
gdal_translate  -co COMPRESS=LZW  -co ZLEVEL=9   $filename.tif tmp_$filename.tif
mv tmp_$filename.tif $filename.tif
rm -f  $filename.tfw   $filename.hdr 
' _ 


export RAM=/dev/shm 