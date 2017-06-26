# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/
# 
# awk 'NR>1' tile_lat_long_10d.txt | awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'

# for LIST in tiles16_listF1.txt ; do bash    /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_250m.sh $LIST  ; done 

# for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST  /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_250m.sh  ; done 

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
#PBS -l walltime=8:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 

cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/$LIST   | xargs -n 13 -P 8 bash -c $'

tile=${1}
xmin=${4}
ymin=${9}
xmax=${10}
ymax=${5}

INPUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.6/GSHHS_shp/f/GSHHS_f_L1.shp    
SHPOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_shp_clip
TIFOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif

rm -f $RAM/$tile.*
echo  clip the shp by $tile
ogr2ogr  -clipsrc $xmin $ymin $xmax $ymax  -spat  $xmin   $ymin   $xmax   $ymax -skipfailures  $RAM/$tile.shp     $INPUT

echo rasterize 250 meter $tile   

rm -f  ${TIFOUT}_250m/${tile}_250m.tif

# -at any Enables the ALL_TOUCHED rasterization 
gdal_rasterize   -at   -tr 0.0020833333333333333 0.002083333333333 -burn  1  -te  $xmin $ymin $xmax $ymax -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -l $tile  $RAM/$tile.shp    ${TIFOUT}_250m/${tile}_250m.tif

rm -r   $RAM/$tile.*

' _ 

cleanram 
exit 
# segue   /lustre/home/client/fas/sbsc/ga254/scripts/GSHHG/sc2_rasterize_250m_merge.sh  
