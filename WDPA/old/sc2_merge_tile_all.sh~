
# for  dir in   102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6; do qsub  -v DIR=$dir  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc2_merge_tile.sh ; done 

# echo   102  103  104  105  106  11  111  112  12  120  121  2  20  21  3  4  5  6 | xargs -n 1 -P 20 bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WDPA/sc2_merge_tile.sh 


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
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

# export DIR=$DIR 
export DIR=$1


export RASTERIZE=/lustre0/scratch/ga254/dem_bj/WDPA/rasterize

rm -f $RASTERIZE/$DIR/a.tif  $RASTERIZE/$DIR/b.tif   $RASTERIZE/$DIR/c.tif $RASTERIZE/$DIR/d.tif $RASTERIZE/$DIR/e.tif 

/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$DIR/a.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/$DIR/[0-1]_?_IUCN*.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$DIR/b.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/$DIR/[2-3]_?_IUCN*.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$DIR/c.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/$DIR/[4-5]_?_IUCN*.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$DIR/d.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/$DIR/[6-7]_?_IUCN*.tif
/home2/ga254/bin/gdal_merge_bylines.py -o $RASTERIZE/$DIR/e.tif -ot Byte -co COMPRESS=LZW  $RASTERIZE/$DIR/[8-9]_?_IUCN*.tif

rm -f $RASTERIZE/$DIR/tmpIUCN$DIR.tif

/home2/ga254/bin/gdal_merge_bylines.py  -ul_lr   -180 +90 +180 -90        -o $RASTERIZE/$DIR/tmpIUCN$DIR.tif -ot Byte -co COMPRESS=LZW $RASTERIZE/$DIR/[a-e].tif

rm -f $RASTERIZE/$DIR/a.tif  $RASTERIZE/$DIR/b.tif   $RASTERIZE/$DIR/c.tif $RASTERIZE/$DIR/d.tif $RASTERIZE/$DIR/e.tif 

gdal_translate -co COMPRESS=LZW  -co ZLEVEL=9 -outsize  -a_nodata 0  $RASTERIZE/$DIR/IUCN$DIR.tif  $RASTERIZE/$DIR/tmpIUCN$DIR.tif
rm -f $RASTERIZE/$DIR/tmpIUCN$DIR.tif
