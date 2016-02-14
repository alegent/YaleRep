
# qsub /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc1_wget_srtm.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=8:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/zip 

# downlad the data 
# quest sistema non download tutti 
# echo $( for x in $(seq 1 24 ) ; do  for y in $(seq 1 72) ; do echo ${x} ${y} ; done ; done   | awk '{ if ($1<10 ) {print 0 $1 , $2  } else { print $1 , $2 }  }'  | awk '{ if ($2<10 ) {print  $1  "_" 0  $2  } else { print $1 "_" $2 }  }' )  | xargs  -n 1  -P 8  bash -c $' 

# if [ ! -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/zip/srtm_${1}.zip   ] ; then 
# wget -w 5 --waitretry=4 --random-wait   http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_${1}.zip 
# fi 
#  ' _

# eseguito questo a mano 
# wget -r --no-parent --random-wait --timestamping -A.zip http://gis-lab.info/data/srtm-tif/
# 872  files  
# confermato by 
# wget -O -    -A.zip http://gis-lab.info/data/srtm-tif/ |   grep  zip    | wc -l


ls   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/zip/srtm_??_??.zip  |  xargs  -n 1  -P 8  bash -c $'
file=$1
rm -f  $filename.tfw   $filename.hdr  $filename.tif 
unzip -o  $1 
filename=$(basename $1 .zip)
gdal_translate  -co COMPRESS=LZW  -co ZLEVEL=9   $filename.tif tmp_$filename.tif
mv tmp_$filename.tif /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles/$filename.tif
rm -f  $filename.tfw   $filename.hdr $filename.tif 
' _ 


export RAM=/dev/shm 