
#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:10:00:00  
#PBS -l mem=34g
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


echo $JOBID  >  ~/test0.txt 
