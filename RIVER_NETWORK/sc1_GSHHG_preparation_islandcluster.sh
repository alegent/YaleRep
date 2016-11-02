
# bash  /home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc1_GSHHG_preparation_islandcluster.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG
RAM=/dev/shm/




rm -f  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island.{shx,shp,prj,dbf}
pkpolygonize  -f "ESRI Shapefile" -nodata 0 --name UNIT   -m $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island_sample.tif  -i $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island_sample.tif -o $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3island.shp





qsub /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc4_UnitExtend.sh 

exit

