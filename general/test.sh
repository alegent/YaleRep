#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:02:00
#PBS -l nodes=1:ppn=1
#PBS -l mem=34gb
#PBS -l epilogue=$HOME/bin/epilogue_script.sh
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID 
checkjob -v $PBS_JOBID  >  /scratch/fas/sbsc/ga254/stdnode/test.sh.$PBS_JOBID.txt

seq 1 444444444444444 > /dev/shm/txt.txt 

checkjob -v $PBS_JOBID 
checkjob -v $PBS_JOBID  >>  /scratch/fas/sbsc/ga254/stdnode/test.sh.$PBS_JOBID.txt