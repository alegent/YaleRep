# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# mkdir /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/list_tiles/
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif/
# ls ?_?.tif >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/list_tiles/listtiles_all.txt 
# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/list_tiles/ 
# awk 'NR%8==1{x="listtiles"++i;}{print > x ".txt"}'  listtiles_all.txt 

# for file in /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/crop_?_?_s3.tif    ; do qsub  -v file=$file /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent.sh   ; done
# bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent.sh   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/?_?_s3.tif

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:12:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

rm -fr /dev/shm/*  > /dev/null 2>&1

export file=$file

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export RAM=/dev/shm
mkdir  $RAM/MATRIX

export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon

export filenameCROP=$(basename $file .tif)
export filename=${filenameCROP:5:6}


for tilex in 0 1 2 3 ; do 

export tilex=$tilex

echo 0 1 2 3 | xargs -n 1 -P 4  bash -c $'
tiley=$1                                                                                           # 4322 + 8 incremen  3362 + 8 increment
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -srcwin $(expr $tilex \* 4322) $(expr $tiley \* 3362) 4330 3370 $file $RAM/${filename}_$tilex$tiley.tif 
pkinfo -nodata 255   -mm -i  /dev/shm/${filename}_$tilex$tiley.tif   > /dev/shm/${filename}_$tilex$tiley.txt
min=$( awk \'{  print $2 }\' /dev/shm/${filename}_$tilex$tiley.txt)
max=$( awk \'{  print $4 }\' /dev/shm/${filename}_$tilex$tiley.txt)
if [[ $min -eq 1  &&  $max -eq 1 ]] ; then 

rm  $RAM/${filename}_$tilex$tiley.tif

else
python /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/Aggregation_GLCM.py -no 255  -m "ASM ENT" -o $RAM/MATRIX -pn 4 4 -mm 10 1 -l 10 -scale $RAM/${filename}_$tilex$tiley.tif
rm -f  $RAM/${filename}_$tilex$tiley.tif
fi
rm   /dev/shm/${filename}_$tilex$tiley.txt
' _ 

done

rm -f  $OUTDIR/asm/tiles/ASM_$filename.tif   $OUTDIR/ent/tiles/ENT_$filename.tif  
# asm i vuoit anno lo 0 e devono avere 1
gdal_merge.py -init 1  -n 255   nodata_value 255  -co COMPRESS=LZW   $RAM/MATRIX/ASM_*.tif -o   $OUTDIR/asm/tiles/ASM_$filename.tif  
gdal_merge.py -init 0  -n 255   nodata_value 255  -co COMPRESS=LZW   $RAM/MATRIX/ENT_*.tif -o   $OUTDIR/ent/tiles/ENT_$filename.tif  

rm -rf   /dev/shm/*  > /dev/null 2>&1
rm -rf   /tmp/*      > /dev/null 2>&1

