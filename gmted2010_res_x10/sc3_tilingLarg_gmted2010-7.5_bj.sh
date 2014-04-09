# download  unzip and tif conversion of the Global Multi-resolution Terrain Elevation Data 2010 (GMTED2010)
# setting working directory 

# transform to tif and tiling them using multiprocess approch   
# be75_grd.zip	Breakline Emphasis     , 7.5 arc-seconds
# ds75_grd.zip	Systematic Subsample   , 7.5 arc-seconds
# md75_grd.zip	Median Statistic       , 7.5 arc-seconds
# mi75_grd.zip	Minimum Statistic      , 7.5 arc-seconds
# mn75_grd.zip	Mean Statistic         , 7.5 arc-seconds
# mx75_grd.zip	Maximum Statistic      , 7.5 arc-seconds
# sd75_grd.zip	Standard Dev. Statistic, 7.5 arc-seconds

# rm     /lustre0/scratch/ga254/stdout/*  /lustre0/scratch/ga254/stderr/*
# for DIR in  md75_grd mi75_grd mn75_grd mx75_grd be75_grd ds75_grd sd75_grd  ; do  qsub -v DIR=$DIR   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc3_tiling_gmted2010-7.5_bj.sh ; done

# for DIR in  be75_grd  ; do  bash   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc3_tilingLarg_gmted2010-7.5_bj.sh $DIR ; done


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


DIR=$1

echo processing $DIR

INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles
cd $INDIR

# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0


#              -projwin ulx uly lrx lry 
gdal_translate -projwin -180 +90   0   0  -co COMPRESS=LZW  -ot Int16   $INDIR/$DIR/$DIR $INDIR/$DIR"_tif"/$DIR"_NW.tif"
gdal_translate -projwin    0 +90 180   0  -co COMPRESS=LZW  -ot Int16   $INDIR/$DIR/$DIR $INDIR/$DIR"_tif"/$DIR"_NE.tif"
gdal_translate -projwin -180   0   0 -90  -co COMPRESS=LZW  -ot Int16   $INDIR/$DIR/$DIR $INDIR/$DIR"_tif"/$DIR"_SW.tif"
gdal_translate -projwin    0   0 180 -90  -co COMPRESS=LZW  -ot Int16   $INDIR/$DIR/$DIR $INDIR/$DIR"_tif"/$DIR"_SE.tif"


gdal_edit.py -a_ullr -180 +90   0   0      $INDIR/$DIR"_tif"/$DIR"_NW.tif"
gdal_edit.py -a_ullr    0 +90 180   0      $INDIR/$DIR"_tif"/$DIR"_NE.tif"
gdal_edit.py -a_ullr -180   0   0 -90      $INDIR/$DIR"_tif"/$DIR"_SW.tif"
gdal_edit.py -a_ullr    0   0 180 -90      $INDIR/$DIR"_tif"/$DIR"_SE.tif"

gdalbuildvrt -overwrite    $INDIR/$DIR"_tif"/$DIR.vrt  $INDIR/$DIR"_tif"/$DIR"_"??.tif



for nx in `seq 0 9` ; do  for ny in `seq 0 4` ; do echo $nx $ny $DIR; done ; done | xargs -n 3  -P 4  bash -c $'
nx=$1
ny=$2
DIR=$3
INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/$DIR"_tif"

xoff=$(echo 17280 \* $nx | bc)
yoff=$(echo 2879 + 13440 \* $ny | bc)   # 2879 the ofset of no data value in the northen part
xsize=19270 # increase 2000 pixel to avoid border effect
ysize=15440 # increase 2000 pixel to avoid border effect 
gdal_translate -co ZLEVEL=9 -srcwin  $xoff $yoff $xsize $ysize  -co COMPRESS=LZW $INDIR/$DIR.vrt  $INDIR/$nx"_"$ny.tif

' _ 


rm $DIR"_tif"/${DIR}_??.tif

echo start to integrate greenland 


for tile in 2_0 3_0 4_0 2_1 3_1 4_1 ; do echo $tile $DIR ; done |  xargs -n 2  -P 6  bash -c $'

tile=$1
DIR=$2
INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles

    # get greenland mn and paste in mn md mx mn be
    if [  ${DIR} = mn75_grd ] ||  [  ${DIR}=md75_grd  ] ||  [  ${DIR}=mx75_grd ]   ||  [  ${DIR}=mn75_grd  ] || ${DIR} = be75_grd ] ; then 
    echo ${DIR}  $tile 
pkmosaic -t 0 -min -30000 $(pkinfo -bb -i $INDIR/${DIR}_tif/${tile}.tif) -co COMPRESS=LZW -co ZLEVEL=9 -m max -i $INDIR/${DIR}_tif/${tile}.tif  -i $INDIR/mn75_grd_tif/green_land_msk.tif  -o $INDIR/${DIR}_tif/${tile}g.tif
    fi 
    # get greenland ds and paste in ds 
    if [  ${DIR} = ds75_grd ]  ; then 
    echo ${DIR} $tile 
    pkmosaic -t 0 -min -30000 $(pkinfo -bb -i $INDIR/${DIR}_tif/${tile}.tif) -co COMPRESS=LZW -co ZLEVEL=9  -m max  -i  $INDIR/${DIR}_tif/${tile}.tif  -i $INDIR/ds75_grd_tif/green_land_msk.tif  -o $INDIR/${DIR}_tif/${tile}g.tif
    fi 
    # standard deviation not computed for greenland becouse == to 0

mv $INDIR/${DIR}_tif/${tile}.tif $INDIR/${DIR}_tif/${tile}_no_green.tiff

mv $INDIR/${DIR}_tif/${tile}g.tif $INDIR/${DIR}_tif/${tile}.tif

' _ 







