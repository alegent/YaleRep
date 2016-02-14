# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
#  awk 'NR%4==1 {x="F"++i;}{ print >   "tiles4_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list

# for list in tiles8_listF*.txt; do qsub -v list=$list /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult-aspect.sh ; done

# for list  in  tiles8_listF3.txt  ; do bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult.sh   $list  ; done


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# list=$1

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list/$list | xargs -n 1 -P 8  bash -c $' 

INDIR_MI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mi75_grd_tif
INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
INDIR_MX=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mx75_grd_tif
INDIR_MN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mn75_grd_tif
TMP=/dev/shm

export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
export filename=$(basename $1 .tif)

# form here only md will be used

INDIR=$INDIR_MD
mm=md

echo  slope with file   $INDIR/$filename.tif
gdaldem slope  -s 111120 -co COMPRESS=DEFLATE -co ZLEVEL=9  -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/slope/tiles/${filename}_${mm}.tif  

echo  aspect  with file   $INDIR/$filename.tif

gdaldem aspect  -zero_for_flat -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   $INDIR/$filename.tif  $OUTDIR/aspect/tiles/${filename}_${mm}.tif

# r1 aspect , r2 slope 

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/aspect/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif" --overwrite --type=Float32


####
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif --calc="(sin(A * 3.141592 / 180 ))" --outfile   $OUTDIR/slope/tiles/${filename}_${mm}"_sin.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif --calc="(cos(A * 3.141592 / 180))" --outfile   $OUTDIR/slope/tiles/${filename}_${mm}"_cos.tif" --overwrite --type=Float32

####

gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_sin.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Ew.tif" --overwrite --type=Float32
gdal_calc.py  --NoDataValue=-9999 --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --co=INTERLEAVE=BAND --NoDataValue -9999 -A $OUTDIR/slope/tiles/${filename}_${mm}.tif -B  $OUTDIR/aspect/tiles/${filename}_${mm}"_cos.tif"  --calc="((sin(A))*B)" --outfile   $OUTDIR/aspect/tiles/${filename}_${mm}"_Nw.tif" --overwrite --type=Float32


' _ 

checkjob -v $PBS_JOBID 

rm -f /dev/shm/* 