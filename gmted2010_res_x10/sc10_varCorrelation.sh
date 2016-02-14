# for km in 5 10 50 100 ; do qsub -v km=$km  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc10_varCorrelation.sh  ; done

# il km 1 va in multi node con la sequenaza 1 7  
# for list  in $(seq 1 7) ; do for km in 1  ; do qsub -v km=$km,list=$list  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc10_varCorrelation.sh  ; done ; done 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/list
# grep -e _md_G -e elevation_range -e elevation_cv -e elevation_sd -e elevation_psd -e slope_range -e slope_cv -e geomorphic /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/list/list_km1.txt > /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/list/list_km1_4corelation.txt
# awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list4corelation"x"_km1.txt" }' list_km1_4corelation.txt

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:4:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final
export km=$km
export list=$list


if [ $km -gt 2  ] ; then list_file=list_km${km}.txt  ; fi 
if [ $km -eq 1  ] ; then list_file=tiles16_listF${list}_km1.txt  ; fi 

export list_file 

cat  $DIR/list/$list_file    | xargs -n 1 -P 8 bash -c $' 
file=$1  
filename=$( basename $file .tif )

pksetmask -co  COMPRESS=LZW -co ZLEVEL=9 -msknodata 0 -nodata -32767 -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/mask/maskLST_4GMTED.tif -i $DIR/$file -o  /dev/shm/${filename}_msk.tif 

pkreclass -of GTiff  -r -32768 -c  -9999  -co COMPRESS=LZW -co ZLEVEL=9 -i  /dev/shm/${filename}_msk.tif -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/msktif/${filename}_msk.tif
rm -f  /dev/shm/${filename}_msk.tif 
' _ 

exit 


if [ $km -gt 2  ] ; then list_file=list_km${km}_4corelation.txt  ; fi 
if [ $km -eq 1  ] ; then list_file=tiles8_list4corelationF${list}_km1.txt   ; fi 

export list_file 

echo $list_file

cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/list/$list_file  | xargs -n 1 -P 8 bash -c $' 

RAM=/dev/shm
DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation
MSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/msktif

export filename1=$(basename $1 )

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/${filename1}.txt

for file2 in $(cat   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/list/list_km${km}_4corelation.txt   ) ; do 

filename2=$(basename $file2  )
echo correlation for $filename1  $filename2
# reg is the first value 

pkstat -nodata -32767 -preg  -reg -i $MSK/$filename1 -i $MSK/$filename2 > /dev/shm/${filename1}_${filename2}.txt
echo $filename1 $filename2  $( head -1  /dev/shm/${filename1}_${filename2}.txt ) $(tail -2 /dev/shm/${filename1}_${filename2}.txt | head -1   )   >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/txt/${filename1}.txt
rm /dev/shm/${filename1}_${filename2}.txt
done 

' _ 

exit 


