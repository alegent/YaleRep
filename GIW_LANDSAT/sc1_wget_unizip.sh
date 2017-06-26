# qsub /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc1_wget_unizip.sh
#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

# info
# http://glcf.umd.edu/data/watercover/

# Value Label
# 0     No Data
# 1 	Land
# 2 	Water           Consider only this for river network 
# 4 	Snow/Ice
# 200 	Cloud shadow
# 201 	Cloud

# questo wget abbandonato l'xargs blocca il downlaod completo
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/gz 
# get the list of the folder and download the gz  in multicore
# -nc e -c fanno il dowl solo se il file non e' completo
# wget -nv -O- ftp://ftp.glcf.umd.edu/glcf/GlobalInlandWater/WRS2/ | grep ftp| awk -F "\"" '{ print $2 }' | sort | xargs -n 1 -P 8 wget --waitretry=4 --random-wait -nc-c -w 5 -N-r -nH -nd -np -R index.html* -A.gz
# sleep 600
# wget -nv -O- ftp://ftp.glcf.umd.edu/glcf/GlobalInlandWater/WRS2/ | grep ftp| awk -F "\"" '{ print $2 }'        | xargs -n 1 -P 8 wget --waitretry=4 --random-wait -nc-c -w 5 -N-r -nH -nd -np -R index.html* -A.gz 

# questo funziona bene 
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/gz 
# wget -m -nd  -A.gz   ftp://ftp.glcf.umd.edu/glcf/GlobalInlandWater/WRS2/

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/gz/*.gz  | wc -l > /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/gz/count_gz.txt 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif
find    /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/gz  -name "*.gz"  | xargs -n 1 -P 8  bash -c $' 
gunzip $1  
filename=$(basename $1 .gz)
dirname=$(dirname $1 ) 

mv  $dirname/$filename  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GIW_LANDSAT/tif/$filename  

' _

qsub /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc2_warp30m.sh 
qsub /lustre/home/client/fas/sbsc/ga254/scripts/GIW_LANDSAT/sc2_warp250water.sh