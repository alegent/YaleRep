# works perfect for different layers 

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

# tail -182 for the 2002 
# cd /tmp ;  for DAY in $( cat  /lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/day_list.txt   )  ; do for YEAR in `seq 2004 2006` ; do qsub -v YEAR=$YEAR,DAY=$DAY  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc1_heg_tif.sh ; sleep 100 ; done ; done  & 

# qsub -S /bin/bash -v YEAR=2005  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc1_heg_tif_1year.sh   

# controll the status 
# cd /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2 ; for year in `seq 2002 2014` ; do  ll   $year/tif/AOD_550_Dark_Target_Deep_Blue_Combined_year${year}_day*.tif | tail -1   ; done  

# bash  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C6_MYD04_L2/sc1_heg_tif_1year.sh  2004   

# 80 ore per un anno .. mi sembra che si blocca con 80 
# 8 for each node 

#PBS -S /bin/bash
#PBS -q fas_long
#PBS -l walltime=3:00:00:00
#PBS -l nodes=2:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

# export YEAR=$1
# export DAY=$2

export YEAR=$YEAR

for DAY in $( cat  /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt   )  ; do 
export DAY=$DAY

export HDFDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/hdf
export TIFDIR_TMP=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/tif_tmp
export TIFDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/tif
export PRMDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/prm
export HDRDIR=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/hdr

#    if [ -f $TIFDIR/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day$DAY.tif ] ; then 
#    echo the file  $TIFDIR/AOD_550_Dark_Target_Deep_Blue_Combined_year${YEAR}_day$DAY.tif  exist 

if [ -f $TIFDIR/Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate_year${YEAR}_day$DAY.tif ] ; then 
    echo the file  Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate_year${YEAR}_day$DAY.tif  exist
else
    echo processing $YEAR day $DAY

wget -P  $HDFDIR   ftp://ladsweb.nascom.nasa.gov/allData/6/MYD04_L2/$YEAR/$DAY/*.hdf

ls $HDFDIR/MYD04_L2.A${YEAR}${DAY}*.hdf | xargs -n 1 -P  16   bash  -c  $'

file=$1
filename=$(basename $file .hdf)

echo filename  $filename 
cd /tmp 
# create the hdr 
rm -f $HDRDIR/$filename.hdr 
PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/hegtool -n $HDFDIR/$filename.hdf $HDRDIR/$filename.hdr   &>/dev/null

SWATH_LAT_MAX=$( grep SWATH_LAT_MAX  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )  
SWATH_LAT_MIN=$( grep SWATH_LAT_MIN  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )
SWATH_LON_MAX=$( grep SWATH_LON_MAX  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )
SWATH_LON_MIN=$( grep SWATH_LON_MIN  $HDRDIR/$filename.hdr | awk \'{ gsub ("="," ") ; print $2 }\' )

# 
# ---------- Forwarded message ----------
# From: Sayer, Andrew (GSFC-613.0)[UNIVERSITIES SPACE RESEARCH ASSOCIATION] <andrew.sayer@nasa.gov>
# Date: 2 June 2014 12:52
# Subject: RE: convert MYD04_3K hdf to tif
# To: "giuseppe.amatulli@yale.edu" <giuseppe.amatulli@yale.edu>
# 
# If you want the global picture, it would be probably best to use AOD_550_Dark_Target_Deep_Blue_Combined, as you already are. 
# This is already filtered to include only pixels passing QA checks. 
# If you want to fill gaps, you can use Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate , which is also already filtered to include only pixels passing QA checks. 
# You can then also use Corrected_Optical_Depth_Land, but you need to filter this yourself to include only data with QA=3 from it.
# 

#  AOD_550_Dark_Target_Deep_Blue_Combined add this in case of re run

for band in Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate   Corrected_Optical_Depth_Land  Quality_Assurance_Land   ; do 

# insert the qa of  Corrected_Optical_Depth_Land 
# should be one of this 
# SUBDATASET_25_NAME=HDF4_EOS:EOS_SWATH:"MYD04_L2.A2004150.2110.006.2014017112811.hdf":mod04:Quality_Assurance_Land



if [ band = "Corrected_Optical_Depth_Land" ] ; then  BAND_NUMBER=2 ; else BAND_NUMBER=1 ; fi 


echo ""                                                                              > $PRMDIR/$filename.prm 
echo "NUM_RUNS = 1"                                                                 >> $PRMDIR/$filename.prm 
echo ""                                                                             >> $PRMDIR/$filename.prm 
echo "BEGIN"                                                                        >> $PRMDIR/$filename.prm 
echo "INPUT_FILENAME = $HDFDIR/$filename.hdf"                                       >> $PRMDIR/$filename.prm 
echo "OBJECT_NAME = mod04"                                                          >> $PRMDIR/$filename.prm 
echo "FIELD_NAME = $band|"                       >> $PRMDIR/$filename.prm 
echo "BAND_NUMBER = $BAND_NUMBER"                                                              >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_X = 0.08333333333333"                                      >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_Y = 0.08333333333333"                                      >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_UL_CORNER = ( $SWATH_LAT_MAX $SWATH_LON_MIN )"                 >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_LR_CORNER = ( $SWATH_LAT_MIN $SWATH_LON_MAX )"                 >> $PRMDIR/$filename.prm 
echo "RESAMPLING_TYPE = BI"                                                         >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_TYPE = GEO"                                                 >> $PRMDIR/$filename.prm 
echo "ELLIPSOID_CODE = WGS84"                                                       >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_PARAMETERS = ( 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0  )"    >> $PRMDIR/$filename.prm 
echo "OUTPUT_FILENAME = $TIFDIR_TMP/$filename$band.tif"                                                            >> $PRMDIR/$filename.prm 
echo "OUTPUT_TYPE = GEO"                                                                                  >> $PRMDIR/$filename.prm 
echo "END"                                                                                                >> $PRMDIR/$filename.prm 
echo ""                                                                                                   >> $PRMDIR/$filename.prm 

rm -f  $TIFDIR_TMP/$filename$band.tif

echo export   $TIFDIR_TMP/$filename$band.tif

PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/swtif -P $PRMDIR/$filename.prm   &>/dev/null
rm -f  $TIFDIR_TMP/$filename$band.tif.met

# remove empty file 
data=$(gdalinfo -mm $TIFDIR_TMP/$filename$band.tif  | grep Computed | awk -F  ","  \'{  print  $NF  }\')
if [ $data = -9999.000 ] ;  then rm -f   $TIFDIR_TMP/$filename$band.tif  ; fi 
rm -f  $PRMDIR/$filename.prm  

done

rm -f $HDRDIR/$filename.hdr  $HDFDIR/$filename.hdf $HDRDIR/$filename.hdr 

' _     &>/dev/null 


rm -f /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/$YEAR/*.log 

echo starting the tiling merge action $TIFDIR/Deep_Blue_Aerosol_Optical_year${YEAR}_day$DAY.tif  $TIFDIR/Corrected_Optical_Depth_Land_year${YEAR}_day$DAY.tif

# merging 


#  AOD_550_Dark_Target_Deep_Blue_Combined add this in case of re run

for band in  Deep_Blue_Aerosol_Optical_Depth_550_Land_Best_Estimate   Corrected_Optical_Depth_Land   ; do 
    gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -overwrite  -hidenodata    -resolution user  -tr 0.08333333333333  0.08333333333333 -te -180 -90 +180 +90   $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*$band.tif
    gdal_translate  -a_nodata -9999   -co  COMPRESS=LZW -co ZLEVEL=9    -a_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"    $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR/${band}_year${YEAR}_day$DAY.tif
    rm  $TIFDIR/year${YEAR}_day$DAY.vrt 
    rm -r $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*${band}.tif
done 

# this a nodata = 0

for band in  Quality_Assurance_Land  ; do 
    gdalbuildvrt -srcnodata 0  -vrtnodata 0  -overwrite  -hidenodata    -resolution user  -tr 0.08333333333333  0.08333333333333 -te -180 -90 +180 +90   $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*$band.tif
    gdal_translate  -a_nodata 0  -co  COMPRESS=LZW -co ZLEVEL=9    -a_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"    $TIFDIR/year${YEAR}_day$DAY.vrt   $TIFDIR/${band}_year${YEAR}_day$DAY.tif
    rm  $TIFDIR/year${YEAR}_day$DAY.vrt 
    rm -r $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*${band}.tif
done 


rm -f  $HDFDIR/MYD04_L2.A${YEAR}${DAY}*.hdf  $TIFDIR_TMP/MYD04_L2.A${YEAR}${DAY}*.tif $TIFDIR/year${YEAR}_day$DAY.vrt 


fi
done 

checkjob -v $PBS_JOBID


