
# cd /lustre0/scratch/ga254/dem_bj/HYDRO1k/tiles
# get the file list to process 
# for file in ??_?_?.tif ; do echo ${file:3:8}  ; done | sort | uniq -c | sort -k 1,1 -g  | awk '{ if ($1>1) print $2 }'
# 


# for file in 0_0.tif 2_2.tif 3_2.tif 4_1.tif 5_1.tif 5_2.tif 6_0.tif 6_1.tif 7_2.tif 8_1.tif 8_2.tif 6_2.tif ; do filename=`basename $file`; qsub -v filename=$filename /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/HYDRO1k/sc3_mergetiling_bj.sh ; done  

# rm /lustre0/scratch/ga254/stdout/* /lustre0/scratch/ga254/stderr/*

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=1:00:00 
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

INDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k/tiles

pkmosaic -m minband $( for file in $INDIR/??_$filename ; do echo -i $file ; done   ) -ot UInt32   -t 4294957297 -max 4294957295  -o $INDIR/$filename


