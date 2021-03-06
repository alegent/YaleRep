# rm  /lustre0/scratch/ga254/stdout/* /lustre0/scratch/ga254/stderr/*  
# for file   in /lustre0/scratch/ga254/dem_bj/HYDRO1k/gt30h1k??/??_fa.tif   ; do  qsub -v file1k=$file  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/HYDRO1k/sc2_reprojectiling_toEPSG4326_bj.sh  ; done 

# bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/HYDRO1k/sc2_reprojectiling_toEPSG4326_bj.sh  /lustre0/scratch/ga254/dem_bj/HYDRO1k/gt30h1keu/eu_fa.tif


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l mem=4gb
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=4
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 
#PBS -e /lustre0/scratch/ga254/stderr

#file1k=$1
export $file1k
export CONT=`basename $file1k _fa.tif`
export OUTDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k/tiles
export INDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k

echo processing $CONT 

ls /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/be75_grd_tif_16overlap/?_?.tif | xargs -n 1 -P 10  bash -c $' 
file=$1
filename=`basename $file`
INDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k
OUTDIR=/lustre0/scratch/ga254/dem_bj/HYDRO1k/tiles

gdalwarp  -ot UInt32 -wt UInt32 -srcnodata 4294957297  -dstnodata 4294957297  -multi -te $(~/bin/getCorners4Gwarp $file) -tr 0.002083333333333 0.002083333333333  -r bilinear  -co COMPRESS=LZW -t_srs /lustre0/scratch/ga254/dem_bj/GMTED2010/prj/4326.prj   $INDIR/gt30h1k$CONT/${CONT}_fa.tif $OUTDIR/${CONT}_$filename -overwrite

min=$(gdalinfo -mm  $OUTDIR/${CONT}_$filename  | grep Compute   | awk \'{ gsub ("=,"," ")  ;  print  int($1)  }\')
echo $min 
if [ "$min" = ""  ] ; then 
    rm -f $OUTDIR/${CONT}_$filename 
fi

' - 
