
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

YEAR=2003

HDFDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MODATML2_MYDATML2/$YEAR/hdf
TIFDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MODATML2_MYDATML2/$YEAR/tif
PRMDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MODATML2_MYDATML2/$YEAR/prm
HDRDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_MODATML2_MYDATML2/$YEAR/hdr

file=$1
filename=$(basename $file .hdf)

echo filename  $filename 

# create the hdr 
rm -f $HDRDIR/$filename.hdr 
PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/hegtool -n $HDFDIR/$filename.hdf $HDRDIR/$filename.hdr  # &>/dev/null

SWATH_LAT_MAX=$( grep SWATH_LAT_MAX  $HDRDIR/$filename.hdr | awk '{ gsub ("="," ") ; print $2 }' )  
SWATH_LAT_MIN=$( grep SWATH_LAT_MIN  $HDRDIR/$filename.hdr | awk '{ gsub ("="," ") ; print $2 }' )
SWATH_LON_MAX=$( grep SWATH_LON_MAX  $HDRDIR/$filename.hdr | awk '{ gsub ("="," ") ; print $2 }' )
SWATH_LON_MIN=$( grep SWATH_LON_MIN  $HDRDIR/$filename.hdr | awk '{ gsub ("="," ") ; print $2 }' )



echo ""                                                                              > $PRMDIR/$filename.prm 
echo "NUM_RUNS = 1"                                                                 >> $PRMDIR/$filename.prm 
echo ""                                                                             >> $PRMDIR/$filename.prm 
echo "BEGIN"                                                                        >> $PRMDIR/$filename.prm 
echo "INPUT_FILENAME = $HDFDIR/$filename.hdf"                                       >> $PRMDIR/$filename.prm 
echo "OBJECT_NAME = atml2"                                                          >> $PRMDIR/$filename.prm 
echo "FIELD_NAME = Deep_Blue_Aerosol_Optical_Depth_550_Land|"                       >> $PRMDIR/$filename.prm 
echo "BAND_NUMBER = 1"                                                              >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_X = 0.08333333333333"                                      >> $PRMDIR/$filename.prm 
echo "OUTPUT_PIXEL_SIZE_Y = 0.08333333333333"                                      >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_UL_CORNER = ( $SWATH_LAT_MAX $SWATH_LON_MIN )"                 >> $PRMDIR/$filename.prm 
echo "SPATIAL_SUBSET_LR_CORNER = ( $SWATH_LAT_MIN $SWATH_LON_MAX )"                 >> $PRMDIR/$filename.prm 
echo "RESAMPLING_TYPE = BI"                                                         >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_TYPE = GEO"                                                 >> $PRMDIR/$filename.prm 
echo "ELLIPSOID_CODE = WGS84"                                                       >> $PRMDIR/$filename.prm 
echo "OUTPUT_PROJECTION_PARAMETERS = ( 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0  )"    >> $PRMDIR/$filename.prm 
echo "OUTPUT_FILENAME = $TIFDIR/$filename.tif"                                                            >> $PRMDIR/$filename.prm 
echo "OUTPUT_TYPE = GEO"                                                                                  >> $PRMDIR/$filename.prm 
echo "END"                                                                                                >> $PRMDIR/$filename.prm 
echo ""                                                                                                   >> $PRMDIR/$filename.prm 

rm -f  $TIFDIR/$filename.tif
# create the tif 
PGSHOME=/home2/ga254/bin/heg/TOOLKIT_MTD   MRTDATADIR=/home2/ga254/bin/heg/data  PWD=/tmp  /home2/ga254/bin/heg/bin/swtif -P $PRMDIR/$filename.prm  # &>/dev/null
rm -f  $TIFDIR/$filename.tif.met

# remove empty file 
# data=$(gdalinfo -mm $TIFDIR/$filename.tif  | grep Computed | awk -F  ","  '{  print  $NF  }')
# if [ $data = -9999.000 ] ;  then rm -f   $TIFDIR/$filename.tif  ; fi 
