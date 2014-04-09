# rm  /lustre0/scratch/ga254/stdout/* /lustre0/scratch/ga254/stderr/*  
# for file   in /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/be75_grd_tif/?_?.tif  ; do  qsub -v file=$file   /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_res_x10/sc01_reproject_be75_bj.sh  ; done 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr


OUTDIR=/lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/
filename=`basename $file`

gdalwarp -r cubicspline  -co COMPRESS=LZW -t_srs /lustre0/scratch/ga254/dem_bj/GMTED2010/prj/6974.prj  $file $OUTDIR/be75_grd_tif_SR-ORG6974/$filename  -multi -overwrite
