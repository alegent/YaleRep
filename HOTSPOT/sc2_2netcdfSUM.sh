
# qsub  -W depend=afterany$(qstat -u $USER  | grep sc1_rasterize.sh   | awk -F . '{  printf (":%i" ,  $1 ) }' | awk '{   printf ("%s\n" , $1 ) }')  /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc2_2netcdfSUM.sh  

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

module load Tools/CDO/1.6.4 

export RAM=/dev/shm
export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT

for GROUP in TERRESTRIAL_MAMMALS REPTILES AMPHIBIANS MANGROVES MARINE_MAMMALS CORALS MARINEFISH  ; do  
for RES in 0.25d  1d ; do
echo start group sum $GROUP 

export GROUP
export RES

echo $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP $GROUP 

rm -f  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum*_1stk_${RES}.nc   $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum*_2stk_${RES}.nc  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum*_3stk_${RES}.nc 

find   $DIR/tif_${RES}/$GROUP -name "*.nc"    | xargs -n 30 -P 8  bash -c $'
                                                                                                                                                                                     
FIDname=$(echo $(basename ${1} ${RES}.nc  ) | tr "${GROUP}_sum" " " | awk \'{print  $1 }\' )

echo $FIDname   adsfffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

cdo  -b I32 -z zip_9 -f nc4  enssum  ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_1stk_${RES}.nc 

' _ 

echo start second itereation  start second itereation start second itereation start second itereation start second itereation start second itereation start second itereation start second itereation start second itereation 

find   $DIR/tif_${RES}_stack/$GROUP -name "*_1stk_*.nc"    | xargs -n 30 -P 8  bash -c $'
                                                                                                                                                                                     
FIDname=$(echo $(basename ${1} _1stk_${RES}.nc  ) | tr "${GROUP}_sum" " " | awk \'{print  $1 }\' )

echo $FIDname   adsfffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
cdo   -b I32 -z zip_9 -f nc4  enssum  ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30}  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_2stk_${RES}.nc 

' _ 

echo start therd itereation  start therd itereation start therd itereation start therd itereation start therd itereation start therd itereation start therd itereation start therd itereation start therd itereation start therd itereation 

find   $DIR/tif_${RES}_stack/$GROUP -name "*_2stk_*.nc"    | xargs -n 30 -P 8  bash -c $'
                                                                                                                                                                                     
FIDname=$(echo $(basename ${1} _2stk_${RES}.nc  ) | tr "${GROUP}_sum" " " | awk \'{print  $1 }\' )

echo $FIDname   adsfffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

rm  -f $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_3stk_${RES}.nc

cdo  -b I32 -z zip_9 -f nc4  enssum  ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20} ${21} ${22} ${23} ${24} ${25} ${26} ${27} ${28} ${29} ${30} $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_3stk_${RES}.nc 
gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_3stk_${RES}.nc  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_3stk_${RES}.tif 

rm -f $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.shp  
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum${FIDname}_3stk_${RES}.tif   -o $DIR/tif_${RES}_stack/$GROUP/360x114global_${GROUP}_sum_${RES}.shp  


' _ 

rm -f  $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum*_1stk_${RES}.nc   $DIR/tif_${RES}_stack/${GROUP}/${GROUP}_sum*_2stk_${RES}.nc  

done 
done 

for RES in 1d 0.25d ; do

rm -f   /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/BIRDS/BIRDS_sumALL_3stk_${RES}.nc 
cdo  -b I32 -z zip_9 -f nc4 enssum /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}/BIRDS/BIRDS_sum*_${RES}.nc    /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/BIRDS/BIRDS_sumALL_3stk_${RES}.nc 
gdal_translate  -ot UInt32  -co COMPRESS=DEFLATE -co ZLEVEL=9    /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/BIRDS/BIRDS_sumALL_3stk_${RES}.nc  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/BIRDS/BIRDS_sumALL_3stk_${RES}.tif 


rm -f  $DIR/tif_${RES}_stack/BIRDS/360x114global_BIRDS_sum_${RES}.*
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i  /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/tif_${RES}_stack/BIRDS/BIRDS_sumALL_3stk_${RES}.tif -o $DIR/tif_${RES}_stack/BIRDS/360x114global_BIRDS_sum_${RES}.shp  



done  

echo  overall sum 

for RES in 1d 0.25d ; do

rm -f   /dev/shm/output$RES.vrt
gdalbuildvrt  -overwrite  -separate -te -180 -90 +180 +90   /dev/shm/output$RES.vrt   $DIR/tif_${RES}_stack/*/*_sum*_3stk_${RES}.tif
oft-calc -ot UInt32   /dev/shm/output$RES.vrt   $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif <<EOF
1
#1 #2 #3 #4 #5 #6 #7 #8 + + + + + + +
EOF

rm -f   $DIR/tif_${RES}_stack/360x114global_allgroup_sum_${RES}.*
pkextract -r mean  -f  "ESRI Shapefile" -srcnodata -9999 -polygon  --bname Nsp_Mean  -s /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i  $DIR/tif_${RES}_stack/allgroup_sum_${RES}.tif  -o $DIR/tif_${RES}_stack/360x114global_allgroup_sum_${RES}.shp

done 
