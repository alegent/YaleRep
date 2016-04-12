# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

# for list in /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/list/tiles8_list12000F*.txt  ; do   for km in 1 5 10 50 100 ; do qsub  -v km=$km,list=$list   /home/fas/sbsc/ga254/scripts/SRTM/sc3a_dem_variables_float_noMult_resKM.sh ; done ; done  

# for the full computation 14 


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:14:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=34
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/tiles
export list=$list
export km=$km 

# for testing
# export list=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/geo_file/list/tiles16_listF6.txt
# export km=50

export res=$( expr $km \* 10)

# tot file 872

cat $list  | xargs -n 1 -P 8  bash -c $' 

file=$1
filename=$(basename $file .vrt )

echo vrt    $SRTM/altitude/vrt/${filename}_clip.vrt   
gdal_translate -of VRT   -srcwin 1 1 12000 12000   $SRTM/altitude/tiles/$filename.tif     $SRTM/altitude/vrt/${filename}_clip${km}.vrt   

# for MAT in mean median min max stdev ; do
#      pkfilter  -nodata -32768  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32 -of GTiff -nodata -9999 -dx $res -dy $res -f $MAT -d $res -i $SRTM/altitude/vrt/${filename}_clip${km}.vrt -o $SRTM/altitude/$MAT/tiles/${filename}_km$km.tif
# done 

# for TOPO in  slope tpi tri vrm roughness ; do 
for TOPO in  vrm ; do 
    gdal_translate -of VRT  -srcwin 1 1 12000 12000  $SRTM/${TOPO}/tiles/$filename.tif  $SRTM/${TOPO}/vrt/${filename}_clip${km}.vrt 
    for MAT in mean median min max stdev ; do                                                                                                         
    echo  $TOPO  $MAT $res 

    pkfilter -nodata -9999 -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32 -of GTiff -nodata -9999 -dx $res -dy $res -f $MAT -d $res -i  $SRTM/${TOPO}/vrt/${filename}_clip${km}.vrt  -o $SRTM/$TOPO/$MAT/tiles/${filename}_km$km.tif
    done 
done
 
# TOPO=aspect
# for DER in sin cos Ew Nw ; do 
# echo vrt 
# gdal_translate -of VRT   -srcwin 1 1 12000 12000  $SRTM/${TOPO}/tiles/${filename}_${DER}.tif    $SRTM/${TOPO}/vrt/${filename}_${DER}_clip${km}.vrt  
#     for MAT in mean median min max stdev ; do                                                                                                         
#         echo $TOPO $MAT $res 
#         pkfilter  -nodata -9999   -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32 -of GTiff -nodata -9999 -dx $res -dy $res -f $MAT -d $res -i  $SRTM/${TOPO}/vrt/${filename}_${DER}_clip${km}.vrt  -o $SRTM/$TOPO/$MAT/tiles/${filename}_${DER}_km$km.tif 
#     done
# done

' _ 


rm -rf /dev/shm/*

exit 


