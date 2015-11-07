# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/URBAN/sc1_treecover2000_wget.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

# cd   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# wget https://storage.googleapis.com/earthenginepartners-hansen/GFC2015/treecover2000.txt

cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif 
cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/treecover2000.txt  | xargs -n 1 -P 8 wget $1 

