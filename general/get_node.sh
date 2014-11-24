#PBS -S /bin/bash
#PBS -q fas_devel
#PBS -l walltime=04:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -m abe

rm -f  /home/fas/sbsc/ga254/node.txt
checkjob -v $PBS_JOBID | grep "Task Distribution" | awk '{ print $3 }' > /home/fas/sbsc/ga254/node.txt

sleep 3.59h

rm -f  /home/fas/sbsc/ga254/node.txt
