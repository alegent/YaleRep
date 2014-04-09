
# cd /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv
# ls /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv/*TY.csv  | xargs -n 1 -P 10 bash /mnt/data2/scratch/GMTED2010/solar_radiation/scripts/sc1_nrel_day_sum.sh

INDIR=/mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv
file=$1
filename=$(basename $file .csv)

awk -F "," '{  if(NR>2) {  for (col=1;col<=NF-1;col++) {printf ("%s ", $col )} ; printf ("%s\n", $NF)}}'  $INDIR/${filename}.csv  | sort -k 1,1 -g > $INDIR/${filename}_s.txt

/mnt/data2/scratch/GMTED2010/solar_radiation/scripts/sum.sh  $INDIR/${filename}_s.txt  $INDIR/${filename}_sum.txt <<EOF
n
1
0
EOF

cat header.txt > $INDIR/${filename}_sumH.txt
# inserted to remove the last space after NF
awk  '{  for (col=1;col<=(NF-1);col++) {printf ("%s ", $col )} ; printf ("%s\n", $NF) }' $INDIR/${filename}_sum.txt >> $INDIR/${filename}_sumH.txt 
rm  $INDIR/${filename}_sum.txt $INDIR/${filename}_s.txt


