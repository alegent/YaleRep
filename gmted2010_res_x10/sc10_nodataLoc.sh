# qsub /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc10_nodataLoc.sh 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr



ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/*/altitude*.tif | xargs -n 1 -P 8 bash -c $'  
file=$1
filename=$(basename $file .tif )
DIR=$(dirname $file )
gdal_translate -of XYZ -ot Int16 $file  $DIR/$filename.txt

awk \'{ if($3==-32768)  { print $1,$2 }   }\' $DIR/$filename.txt > $DIR/${filename}-32768.txt

' _  

