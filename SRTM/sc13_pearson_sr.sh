# bash  /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc13_pearson_sr.sh
# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/SRTM/sc13_pearson_sr.sh


#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr



for km in 1 5 10 50 100 ; do  

export km=$km 
export COR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/correlation

seq 4 23 | xargs -n 1 -P 8 bash -c $' 
seq=$1 

echo $( head -1 $COR/point_sp/x_y_km${km}.txt | awk -v seq=$seq  \'{ print $seq  }\')  $( pearson_awk.sh $COR/point_sp/x_y_km${km}.txt  3 $seq ) 

' _  | sort -k 2,2 -g  > $COR/pearson/pearson_km${km}.txt 

done 

exit 
# lanciati a mano

for var in tpi tri vrm slope roughness ; do 
for km in 1 5 10 50 100 ; do 
echo $(grep ${var}_median  $COR/pearson/pearson_km${km}.txt   | awk ' { print $2 }' ) $( grep ${var}_md   $COR/../../GMTED2010/correlation/point_sp/pearson_km${km}.txt   |  awk  ' { print $2 }' ) 
done > $COR/pearson/pearson_${var}_SRTM_GMTED.txt 
done 

for km in 1 5 10 50 100 ; do 
echo $(grep altitude_median  $COR/pearson/pearson_km${km}.txt   | awk ' { print $2 }' ) $( grep elevation_md   $COR/../../GMTED2010/correlation/point_sp/pearson_km${km}.txt   |  awk  ' { print $2 }' ) 
done > $COR/pearson/pearson_altitude_SRTM_GMTED.txt 

for km in 1 5 10 50 100 ; do 
echo $(grep  aspect_median_Nw  $COR/pearson/pearson_km${km}.txt   | awk ' { print $2 }' ) $( grep northness_md   $COR/../../GMTED2010/correlation/point_sp/pearson_km${km}.txt   |  awk  ' { print $2 }' ) 
done > $COR/pearson/pearson_northness_SRTM_GMTED.txt 

for km in 1 5 10 50 100 ; do 
echo $(grep  aspect_median_Ew  $COR/pearson/pearson_km${km}.txt   | awk ' { print $2 }' ) $( grep eastness_md   $COR/../../GMTED2010/correlation/point_sp/pearson_km${km}.txt   |  awk  ' { print $2 }' ) 
done > $COR/pearson/pearson_eastness_SRTM_GMTED.txt 












