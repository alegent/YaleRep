# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/
# 
# awk 'NR>1' tile_lat_long_10d.txt | awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'

# for LIST in tiles16_listF1.txt ; do bash    /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_10m.sh $LIST  ; done 

# for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST  /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_10m.sh  ; done 

# The geography data come in five resolutions:

#  F   full resolution: Original (full) data resolution.
#  H   high resolution: About 80 % reduction in size and quality.
#  I   intermediate resolution: Another ~80 % reduction.
#  L   low resolution: Another ~80 % reduction.
#  C   crude resolution: Another ~80 % reduction.

# Unlike the shoreline polygons at all resolutions, the lower resolution rivers are not guaranteed not to cross.
# Shorelines are furthermore organized into 4 hierarchical levels:

#     L1: boundary between land and ocean.
#     L2: boundary between lake and land.
#     L3: boundary between island-in-lake and lake.
#     L4: boundary between pond-in-island and island.


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 

cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/$LIST | head -8    | xargs -n 13 -P 8 bash -c $'

tile=$1
xmin=$4
ymin=$9
xmax=$10
ymax=$5

INPUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp    
SHPOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_shp_clip
TIFOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif

rm -f $RAM/$tile.*
echo  clip the shp by $tile
ogr2ogr  -clipsrc $xmin $ymin $xmax $ymax  -spat  $xmin   $ymin   $xmax   $ymax -skipfailures  $RAM/$tile.shp     $INPUT

echo rasterize 10 meter $tile 
rm -f  $TIFOUT/$tile.tif

gdal_rasterize -tr 0.00008333333333333333333  0.00008333333333333333333  -burn  1  -te  $xmin $ymin $xmax $ymax -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -l $tile  $RAM/$tile.shp  $RAM/$tile.tif

rm -f  $RAM/$tile.shp  

for res in 30 250 1 ; do 

if [ $res -eq 30  ]  ; then  dx=3   ; dy=3;    resname=30m  ; fi 
if [ $res -eq 250 ]  ; then  dx=25  ; dy=25;   resname=250m  ; fi 
if [ $res -eq 1   ]  ; then  dx=100 ; dy=100;  resname=100m ; fi 

pkfilter  -co COMPRESS=DEFLATE -co ZLEVEL=9  -class 1  -dx   $dx  -dy  $dy   -f density -d  $dx  -i $RAM/$tile.tif   -o $RAM/${tile}_$resname.tif 
oft-calc -ot  UInt16 $RAM/${tile}_${resname}_tmp.tif  $RAM/${tile}_$resname.tif   <<EOF
1
#1 100 *
EOF
rm -f $RAM/${tile}_${resname}.tif
 
gdal_translate COMPRESS=DEFLATE -co ZLEVEL=9  -ot  UInt16  $RAM/${tile}_${resname}_tmp.tif   ${TIFOUT}_${resname}/${tile}_${resname}.tif

rm $RAM/${tile}_${resname}_tmp.tif   
 
done 

mv $RAM/$tile.tif ${TIFOUT}_10m/${tile}_10m.tif

' _  

cleanram 
exit 
