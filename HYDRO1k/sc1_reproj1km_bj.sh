
# echo af as au eu na sa
# echo eu  | xargs -n 1 -P 6 bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/HYDRO1k/sc1_reproj1km_bj.sh 

INDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k
CONT=$1

gdal_translate -stats -ot Int16  -a_nodata 32767 -co COMPRESS=LZW  $INDIR/gt30h1k$CONT/${CONT}_dem.bil $INDIR/gt30h1k$CONT/${CONT}_dem.tif 

gdalwarp -ot Int16 -wt Int16 -srcnodata 32767  -dstnodata 32767   -multi -tr 0.0083333333333 0.0083333333333 -r cubic -co COMPRESS=LZW -t_srs /lustre0/scratch/ga254/dem_bj/GMTED2010/prj/4326.prj $INDIR/gt30h1k$CONT/${CONT}_dem.tif $INDIR/gt30h1k$CONT/${CONT}_dem_proj.tif -overwrite


# get the proj4 string from the bil file     non automatizzato perche lo spazio nella stringa interrompe lo script. 
# prj4=`gdalsrsinfo  -o proj4 eu_dem.bil`

if [ $CONT = af ] ; then 
    gdal_translate -stats -ot UInt32 -a_nodata 4294957297  -a_srs "+proj=laea +lat_0=5 +lon_0=20 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

if [ $CONT = as ] ; then 
    gdal_translate -stats -ot UInt32  -a_nodata 4294957297 -a_srs "+proj=laea +lat_0=45 +lon_0=100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

if [ $CONT = au ] ; then 
    gdal_translate -stats -ot UInt32  -a_nodata 4294957297 -a_srs "+proj=laea +lat_0=-15 +lon_0=135 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

if [ $CONT = eu ] ; then 
    gdal_translate -stats -ot UInt32  -a_nodata 4294957297 -a_srs "+proj=laea +lat_0=55 +lon_0=20 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

if [ $CONT = na ] ; then 
    gdal_translate -stats -ot UInt32  -a_nodata 4294957297 -a_srs "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

if [ $CONT = sa ] ; then 
    gdal_translate -stats -ot UInt32  -a_nodata 4294957297 -a_srs "+proj=laea +lat_0=-15 +lon_0=-60 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs" $INDIR/gt30h1k$CONT/${CONT}_fa.bil  $INDIR/gt30h1k$CONT/${CONT}_fa.tif
fi 

gdalwarp -ot UInt32 -wt UInt32 -srcnodata 4294957297  -dstnodata 4294957297   -multi -tr 0.0083333333333 0.0083333333333 -r cubic -co COMPRESS=LZW   -t_srs /lustre0/scratch/ga254/dem_bj/GMTED2010/prj/4326.prj $INDIR/gt30h1k$CONT/${CONT}_fa.tif $INDIR/gt30h1k$CONT/${CONT}_fa_proj.tif   -overwrite
