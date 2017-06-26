# qsub   /lustre/home/client/fas/sbsc/ga254/scripts/GSHL/sc04_watershed.sh

#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# full process more than 4 our

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GSHL


echo  1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5  | xargs -n 1 -P 8 bash -c $'
BIN=$1
oft-stat  -mm -noavg -nostd -i $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin${BIN}_clump.tif -o  $DIR/computationalUNIT/compunit_bin${BIN}_tmp.txt    -um $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/watershed_poly.tif  

awk \' {  print $1 , int($4)   }\'  $DIR/computationalUNIT/compunit_bin${BIN}_tmp.txt  >   $DIR/computationalUNIT/compunit_bin${BIN}.txt 
rm -f   $DIR/computationalUNIT/compunit_bin${BIN}_tmp.txt  

' _ 

paste -d " "  compunit_bin1.5.txt <( awk '{  print $2 }' compunit_bin2.5.txt ) <( awk '{  print $2 }' compunit_bin3.5.txt )   <( awk '{  print $2 }' compunit_bin4.5.txt ) <( awk '{  print $2 }' compunit_bin5.5.txt )   <( awk '{  print $2 }' compunit_bin6.5.txt )  <( awk '{  print $2 }' compunit_bin7.5.txt ) <( awk '{  print $2 }' compunit_bin8.5.txt ) <( awk '{  print $2 }' compunit_bin9.5.txt )  > compunit_binAll_cump.txt 



