



#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=0:10:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
# module load Tools/PKTOOLS/2.4.2   # exclued to load the pktools from the $HOME/bin
module load Libraries/OSGEO/1.10.0
module load Libraries/GSL
module load Libraries/ARMADILLO



OUTTXT=/lustre0/scratch/ga254/dem_bj/WWF_ECO/txt_output 

cat  $OUTTXT/wwf_eco_*_*.txt   | sort -k 1,1 > $OUTTXT/wwf_eco_all.txt


/lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sum.sh  $OUTTXT/wwf_eco_all.txt $OUTTXT/wwf_eco_sum.txt <<EOF
n
1
0
EOF


echo "ID pixNumb sumTreePerc sumGain sumLoss" > $OUTTXT/wwf_eco_sum_header.txt
cat  $OUTTXT/wwf_eco_sum.txt  >> $OUTTXT/wwf_eco_sum_header.txt

