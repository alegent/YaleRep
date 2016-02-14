
# bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc12_point_extraction.sh
# qsub  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc12_point_extraction.sh


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

MSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/msktif
COR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation

gdalbuildvrt  -overwrite -separate $COR/point_sp/km${km}a.vrt $( for file in $( cat  $COR/list/list_km${km}_4corelation.txt | grep -v geomorphic_class | grep  -v  geomorphic_majority | grep  -v  geomorphic_count) ; do echo $MSK/$file ; done ) 

gdalbuildvrt  -overwrite -separate $COR/point_sp/km${km}b.vrt $( for file in $( cat  $COR/list/list_km${km}_4corelation.txt | grep  -e  geomorphic_class -e  geomorphic_majority -e  geomorphic_count  ) ; do echo $MSK/$file ; done ) 

echo extract  km $km

gdallocationinfo -geoloc -valonly  $COR/point_sp/km${km}a.vrt < $COR/point_sp/BBS_stops_x_y.txt | awk \'{printf "%s" (NR%28==0?RS:FS) , $1}\' > $COR/point_sp/km${km}a.txt 
gdallocationinfo -geoloc -valonly  $COR/point_sp/km${km}b.vrt < $COR/point_sp/BBS_stops_x_y.txt | awk \'{printf "%s" (NR%12==0?RS:FS) , $1}\' > $COR/point_sp/km${km}b.txt 

echo rearrange  km $km

#reduce the to 8 digitii floating point  

paste  -d " "  <( awk \'{  for (i=1;i<NF;i++) {printf ("%.8f " , $i) } printf ("%.8f" , $NF)  ; printf ("\\n")  }\'   $COR/point_sp/km${km}a.txt )   $COR/point_sp/km${km}b.txt   >  $COR/point_sp/km${km}.txt 

rm  $COR/point_sp/km${km}a.txt   $COR/point_sp/km${km}b.txt  

# this create the list but than the elevation are modified manualy
# echo "X Y SR" $( cat   $COR/list/list_km${km}_4corelation.txt | grep -v geomorphic_class | grep  -v  geomorphic_majority | grep  -v  geomorphic_count | awk -F "_" \'{  printf ("%s_%s ", $1 , $2 ) }\' ) $( cat   $COR/list/list_km${km}_4corelation.txt |  grep  -e  geomorphic_class -e  geomorphic_majority -e  geomorphic_count  | awk -F "_"  \'{  printf ("%s_%s ", $1 , $2 ) }\' ) >  $COR/point_sp/x_y_km${km}.txt

echo "X Y SR aspect-cosine_md aspect-sine_md dx_md dxx_md dy_md dyy_md eastness_md elevation_cv_mnpsd elevation_cv_mnsd elevation_md elevation_range elevation_sd_md elevation_sd_mn elevation_sd_sd elevation_psd_sd geomorphic_ent geomorphic_shannon geomorphic_uni northness_md pcurv_md roughness_md slope_cv slope_md slope_range tcurv_md tpi_md tri_md vrm_md geomorphic_class10 geomorphic_class1 geomorphic_class2 geomorphic_class3 geomorphic_class4 geomorphic_class5 geomorphic_class6 geomorphic_class7 geomorphic_class8 geomorphic_class9 geomorphic_count geomorphic_majority"  >  $COR/point_sp/x_y_km${km}.txt 

paste -d " "   <(awk -F ","  \'{ if (NR>1)  print $2, $3 , $4  }\'  BBS_stops.csv) $COR/point_sp/km${km}.txt  | grep -v 32767   >> $COR/point_sp/x_y_km${km}.txt

rm  $COR/point_sp/km${km}.txt  

' _ 




