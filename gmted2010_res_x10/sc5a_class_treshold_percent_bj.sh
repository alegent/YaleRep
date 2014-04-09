
# calculate altitude area percent above a specific treshold
# e.g  75% of class200 means that 75% of the pixels is >= 200 
# for this case the treshold is set every 100 meter
# geting the integer of the altitued / 100
# 230 become class 200
# 159 become class 100

#  for file in /mnt/data2/dem_variables/GMTED2010/tiles/mi75_grd_tif/*.tif ; do echo $file mi ; done  | xargs -n 2 -P 25  bash /mnt/data2/dem_variables/GMTED2010/scripts/sc2_class_treshold_percent.sh 
#  for file in /mnt/data2/dem_variables/GMTED2010/tiles/mx75_grd_tif/*.tif ; do echo $file mx ; done  | xargs -n 2 -P 25  bash /mnt/data2/dem_variables/GMTED2010/scripts/sc2_class_treshold_percent.sh 

# run the script in the  @bulldogj 

# rm /lustre0/scratch/ga254/stderr/* ; rm /lustre0/scratch/ga254/stdout/* ; 

# for file in /home2/ga254/scratch/dem_bj/GMTED2010/tiles/mi75_grd_tif/*.tif  ; do qsub -v file=$file,mm=mi   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc5a_class_treshold_percent_bj.sh  ; done 

# for file in /home2/ga254/scratch/dem_bj/GMTED2010/tiles/md75_grd_tif/*.tif  ; do qsub -v file=$file,mm=md   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc5a_class_treshold_percent_bj.sh  ; done 

# for file in /home2/ga254/scratch/dem_bj/GMTED2010/tiles/mx75_grd_tif/*.tif  ; do qsub -v file=$file,mm=mx   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc5a_class_treshold_percent_bj.sh  ; done 

# to check 
# ny=45 ; for n in `seq 1 9` ;do echo `gdallocationinfo -valonly altitude/class/5_1_class_tmp3.tif 2$n $ny` `gdallocationinfo  -valonly  tiles/mn75_grd_tif/5_1.tif 2$n $ny` ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=14:00:00
#PBS -l nodes=10:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

# load moduels 

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

# file=$1    
# mm=$2     

file=${file}  
mm=${mm}

filename=$(basename $file .tif)

echo $file
echo $mm

INDIR=/home2/ga254/scratch/dem_bj/GMTED2010/tiles/$mm"75_grd_tif"
OUTDIR=/home2/ga254/scratch/dem_bj/GMTED2010/altitude/class_$mm/class

echo  calcualte altitude  every 100 meter  using the the Int16 factors for $file 

time (

gdal_calc.py -A  $INDIR/$filename.tif   --calc="(A / 100)"  --outfile=/tmp/$filename"_class_tmp1.tif" --type=Int16 --overwrite --co=COMPRESS=LZW 
gdal_calc.py -A  /tmp/$filename"_class_tmp1.tif" --calc="(A * 100)" --outfile=/tmp/$filename"_class_tmp2.tif" --type=Int16 --overwrite --co=COMPRESS=LZW 
rm /tmp/$filename"_class_tmp1.tif" 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  /tmp/$filename"_class_tmp2.tif" $OUTDIR/$filename"_class.tif"
rm /tmp/$filename"_class_tmp2.tif"


gdalinfo -mm $OUTDIR/$filename"_class.tif"  | grep Computed | awk '{ gsub ("[=,]"," "); print int($(NF-1)), int($(NF))}' > $OUTDIR/../tmp/$filename"_min_max_"$mm.txt

echo min and max for $OUTDIR/../tmp/$filename"_min_max_"$mm.txt

# start to calculate for each treshold percent pixel
 
for class in $(seq `awk '{ print $1}'  $OUTDIR/../tmp/${filename}_min_max_${mm}.txt` 100    `awk '{ print $2}' $OUTDIR/../tmp/${filename}_min_max_${mm}.txt` ) ; do 

    class_start=$class
    class_end=$(awk '{ print $2}'  $OUTDIR/../tmp/${filename}_min_max_${mm}.txt)
    class_string=$(for class_unique in $(seq $class_start 100  $class_end  ) ; do echo -n "-class $class_unique "  ; done) 

    echo applaid the filter for the classes  $class_string

    /home2/ga254/bin/bin/pkfilter  -dx 4 -dy 4 $class_string -f density -d 4 -i $OUTDIR/$filename"_class.tif" -o $OUTDIR/../class$class/$filename"_C"$class"Perc.tif" -co COMPRESS=LZW -co ZLEVEL=9 -ot Byte 

done 

)

checkjob -v $PBS_JOBID
