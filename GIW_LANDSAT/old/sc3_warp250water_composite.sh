# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/ ;  for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST   /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc3_warp250water_composite.sh  ; done 

# for LIST in tiles16_listF1.txt ; do bash  /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc3_warp250water_composite.sh    $LIST  ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=8:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$1
export RAM=/dev/shm

cleanram 

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT

cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/$LIST   | xargs -n 13 -P 8 bash -c $'

tile=${1}
xmin=${4}
ymin=${9}
xmax=${10}
ymax=${5}


gdalbuildvrt -overwrite  -te $xmin $ymin $xmax $ymax $DIR/tif_250m_tiles/$tile.vrt $DIR/tif_250m/output.vrt 
echo composite 
pkcomposite  -ot Byte   -cr max  -srcnodata 0 -dstnodata 0  -co COMPRESS=LZW -co ZLEVEL=9   -of GTiff   -i $DIR/tif_250m_tiles/$tile.vrt -o $DIR/tif_250m_tiles/$tile.tif
rm $DIR/tif_250m/output.vrt 
' _ 

cleanram 
exit 
