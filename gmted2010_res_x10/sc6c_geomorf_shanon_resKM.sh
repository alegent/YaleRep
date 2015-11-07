# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*


# after have run the /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent_resKM.sh because is using the same tiling system 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file     
# awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }' tiles_xoff_yoff.txt

# for list in tiles16_listF*.txt ; do  for km in 1 5 10 50 100 ; do  qsub  -v km=$km,list=$list  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_shanon_resKM.sh  ; done ; done
# bash   /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_shanon_resKM.sh  1 tiles16_listF1.txt

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:10:00:00  
#PBS -l mem=32gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export RAM=/dev/shm
export IN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms
export OUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon

# km=$1
# list=$2

export km=$km
export res=$( expr $km \* 4)
rm -fr /dev/shm/*


cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/$list  | xargs -n 4 -P 8  bash -c $'
                                                                                                                                                                  
# increment of the tile because the python script cat $res pixel in each border                                                                                                                                     
xoff=$( expr $1 - $res)                                                                                                                                                                                             
yoff=$( expr $2 - $res)        
xsize=$( expr $3 + $res + $res)
ysize=$( expr $4 + $res + $res)

if [ -f  $OUT/tiles/forms/x${xoff}_y${yoff}.tif ] ; then 

for class in $(seq 1 10) ;  do  

# use the id to count the number of pixel in 4 x 4 for each class 

echo class $class 

pkfilter -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32 -nodata 0 -dx $res -dy $res -class $class -f density -d $res -i $OUT/tiles/forms/x${xoff}_y${yoff}.tif  -o $OUT/shannon/tiles/x${xoff}_y${yoff}_count${class}_km${km}.tif
pksetmask -msknodata 0 -nodata 255 -m $OUT/shannon/tiles/x${xoff}_y${yoff}_count${class}_km${km}.tif  -i $OUT/shannon/tiles/x${xoff}_y${yoff}_count${class}_km${km}.tif -o $OUT/shannon/tiles/x${xoff}_y${yoff}_count255_${class}_km${km}.tif
gdal_calc.py  --co=COMPRESS=LZW --co=ZLEVEL=9 --NoDataValue=0 --type=Float32 --overwrite   -A $OUT/shannon/tiles/x${xoff}_y${yoff}_count${class}_km${km}.tif -B $OUT/shannon/tiles/x${xoff}_y${yoff}_count255_${class}_km${km}.tif  --calc="((log ( B  / 100 )) * ( A / 100 ))"  --outfile $OUT/shannon/tiles/x${xoff}_y${yoff}_countH_${class}_km${km}.tif
rm -f  $OUT/shannon/tiles/x${xoff}_y${yoff}_count255_${class}_km${km}.tif $OUT/shannon/tiles/x${xoff}_y${yoff}_count${class}_km${km}.tif

done 

rm -f   $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.vrt
gdalbuildvrt  -separate  -overwrite  $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.vrt  $OUT/shannon/tiles/x${xoff}_y${yoff}_countH_*_km${km}.tif
# controllato il risultato manualmente 
oft-calc -inv  -ot  Float32  $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.vrt  $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.tif <<EOF
1
#1 #2 + #3 + #4 + #5 + #6 + #7 + #8 + #9 + #10 + -1 *
EOF
rm -f   $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.vrt
fi 

# Evenness = shannon / log 16  

rm  $OUT/shannon/tiles/x${xoff}_y${yoff}_shannon_km${km}.vrt $OUT/shannon/tiles/x${xoff}_y${yoff}_countH_*_km${km}.tif  $OUT/shannon/tiles/x${xoff}_y${yoff}_count255_${class}_km${km}.tif

' _ 

rm -fr /dev/shm/*

