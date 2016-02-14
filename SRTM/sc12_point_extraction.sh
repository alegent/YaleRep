# bash  /home/fas/sbsc/ga254/scripts/SRTM/sc12_point_extraction.sh 
# qsub  /home/fas/sbsc/ga254/scripts/SRTM/sc12_point_extraction.sh

# ll */median/*_median_km50.tif   */stdev/*_stdev_km50.tif  */median/*_median_*_km50.tif   */stdev/*_stdev_*_km50.tif   | awk '{ print $9  }'   > correlation/list/list_km50_4corelation.txt

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/point_sp

# awk -F ","  '{ if (NR>1)  print $2, $3  }'  BBS_stops.csv  >  BBS_stops_x_y.txt

echo 1 5 10 50 100 | xargs -n 1 -P 8 bash -c $' 

km=$1

SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM
COR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/correlation

gdalbuildvrt  -overwrite -separate $COR/vrt/km${km}a.vrt $( for file in $( cat  $COR/list/list_km${km}_4corelation.txt ) ; do echo $SRTM/$file ; done)

echo extract  km $km

gdallocationinfo -geoloc -valonly  $COR/vrt/km${km}a.vrt < $COR/point_sp/BBS_stops_x_y.txt | awk \'{printf "%s" (NR%20==0?RS:FS) , $1}\' > $COR/point_sp/km${km}a.txt 

echo rearrange  km $km

# reduce the to 8 digitii floating point  

awk \'{  for (i=1;i<NF;i++) {printf ("%.8f " , $i) } printf ("%.8f" , $NF)  ; printf ("\\n")  }\'   $COR/point_sp/km${km}a.txt >  $COR/point_sp/km${km}.txt 

# rm  $COR/point_sp/km${km}a.txt  

echo "X Y SR altitude_median altitude_stdev aspect_median_cos aspect_median_Ew aspect_median_Nw aspect_median_sin aspect_stdev_cos aspect_stdev_Ew aspect_stdev_Nw aspect_stdev_sin roughness_median roughness_stdev slope_median slope_stdev tpi_median tpi_stdev tri_median tri_stdev vrm_median vrm_stdev"  >  $COR/point_sp/x_y_km${km}.txt 

paste -d " "   <(awk -F ","  \'{ if (NR>1)  print $2, $3 , $4  }\'  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/point_sp/BBS_stops.csv) $COR/point_sp/km${km}.txt  | grep -v 32767   >> $COR/point_sp/x_y_km${km}.txt

rm  $COR/point_sp/km${km}.txt  

' _ 





