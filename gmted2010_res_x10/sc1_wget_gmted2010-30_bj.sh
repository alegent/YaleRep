# download  unzip and tif conversion of the Global Multi-resolution Terrain Elevation Data 2010 (GMTED2010)
# setting working directory 




module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0


INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010
cd $INDIR

# download all the zip file from http://topotools.cr.usgs.gov/gmted_viewer/gmted2010_global_grids.php
# using multiprocess approch 

url=http://gmted.cr.usgs.gov/gmted/Grid_ZipFiles/


echo $url"be30_grd.zip" $url"ds30_grd.zip"  $url"mn30_grd.zip" | xargs -n 1 -P 7  wget  -d /lustre0/scratch/ga254/dem_bj/GMTED2010  $1   



# unzip the file using multiprocess approch  

ls  $INDIR/zip/??30_grd.zip | xargs -n 1 -P 7 bash -c $'
INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010
dir=`basename $1 .zip`
cd $INDIR/$dir

unzip   $1

' _ 


# transform to tif and tiling them using multiprocess approch   
# be30_grd.zip	Breakline Emphasis     , 30 arc-seconds
# ds30_grd.zip	Systematic Subsample   , 30 arc-seconds
# md30_grd.zip	Median Statistic       , 30 arc-seconds
# mi30_grd.zip	Minimum Statistic      , 30 arc-seconds
# mn30_grd.zip	Mean Statistic         , 30 arc-seconds
# mx30_grd.zip	Maximum Statistic      , 30 arc-seconds
# sd30_grd.zip	Standard Dev. Statistic, 30 arc-seconds

echo  be30_grd ds30_grd  mn30_grd |  xargs -n 1 -P 7 bash -c $'

dir=$1
INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/$dir
        gdal_translate   -co COMPRESS=LZW $INDIR/$dir  $INDIR"_tif"/$dir.tif

' _ 

# at the end fo this process the 50 tiles tiff has been created for each of the defined component 



