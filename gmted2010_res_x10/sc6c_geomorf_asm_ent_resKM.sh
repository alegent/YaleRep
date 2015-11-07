# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/crop_?_?_s3.tif    ; do qsub  -v file=$file /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent.sh   ; done
# bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent.sh   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/forms/?_?_s3.tif

# tile preparation 
# split the stak in 16x 8y tiles Size is 172800 67200, so  10800  8400

# echo  0 0 10800 8400	>  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 0 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 8400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 16800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 25200 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 33600 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 42000 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 50400 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  0 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  10800 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  21600 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  32400 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  43200 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  54000 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  64800 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  75600 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  86400 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  97200 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  108000 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  118800 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  129600 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  140400 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  151200 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt
# echo  162000 58800 10800 8400 >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/tiles_xoff_yoff.txt

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file 
# awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }' tiles_xoff_yoff.txt

# for list in tiles16_listF*.txt ; do  for km in 1 5 10 50 100 ; do  qsub  -v km=$km,list=$list  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent_resKM.sh  ; done ; done 
# bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_geomorf_asm_ent_resKM.sh   1 tiles16_listF1.txt 

#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=3:00:00:00  
#PBS -l mem=32gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

rm -fr /dev/shm/*  > /dev/null 2>&1

# km=$1
# list=$2

export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export RAM=/dev/shm
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon
export km=$km
export res=$( expr $km \* 4)

mkdir  $RAM/MATRIX

cat  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geo_file/$list  | xargs -n 4 -P 4 bash -c $' 

# increment of the tile because the python script cat $res pixel in each border 
xoff=$( expr $1 - $res)
yoff=$( expr $2 - $res)
xsize=$( expr $3 + $res + $res)
ysize=$( expr $4 + $res + $res)

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -srcwin $xoff $yoff $xsize $ysize $OUTDIR/tiles/forms/md75_grd_border_full.tif  $OUTDIR/tiles/forms/x${xoff}_y${yoff}.tif 

pkinfo -nodata 255   -mm -i    $OUTDIR/tiles/forms/x${xoff}_y${yoff}.tif   > /dev/shm/x${xoff}_y${yoff}.txt 
min=$( awk \'{  print $2 }\' /dev/shm/x${xoff}_y${yoff}.txt  )
max=$( awk \'{  print $4 }\' /dev/shm/x${xoff}_y${yoff}.txt  )

if [[ $min -eq 1  &&  $max -eq 1 ]] ; then 
    echo remove the file $OUTDIR/tiles/forms/x${xoff}_y${yoff}.tif 
    rm -f  $OUTDIR/tiles/forms/x${xoff}_y${yoff}.tif 

else
    echo start the python for  $OUTDIR/asm/tiles/x${xoff}_y${yoff}.tif  
    python /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/Aggregation_GLCM.py -no 255  -m "ASM ENT" -o $RAM/MATRIX -pn $res $res  -mm 10 1 -l 10 -scale $OUTDIR/tiles/forms/x${xoff}_y${yoff}.tif 
    cp $RAM/MATRIX/ASM_x${xoff}_y${yoff}.tif  $OUTDIR/asm/tiles/HOM_x${xoff}_y${yoff}_km${km}.tif
    cp $RAM/MATRIX/ENT_x${xoff}_y${yoff}.tif  $OUTDIR/ent/tiles/ENT_x${xoff}_y${yoff}_km${km}.tif
fi
rm -f $RAM/MATRIX/ASM_x${xoff}_y${yoff}.tif   $RAM/MATRIX/ENT_x${xoff}_y${yoff}.tif  /dev/shm/x${xoff}_y${yoff}.txt 

' _ 

exit 


