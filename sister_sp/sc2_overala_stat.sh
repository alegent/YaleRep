# qsub  /lustre0/scratch/ga254/dem_bj/Range_map/sister/script/sc2_overala_stat.sh

#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=0:24:00:00
#PBS -l nodes=4:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

export TIF_COUP=/lustre0/scratch/ga254/dem_bj/Range_map/sister/tif_couple
export TXT_COUP=/lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_couple
export OUTDIR=/lustre0/scratch/ga254/dem_bj/Range_map/sister/tif

cat  /lustre0/scratch/ga254/dem_bj/Range_map/sister/sisterSpecies_couple.txt     | xargs -n 2  -P 32  bash -c   $'  

OUTDIR=/lustre0/scratch/ga254/dem_bj/Range_map/sister/tif
filename1=$1
filename2=$2

rm -f  $TIF_COUP/${filename1}_${filename2}.tif

if [ -f $OUTDIR/${filename1}.tif ] ; then 

# sum the two poligons 
pkcomposite -i   $OUTDIR/${filename1}.tif   -co COMPRESS=LZW -co ZLEVEL=9   -i   $OUTDIR/${filename2}.tif  --overwrite  --crule sum -o   /tmp/${filename1}_${filename2}.tif

#  crop the area 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  -projwin $(getCorners4Gtranslate   /tmp/${filename1}_${filename2}.tif)  /lustre0/scratch/ga254/dem_bj/Range_map/sister/30arc-sec-Area_prj6842.tif  /tmp/area_${filename1}_${filename2}.tif
# calculate 
oft-stat-sum  -i   /tmp/area_${filename1}_${filename2}.tif    -o $TXT_COUP/${filename1}_${filename2}.txt  -um   /tmp/${filename1}_${filename2}.tif   -nostd   &> /dev/null

rm -f   /tmp/area_${filename1}_${filename2}.tif      /tmp/${filename1}_${filename2}.tif   

fi 

' _


