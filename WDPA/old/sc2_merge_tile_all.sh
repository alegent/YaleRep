


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=10gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0



export RASTERIZE=/lustre0/scratch/ga254/dem_bj/WDPA/rasterize_all 

rm -f $RASTERIZE/a.tif  $RASTERIZE/b.tif   $RASTERIZE/c.tif $RASTERIZE/d.tif $RASTERIZE/e.tif 

echo a b c d e | xargs -n 1 -P 5 bash -c $'

l=$1

if [ $l = "a" ];then 
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$l.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/tiles/[0-1]_?.tif
fi

if [ $l = "b" ];then 
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$l.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/tiles/[2-3]_?.tif
fi 
if [ $l = "c" ];then 
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$l.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/tiles/[4-5]_?.tif
fi 
if [ $l = "d" ];then 
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$l.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/tiles/[6-7]_?.tif
fi 
if [ $l = "e" ];then 
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$l.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/tiles/[8-9]_?.tif
fi 
' _ 



rm -f $RASTERIZE/WDPA_poly_Jan2014.tif

/home2/ga254/bin/gdal_merge_bylines.py  -ul_lr   -180 +90 +180 -90    -o $RASTERIZE/WDPA_poly_Jan2014.tif    -ot Byte -co COMPRESS=LZW $RASTERIZE/[a-e].tif

# rm -f $RASTERIZE/a.tif  $RASTERIZE/b.tif   $RASTERIZE/c.tif $RASTERIZE/d.tif $RASTERIZE/e.tif 

gdal_translate -co COMPRESS=LZW  -co ZLEVEL=9  -a_nodata 0  $RASTERIZE/WDPA_poly_Jan2014.tif   $RASTERIZE/tmpIUCN$DIR.tif
rm -f $RASTERIZE/tmpIUCN$DIR.tif
