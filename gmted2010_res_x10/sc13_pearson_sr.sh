# bash  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc13_pearson_sr.sh
# qsub  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc13_pearson_sr.sh


#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr



for km in 1 5 10 50 100 ; do  

export km=$km 
export COR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation

seq 4 43 | xargs -n 1 -P 8 bash -c $' seq=$1 ; echo $( head -1 $COR/point_sp/x_y_km${km}.txt | awk -v seq=$seq  \'{ print $seq  }\')  $( pearson_awk.sh $COR/point_sp/x_y_km${km}.txt  3 $seq ) ' _  | sort -k 2,2 -g  > $COR/point_sp/pearson_km${km}.txt 

done 


