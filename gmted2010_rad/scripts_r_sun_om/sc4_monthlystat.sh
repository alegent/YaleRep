
# calculate global radiation and calculate  the mean and the standard deviation 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:04:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/glob_Hrad_month_merge

export RAMDIRG=/dev/shm/

rm -rf  /dev/shm/*
mkdir -p  $RAMDIRG/loc_tmp/tmp

echo "LOCATION_NAME: loc_tmp"                                                       > $HOME/.grass7/rc_$tile
echo "GISDBASE: /dev/shm"                                                          >> $HOME/.grass7/rc_$tile
echo "MAPSET: tmp"                                                                 >> $HOME/.grass7/rc_$tile
echo "GRASS_GUI: text"                                                             >> $HOME/.grass7/rc_$tile

# path to GRASS settings file
export GISRC=$HOME/.grass7/rc_$tile
export GRASS_PYTHON=python
export GRASS_MESSAGE_FORMAT=plain
export GRASS_PAGER=cat
export GRASS_WISH=wish
export GRASS_ADDON_BASE=$HOME/.grass7/addons
export GRASS_VERSION=7.0.0beta1
export GISBASE=/usr/local/cluster/hpc/Apps/GRASS/7.0.0beta1/grass-7.0.0beta1
export GRASS_PROJSHARE=/usr/local/cluster/hpc/Libs/PROJ/4.8.0/share/proj/
export PROJ_DIR=/usr/local/cluster/hpc/Libs/PROJ/4.8.0

export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$GISBASE/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man
export GIS_LOCK=$$
export GRASS_OVERWRITE=1

# rm -rf  $RAMDIRG/loc_month

echo start importing 
r.in.gdal in=$INDIR/beam_Hrad_month_merge/beam_HradCA_month01.tif    out=beam_HradCA_month01    location=loc_month

g.mapset mapset=PERMANENT  location=loc_month

echo import and set the mask 

r.external  -o input=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_1km/land_mask_m10fltGSHHS_f_L1_buf10.tif   output=mask  --overwrite  --quiet 
r.mask raster=mask

echo start the xargs comptutation 

echo 01 02 03 04 05 06 07 08 09 10 11 12 | xargs -n 1 -P 8 bash -c $' 

month=$1

# echo importing $month 

# r.external  -o input=$INDIR/beam_Hrad_month_merge/beam_HradCA_month${month}.tif     output=beam_HradCA_month${month}  --overwrite  --quiet 
# r.external  -o input=$INDIR/diff_Hrad_month_merge/diff_HradCA_month${month}.tif     output=diff_HradCA_month${month}  --overwrite  --quiet 

# r.mapcalc " glob_HradCA_month${month} =  beam_HradCA_month${month} + diff_HradCA_month${month} "

# r.out.gdal -c type=Int16  nodata=-1 createopt="COMPRESS=LZW,ZLEVEL=9" input=glob_HradCA_month${month}  output=$OUTDIR/glob_HradCA_month${month}.tif 

r.external  -o input=$OUTDIR/glob_HradCA_month${month}.tif      output=glob_HradCA_month${month}     --overwrite  --quiet 

' _ 

echo start the computation of statistic

r.series  range=0,20000  input=$(g.mlist rast pattern="glob_HradCA_month*" sep=,)   output=glob_HradCA_mean   method=average  --overwrite
r.series  range=0,20000  input=$(g.mlist rast pattern="glob_HradCA_month*" sep=,)   output=glob_HradCA_sd     method=stddev   --overwrite

# take the floting point number 

r.mapcalc "glob_HradCA_mean_int =  int(   glob_HradCA_mean ) "
r.mapcalc "glob_HradCA_sd_int =  int(   glob_HradCA_sd ) "

r.out.gdal -c type=Int16  nodata=-1 createopt="COMPRESS=LZW,ZLEVEL=9" input=glob_HradCA_mean_int    output=$OUTDIR/glob_HradCA_mean.tif 
r.out.gdal -c type=Int16  nodata=-1 createopt="COMPRESS=LZW,ZLEVEL=9" input=glob_HradCA_sd_int      output=$OUTDIR/glob_HradCA_sd.tif 

rm -rf  /dev/shm/*
