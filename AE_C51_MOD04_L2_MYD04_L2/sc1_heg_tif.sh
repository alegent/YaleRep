# funziona perfectamente!! fatto correre per tutto il 2003!!

# cd /home2/ga254/src/heg 
# /usr/local/cluster/hpc/Modules/modulefind java
# which java 

# install
# /home2/ga254/bin/heg/
# y
# /usr/local/cluster/hpc/Software/BDJ/Tools/Java/1.7.0_45/jdk1.7.0_45/bin

# module load Tools/Java/1.7.0_45
# cd /home2/ga254/bin/heg/bin/
# PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp   /home2/ga254/bin/heg/bin/HEG    # non funziona per via di java cmq e' utile solo per creare il prm di esempio 

# ls  *.hdf | head -2 | xargs -n 1 -P 10   bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_MOD04_L2_MYD04_L2/sc1_heg_tif.sh

# for DAY in $(cat /lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/day_list.txt  )  ; do for YEAR in `seq 2002 2014` ; do qsub -v YEAR=$YEAR,DAY=$DAY  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_MOD04_L2_MYD04_L2/sc1_heg_tif.sh ; sleep 30 ; done ; done  & 



# bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_MOD04_L2_MYD04_L2/sc1_heg_tif.sh  2003 155



#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=0:30:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

export YEAR=$1
export DAY=$2

# export YEAR=$YEAR
# export DAY=$DAY

export HDFDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/hdf
export TIFDIR_TMP=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/tif_tmp
export TIFDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/tif
export PRMDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/prm
export HDRDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/hdr

echo processing $YEAR day $DAY

# wget -P  $HDFDIR  ftp://ladsweb.nascom.nasa.gov/allData/51/MYD04_L2/$YEAR/$DAY/*.hdf


ls $HDFDIR/MYD04_L2.A${YEAR}${DAY}*.hdf | xargs -n 1 -P  10 bash  -c  $'

file=$1
filename=$(basename $file .hdf)

echo filename  $filename 

# create the hdr 
rm -f $HDRDIR/$filename.hdr 
PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/hegtool -n $HDFDIR/$filename.hdf $HDRDIR/$filename.hdr  &>/dev/null

SWATH_LAT_MAX=$( grep SWATH_LAT_MAX  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )  
SWATH_LAT_MIN=$( grep SWATH_LAT_MIN  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )
SWATH_LON_MAX=$( grep SWATH_LON_MAX  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )
SWATH_LON_MIN=$( grep SWATH_LON_MIN  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )


echo ""                                                                              > $PRMDIR/$filename.prm 
echo "NUM_RUNS = 1"                                                                 >> $PRMDIR/$filename.prm 
echo ""                                                                             >> $PRMDIR/$filename.prm 
echo "BEGIN"                                                                        >> $PRMDIR/$filename.prm 
echo "INPUT_FILENAME = $HDFDIR/$filename.hdf"                                       >> $PRMDIR/$filename.prm 
echo "OBJECT_NAME = mod04"                                                          >> $PRMDIR/$filename.prm 
echo "FIELD_NAME = Deep_Blue_Aerosol_Optical_Depth_550_Land|"                       >> $PRMDIR/$filename.prm 
echo "BAND_NUMBER = 1"                                                              >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_X = 0.008333333333333"                                      >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_Y = 0.008333333333333"                                      >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_UL_CORNER = ( $SWATH_LAT_MAX $SWATH_LON_MIN )"                 >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_LR_CORNER = ( $SWATH_LAT_MIN $SWATH_LON_MAX )"                 >> $PRMDIR/$filename.prm 
echo "RESAMPLING_TYPE = BI"                                                         >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_TYPE = GEO"                                                 >> $PRMDIR/$filename.prm 
echo "ELLIPSOID_CODE = WGS84"                                                       >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_PARAMETERS = ( 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0  )"    >> $PRMDIR/$filename.prm 
echo "OUTPUT_FILENAME = $TIFDIR_TMP/$filename.tif"                                                            >> $PRMDIR/$filename.prm 
echo "OUTPUT_TYPE = GEO"                                                                                  >> $PRMDIR/$filename.prm 
echo "END"                                                                                                >> $PRMDIR/$filename.prm 
echo ""                                                                                                   >> $PRMDIR/$filename.prm 

rm -f  $TIFDIR_TMP/$filename.tif

echo export   $TIFDIR_TMP/$filename.tif

PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/swtif -P $PRMDIR/$filename.prm  &>/dev/null
rm -f  $TIFDIR_TMP/$filename.tif.met

# remove empty file 
data=$(gdalinfo -mm $TIFDIR_TMP/$filename.tif  | grep Computed | awk -F  ","  \'{  print  $NF  }\')
if [ $data = -9999.000 ] ;  then rm -f   $TIFDIR_TMP/$filename.tif  ; fi 

# rm -f  $PRMDIR/$filename.prm  $HDRDIR/$filename.hdr

' _ 

rm -f /lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/$YEAR/*.log 

echo starting the tiling merge action $TIFDIR/Deep_Blue_Aerosol_Optical_year${YEAR}_day$DAY.tif

gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -overwrite  -hidenodata   $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*.tif
gdal_translate  -a_nodata -9999   -co  COMPRESS=LZW -co ZLEVEL=9       $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR/Deep_Blue_Aerosol_Optical_year${YEAR}_day$DAY.tif

rm -f  $HDFDIR/MYD04_L2.A${YEAR}${DAY}*.hdf  $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*.tif $TIFDIR/year${YEAR}_day$DAY.vrt 

checkjob -v $PBS_JOBID

