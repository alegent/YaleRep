# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_unit
# seq 0 179818  > seq_unit.txt 
# awk 'NR%100==1 {x="F"++i;}{ print >  "seq_unitF"x".txt" }'  seq_unit.txt 


#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/ ; for LIST in tiles16_listF10.txt ; do bash   /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_250m_continent.sh   $LIST  ; done 

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/ ; for LIST in tiles16_listF*.txt ; do qsub -v LIST=$LIST  /home/fas/sbsc/ga254/scripts/GSHHG/sc1_rasterize_250m_continent.sh ; done 

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

# rm -f   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/shp_continent/continent*.shp  
# for ID in  0-W 0-E 1 2 3 4 5 6 7 8 9 10 ; do 

#  1 = africa 
# 

# echo start ogr ID$ID
# ogr2ogr    -where  " id = '$ID' "  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHS_shp_continent/continent$ID.shp        /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp
# done 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export LIST=$LIST
export RAM=/dev/shm

cleanram 


for ID in  0-W 0-E 1 2 3 4 5 6 7 8 9 10 ; do 

ogr2ogr    -where  " id = '$ID' "  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHS_shp_continent/continent$ID.shp        /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/version2.3.5-1/GSHHS_shp/f/GSHHS_f_L1.shp

export ID 

cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/geo_file/$LIST  | xargs -n 13 -P 8 bash -c $'

tile=${1}
xmin=${4}
ymin=${9}
xmax=${10}
ymax=${5}

INPUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_shp_continent/continent$ID.shp
TIFOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHHG/GSHHS_tif_250m_continent

rm -f $RAM/$tile.*
echo  clip the shp continent$ID.shp   by $tile
ogr2ogr  -clipsrc $xmin $ymin $xmax $ymax  -spat  $xmin   $ymin   $xmax   $ymax -skipfailures  $RAM/$tile.shp     $INPUT

echo rasterize 250 meter $tile   


# -at any Enables the ALL_TOUCHED rasterization 
gdal_rasterize   -at   -tr 0.0020833333333333333 0.002083333333333 -burn  1  -te  $xmin $ymin $xmax $ymax -co COMPRESS=DEFLATE -co ZLEVEL=9  -ot Byte -l $tile  $RAM/$tile.shp    ${TIFOUT}/${tile}_250m_continen$ID.tif

rm -r   $RAM/$tile.*

' _ 

cleanram 

done 

cleanram 

exit 
