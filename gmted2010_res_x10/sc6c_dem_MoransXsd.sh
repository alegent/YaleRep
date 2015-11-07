# for file   in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/moran/tiles/1_1.tif    ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_dem_MoransXsd.sh  ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export IND_MO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/moran/tiles
export IND_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled/
export RAM=/dev/shm
export file=$1
export filename=$(basename $file .tif) 

# funziona ma l ho abandonato difficile interpretazione morans i of the sd 

rm -rf  /dev/shm/*

oft-calc -ot Float32   $IND_MO/$filename.tif $RAM/$filename.tif <<EOF
1
#1 1 *
EOF

pksetmask  -co COMPRESS=LZW -co ZLEVEL=9   -i  $RAM/$filename.tif  -m   $RAM/$filename.tif   -msknodata -2 -p '<' -nodata 2   -o $RAM/${filename}_msk.tif

gdal_edit.py -tr 0.008333333333333 -0.008333333333333 $RAM/${filename}_msk.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -projwin  $( getCorners4Gtranslate $RAM/$filename.tif) /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled/elevation_sd_GMTED2010_sd.tif $RAM/${filename}_sd.tif

rm -f  $RAM/${filename}.vrt
gdalbuildvrt -overwrite -separate   $RAM/${filename}.vrt    $RAM/${filename}_msk.tif  $RAM/${filename}_sd.tif


oft-calc  -ot Float32   $RAM/$filename".vrt"  $RAM/$filename"_index.tif" <<EOF
1
#2 #1 - #2 #1 + /
EOF

oft-calc -ot Float32     $RAM/$filename".vrt"  $RAM/$filename"_moranXsd.tif" <<EOF
1
#1 #2 *
EOF

