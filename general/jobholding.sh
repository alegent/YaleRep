
cd /lustre/scratch/client/fas/sbsc/sd566/global_hydrobasins/ 


awk 'NR%15==1 {x="F"++i;}{ print >  "future_scenarios_list_"x".txt"     }'  future_scenarios_list.txt

for list in $( ls future_scenarios_list_*.txt ) ; do 

    PREV_JOB=$(qsub start.sh)  

    for file in  $(cat $list )  ; do 
	NEXT_JOB=$(qsub -v file=$file  -W depend=afterany:$PREV_JOB script.sh) 
	PREV_JOB=$NEXT_JOB 
    done 
done


