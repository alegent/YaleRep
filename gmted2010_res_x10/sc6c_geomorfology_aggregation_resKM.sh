# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm  /scratch/fas/sbsc/ga254/stdout/* /scratch/fas/sbsc/ga254/stderr/*


# after have run the /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent_resKM.sh because is using the same tiling system

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file

# for list in tiles16_listF*.txt ; do  for km in 1 5 10 50 100 ; do  qsub  -v km=$km,list=$list /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorfology_aggregation_resKM.sh ; done ; done 
# bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorfology_aggregation_resKM.sh  1 tiles16_listF1.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:10:00:00  
#PBS -l mem=34g
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export RAM=/dev/shm
export IN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms
export OUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon

rm -fr /dev/shm/*


# km=$1
# list=$2

export km=$km
export res=$( expr $km \* 4)
rm -fr /dev/shm/*

echo list $list km $km

cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/$list   | xargs -n 4 -P 1 bash -c $'
                                                                                                                                                             
# increment of the tile because the python script cat $res pixel in each border                                                                                                                                     
export xoff=$( expr $1 - $res)
export yoff=$( expr $2 - $res)
export xsize=$( expr $3 + $res + $res)
export ysize=$( expr $4 + $res + $res)

if [ -f  $IN/x${xoff}_y${yoff}.tif ] ; then 

echo majority 
pkfilter -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Byte -nodata 255 -dx $res -dy $res -f mode -d $res -i $IN/x${xoff}_y${yoff}.tif -o $OUT/majority/tiles/x${xoff}_y${yoff}_km${km}.tif

echo countid 
pkfilter -co COMPRESS=LZW  -co ZLEVEL=9  -co INTERLEAVE=BAND -ot Byte  -nodata 255  -dx $res -dy $res  -f countid  -d $res -i $IN/x${xoff}_y${yoff}.tif -o $OUT/count/tiles/x${xoff}_y${yoff}_km${km}.tif

for class in $(seq 1 10) ;  do  

pkfilter -co COMPRESS=LZW -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Float32 -nodata 255 -dx $res -dy $res -f density -class $class -d $res -i $IN/x${xoff}_y${yoff}.tif -o $RAM/x${xoff}_y${yoff}_class${class}_km$km.tif

oft-calc -ot UInt16  $RAM/x${xoff}_y${yoff}_class${class}_km$km.tif $RAM/x${xoff}_y${yoff}_class${class}_km${km}_tmp.tif  <<EOF
1
#1 100 * 
EOF
rm  $RAM/x${xoff}_y${yoff}_class${class}_km$km.tif
gdal_translate -co COMPRESS=LZW  -co ZLEVEL=9  -co INTERLEAVE=BAND  $RAM/x${xoff}_y${yoff}_class${class}_km${km}_tmp.tif  $OUT/percent/tiles/x${xoff}_y${yoff}_class${class}_km${km}.tif

rm -f  $RAM/x${xoff}_y${yoff}_class${class}_km${km}_tmp.tif 

done  

fi

' _ 

rm -fr /dev/shm/*

# segue this  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc7c_geomorf_asm_ent_count_perce_merge_resKM.sh

exit 

