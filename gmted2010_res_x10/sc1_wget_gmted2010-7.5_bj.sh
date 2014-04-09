# download  unzip and tif conversion of the Global Multi-resolution Terrain Elevation Data 2010 (GMTED2010)
# setting working directory 

INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010
cd $INDIR

# download all the zip file from http://topotools.cr.usgs.gov/gmted_viewer/gmted2010_global_grids.php
# using multiprocess approch 

url=http://gmted.cr.usgs.gov/gmted/Grid_ZipFiles/

cd $INDIR/zip
echo $url"be75_grd.zip" $url"ds75_grd.zip" $url"md75_grd.zip" $url"mi75_grd.zip"  $url"mx75_grd.zip"  $url"sd75_grd.zip" | xargs -n 1 -P 7  wget  $1   




# $url"mn75_grd.zip"

# unzip the file using multiprocess approch  

ls  $INDIR/zip/??75_grd.zip | xargs -n 1 -P 7 bash -c $'
INDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010
dir=`basename $1 .zip`
unzip  -d  $INDIR/tiles/$dir $1

' _ 


