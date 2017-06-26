
#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:10:00:00  
#PBS -l mem=34g
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


echo $JOBID  >  ~/test$seq.txt 
sleep 10

# for seq  in $(seq 1 10) ; do PREV_JOB$seq=$(qsub start.sh) ; done   ;   for seq  in $(SEQ 11 111)  ; do NEXT_JOB=(qsub -v seq=$seq -W depend=afterany:$PREV_JOB$(expr $SEQ - 10 )    script.sh) ; PREV_JOB$SEQ=$NEXT_JOB ;   done 



cd /lustre/scratch/client/fas/sbsc/sd566/global_hydrobasins/ 


awk 'NR%15==1 {x="F"++i;}{ print >  "future_scenarios_list_"x".txt"     }'  future_scenarios_list.txt

for list in $( ls future_scenarios_list_*.txt ) ; do 

    PREV_JOB=$(qsub start.sh)  

    for file in  $(cat $list )  ; do 
	NEXT_JOB=$(qsub -v file=$file  -W depend=afterany:$PREV_JOB script.sh) 
	PREV_JOB=$NEXT_JOB 
    done 
done






