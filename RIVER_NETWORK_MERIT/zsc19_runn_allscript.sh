

sbatch   /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc01_wget_merit_river.sh
sleep 30 
sbatch  --dependency=afterok:$(qmys | grep sc01_wget_merit_river.sh  | awk '{  print $1 }'  | uniq )    /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc02_layers_preparation.sh
sleep 30 
for TOPO in altitude ; do
for MATH in min ; do 
for  KM in 0.2 0.3 0.4 0.5 ; do  
sbatch --dependency=afterok:$(qmys | grep sc01_wget_merit_river.sh  | awk '{  print $1 }'  | uniq )  \
 -o  /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc04_elvCorrect_MultiResKM${KM}TOPO${TOPO}MATH${MATH}.sh.%J.out \
 -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc04_elvCorrect_MultiResKM${KM}TOPO${TOPO}MATH${MATH}.sh.%J.err \
 -J sc04_elvCorrect_MultiResKM${KM}TOPO${TOPO}MATH${MATH}.sh --export=TOPO=$TOPO,MATH=$MATH,KM=$KM /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc04_elvCorrect_MultiRes.sh  
done   
done 
done
sleep 30 
for TOPO in altitude ; do  
for MATH in min ; do 
for  KM in 0.2 0.3 0.4 0.5 ; do  
sbatch  --dependency=afterok$( qmys | grep sc04_elvCorrect_MultiRes  | awk '{  printf (":%i" ,  $1 ) }'  | uniq  )  \
 -o  /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc05_elvCorrect_MultiResMergingKM${KM}TOPO${TOPO}MATH${MATH}.sh.%J.out \
 -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc05_elvCorrect_MultiResMergingKM${KM}TOPO${TOPO}MATH${MATH}.sh.%J.err \
-J sc05_elvCorrect_MultiResMergingKM${KM}TOPO${TOPO}MATH${MATH}.sh  --export=TOPO=$TOPO,MATH=$MATH,KM=$KM /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc05_elvCorrect_MultiResMerging.sh 
done
done
done
sleep 30 

