# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/ ;  for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc3_warp30m_aggregate250m_composite.sh ; done 

# for LIST in tiles16_listF1.txt ; do bash /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc3_warp30m_aggregate250m_composite.sh  $LIST  ; done 

# create overal tiles shp and vrt 
# to avoid absolute path in the shp 
# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326
# rm -f   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326/tiles_EPSG4326_w.*
# gdaltindex   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326/tiles_EPSG4326_w.shp  *_EPSG4326_w.tif 

# use this vrt to make the composite 
# rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326/output_EPSG4326_w.vrt
# gdalbuildvrt -overwrite /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326/output_EPSG4326_w.vrt /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif_30m4326/*_EPSG4326_w.tif 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT

cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/$LIST   | xargs -n 13 -P 8 bash -c $'

tile=${1}
xmin=${4}
ymin=${9}
xmax=${10}
ymax=${5}

# rm -f $DIR/tif_30m4326_tiles/$tile.vrt
# gdalbuildvrt -overwrite  -te $xmin $ymin $xmax $ymax $DIR/tif_30m4326_tiles/$tile.vrt $DIR/tif_30m4326/p*r*_WC_*_EPSG4326_w.tif
# echo composite 
# pkcomposite -of GTiff  -ot Byte -cr max -srcnodata 0 -dstnodata 0 -co COMPRESS=DEFLATE  -co ZLEVEL=9 BIGTIFF=YES  -of GTiff -i $DIR/tif_30m4326_tiles/$tile.vrt -o  $DIR/tif_30m4326_tiles/${tile}_30m.tif 
# rm -f $DIR/tif_30m4326_tiles/$tile.vrt

echo aggregate $DIR/tif_30m4326_tiles/${tile}_30m.tif 
pkfilter -dx 8 -dy 8 -f max -d 8 -co COMPRESS=DEFLATE -co ZLEVEL=9 -i $DIR/tif_30m4326_tiles/${tile}_30m.tif -o  $DIR/tif_250m_from_30m4326_tiles/${tile}_250m_max.tif 
pkfilter -dx 8 -dy 8 -f sum -d 8 -co COMPRESS=DEFLATE -co ZLEVEL=9 -i $DIR/tif_30m4326_tiles/${tile}_30m.tif -o  $DIR/tif_250m_from_30m4326_tiles/${tile}_250m_sum.tif 

' _ 

cleanram 
exit 

# follow /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc4_warp30m_30m_merge.sh 
