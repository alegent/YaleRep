# growing the lst of 1 pixel
# qsub  -v SENS=MYD  /u/gamatull/scripts/LST/spline/sc3_sc4_allobservation_noenlarge4spline_krigingIndiaMOYD11A2.sh

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=1
#PBS -l walltime=8:00:00
#PBS -V
#PBS -o /nobackup/gamatull/stdout
#PBS -e /nobackup/gamatull/stderr

echo   /u/gamatull/scripts/LST/spline/sc3_sc4_allobservation_noenlarge4spline_MOYD11A2.sh   
export SENS=MYD
export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_mean
export OUTSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_spline4fill
export MSK=/nobackup/gamatull/dataproces/LST/${SENS}11A2_mean_msk
export RAMDIR=/dev/shm
export GMTED=/nobackupp8/gamatull/dataproces/GMTED2010
export CONSENSUS=/nobackupp8/gamatull/dataproces/CONSENSUS
export KRIG=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2_krig

rm -f /dev/shm/*

# cluster class to mask out 
# export geo_string="65 35 95 5"   # full india  
export geo_string="85 25 90 20"  # test area 

for q in $(seq 1 12) ; do
gdal_translate -ot Int16 -projwin $geo_string  -co COMPRESS=LZW -co ZLEVEL=9 ${CONSENSUS}/consensus_full_class_${q}.tif  ${KRIG}/india_cons_${q}.tif
done

for file  in eastness_md_GMTED2010_md.tif  northness_md_GMTED2010_md.tif  elevation_md_GMTED2010_md.tif  ; do
gdal_translate -projwin $geo_string  -co COMPRESS=LZW -co ZLEVEL=9 ${GMTED}/${file}  ${KRIG}/india_${file}
done                                                                           



module load R/3.1.1_rgal_nex


echo 137 145 153 161 169 177 185 193 201 209 217 225 233 241 249 
echo 209  | xargs -n 1 -P 44   bash -c $'

export DAY=$1 

gdal_translate -projwin $geo_string  -co COMPRESS=LZW -co ZLEVEL=9 ${INSENS}/LST_${SENS}_QC_day${DAY}_wgs84.tif ${KRIG}/indiaLST_${SENS}_day${DAY}_wgs84.tif

echo create lat long training 
rm -f ${KRIG}/indiaLST_${SENS}_day${DAY}_training_full.txt
oft-gengrid-latlong.bash   ${KRIG}/indiaLST_${SENS}_day${DAY}_wgs84.tif   10 10   ${KRIG}/indiaLST_${SENS}_day${DAY}_training_full.txt

echo extract the point information

oft-extr  -o  ${KRIG}/indiaLST_${SENS}_day${DAY}_spec_training_full.txt ${KRIG}/indiaLST_${SENS}_day${DAY}_training_full.txt  ${KRIG}/indiaLST_${SENS}_day${DAY}_wgs84.tif   <<EOF
2
3
EOF

paste -d " " <(   awk \'{ print $2 , $3   }\' ${KRIG}/indiaLST_${SENS}_day${DAY}_training_full.txt  )  <( awk \'{ print  $6  }\' ${KRIG}/indiaLST_${SENS}_day${DAY}_spec_training_full.txt  ) | awk \'{ if ($3>0) print $1 , $2 , $3  }\' > ${KRIG}/indiaLST_${SENS}_day${DAY}_training.txt

rm -f ${KRIG}/indiaLST_${SENS}_day${DAY}_spec_training_full.txt 
rm -f ${KRIG}/indiaLST_${SENS}_day${DAY}_training_full.txt
rm -f ${KRIG}/stack${DAY}.vrt

echo stack the image

gdalbuildvrt  -separate  ${KRIG}/stack${DAY}.vrt ${KRIG}/india_cons_?.tif    ${KRIG}/india_cons_??.tif ${KRIG}/india_elevation_md_GMTED2010_md.tif  ${KRIG}/india_eastness_md_GMTED2010_md.tif ${KRIG}/india_northness_md_GMTED2010_md.tif 

gdal_translate  -projwin   $geo_string  -co COMPRESS=LZW -co ZLEVEL=9 ${KRIG}/stack${DAY}.vrt ${KRIG}/stack${DAY}.tif

oft-extr -o ${KRIG}/indiaLST_${SENS}_day${DAY}_training_stack.txt  ${KRIG}/indiaLST_${SENS}_day${DAY}_training.txt  ${KRIG}/stack${DAY}.tif  <<EOF
1
2
EOF


awk \'{  printf ("%s " , $1) ; printf ("%s " , $2) ; printf ("%s " , $3) ;  for (i=6;i<NF;i++) {printf ("%i " , $i) } ; printf ("%i" , $NF) ; printf ("\\n")  }\' ${KRIG}/indiaLST_${SENS}_day${DAY}_training_stack.txt > ${KRIG}/indiaLST_${SENS}_day${DAY}_training_stack_clean.txt


R --vanilla -q <<EOF

library(raster)
library(gstat)

DAY = Sys.getenv(\'DAY\')
SENS = Sys.getenv(\'SENS\')

DAY="209"
SENS="MYD"

LST = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/indiaLST_",SENS,"_day", DAY , "_wgs84.tif",sep="")  , band=1)
NAvalue(LST)=0


india_cons_1 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_1.tif",sep="")  , band=1)
india_cons_2 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_2.tif",sep="")  , band=1)
india_cons_3 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_3.tif",sep="")  , band=1)
india_cons_4 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_4.tif",sep="")  , band=1)
india_cons_5 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_5.tif",sep="")  , band=1)
india_cons_6 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_6.tif",sep="")  , band=1)
india_cons_7 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_7.tif",sep="")  , band=1)
india_cons_8 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_8.tif",sep="")  , band=1)
india_cons_9 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_9.tif",sep="")  , band=1)
india_cons_10 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_10.tif",sep="")  , band=1)
india_cons_11 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_11.tif",sep="")  , band=1)
india_cons_12 = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_cons_12.tif",sep="")  , band=1)

india_eastness = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_eastness_md_GMTED2010_md.tif",sep="")  , band=1)
india_northness = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_northness_md_GMTED2010_md.tif",sep="")  , band=1)
india_elevation = raster(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/india_elevation_md_GMTED2010_md.tif",sep="")  , band=1)

stack = stack( LST , india_cons_1 , india_cons_2 , india_cons_3 , india_cons_4, india_cons_5, india_cons_6 , india_cons_7 , india_cons_8 , india_cons_9 , india_cons_10 , india_cons_11 , india_cons_12 , india_elevation , india_eastness , india_northness )

training = read.table(paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/indiaLST_",SENS,"_day",DAY,"_training_stack_clean.txt", sep="") , sep=" " )

names(training)[1] ="X"
names(training)[2] ="Y"
names(training)[3] ="LST"
names(training)[4] ="india_cons_1"
names(training)[5] ="india_cons_2"
names(training)[6] ="india_cons_3"
names(training)[7] ="india_cons_4"
names(training)[8] ="india_cons_5"
names(training)[9] ="india_cons_6"
names(training)[10] ="india_cons_7"
names(training)[11] ="india_cons_8"
names(training)[12] ="india_cons_9"
names(training)[13] ="india_cons_10"
names(training)[14] ="india_cons_11"
names(training)[15] ="india_cons_12"
names(training)[16] ="india_elevation"
names(training)[17] ="india_eastness"
names(training)[18] ="india_northness"

coordinates(training) <- ~X+Y
projection(training) <- projection(LST)

gCoK <- gstat(NULL, "LST", LST~1, training)
gCoK <- gstat(gCoK, "india_cons_1", india_cons_1~1, training)
gCoK <- gstat(gCoK, "india_cons_2", india_cons_2~1, training)
gCoK <- gstat(gCoK, "india_cons_3", india_cons_3~1, training)
gCoK <- gstat(gCoK, "india_cons_4", india_cons_4~1, training)
gCoK <- gstat(gCoK, "india_cons_5", india_cons_5~1, training)
gCoK <- gstat(gCoK, "india_cons_6", india_cons_6~1, training)
gCoK <- gstat(gCoK, "india_cons_7", india_cons_7~1, training)
gCoK <- gstat(gCoK, "india_cons_8", india_cons_8~1, training)
gCoK <- gstat(gCoK, "india_cons_9", india_cons_9~1, training)
gCoK <- gstat(gCoK, "india_cons_10", india_cons_10~1, training)
gCoK <- gstat(gCoK, "india_cons_11", india_cons_11~1, training)
gCoK <- gstat(gCoK, "india_cons_12", india_cons_12~1, training)
gCoK <- gstat(gCoK, "india_elevation", india_elevation~1, training)
gCoK <- gstat(gCoK, "india_eastness", india_eastness~1, training)
gCoK <- gstat(gCoK, "india_northness", india_northness~1, training)

coV <- variogram(gCoK)
# plot(coV, type="b", main="Co-variogram")
coV.fit <- fit.lmc(coV, gCoK, vgm(model="Sph", range=1000))
coV.fit

coK <- interpolate(stack, coV.fit)
plot(coK)

writeRaster(coK, filename="paste("/nobackupp8/gamatull/dataproces/LST/",SENS,"11A2_krig/LST_predict.tif",sep="") , options="COMPRESS=LZW"  ,   format="GTiff", overwrite=TRUE)  )

EOF

' _ 


