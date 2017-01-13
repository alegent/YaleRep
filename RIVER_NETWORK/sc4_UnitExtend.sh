# bash  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc4_UnitExtend.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=8:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG

sort -k 2,2 -g /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3.txt  >   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt

tail -13   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt | head -12  | xargs -n 2 -P 8 bash -c $' 

geo_string=$( oft-bb $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif  $1  | grep BB | awk \'{ print $6,$7,$8-$6,$9-$7 }\')

gdal_translate   -co COMPRESS=DEFLATE -co ZLEVEL=9  -srcwin  $geo_string  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT$1.tif 

pkgetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Byte -min $1 -max $1 -data 1 -nodata 0 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT$1.tif  -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT${1}msk.tif 

' _

# EUROASIA camptacha 19899 

geo_string=$( oft-bb $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif 19899  | grep BB | awk '{ print $6,$7,$8-$6,$9-$7 }')
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  -srcwin  $geo_string  $DIR/GSHHS_land_mask250m_enlarge_clump_UNIT3.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT19899.tif 
pkgetmask -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Byte -min 19899 -max 19899  -data 1 -nodata 0 -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT19899.tif  -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/unit/UNIT19899msk.tif 

exit 


# start script sc5 and followed by sc6

for UNIT in 1 2 3 4 5 6 7 8 90420 10328 80691 84397 2285 26487 33778 92404 11000 11001 98343 91518 ; do qsub -v UNIT=$UNIT  /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc5_river_newtworkGMTED250.sh ; done  
qsub  -W depend=afterany$(qstat -u $USER  | grep sc5_river_newtwo     | awk -F . '{  printf (":%i" ,  $1 ) }' | awk '{   printf ("%s\n" , $1 ) } ' ) /lustre/home/client/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc6_continentisland_merge_oft-calc.sh 


exit 

tail -13   /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_NETWORK/GSHHG/GSHHS_land_mask250m_enlarge_clump_UNIT3_s.txt | head -12

90420 11750011      MADAGASCAR        
10328 12535192      canada island 
80691 13772932     indonesia 
84397 14731200     guinea 
2285 22431475      canada island 
26487 26414813     canada island 
33778 150020638    greenland      
92404 158200595     AUSTRALIA
11000 350855901     south america 
11001 576136081     africa 
98343 596887982     north america 
91518 1474765872    EUROASIA    

19899               EUROASIA camptacha

