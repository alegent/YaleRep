# calculate geomorfology parameter http://grass.osgeo.org/grass70/manuals/addons/r.geomorphon.html &  http://grass.osgeo.org/grass64/manuals/r.param.scale.html 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*

# for file in $(ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/India/indiaLST_MYD_day209_wgs84.tif  ) ; do qsub  -v file=$file /lustre/home/client/fas/sbsc/ga254/scripts/LST/sc10_multir_grass.sh   ; done 
# for file in `ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/India/indiaLST_MYD_day209_wgs84.tif` ; do bash /lustre/home/client/fas/sbsc/ga254/scripts/LST/sc10_multir_grass.sh  $file   ; done 



#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

file=$1   
# export file=$file

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/India
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/India
export RAM=/dev/shm


export filename=$(basename $file .tif)

checkjob -v $PBS_JOBID  

rm -fr /dev/shm/*


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/LST/India 

rm -r  /dev/shm/loc_$filename

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh   /dev/shm loc_$filename  $file

r.mapcalc  " mask = if(  $(basename $file .tif ) > 0 , 1 , 0 ) " 

r.mask  raster=mask  maskcats=0  --o 

for q in $(seq 1 12) ; do                                                                                                                                                                                          
r.in.gdal in=india_cons_${q}.tif out=india_cons_${q}
done                                                                                                                                                                                                               


for dem   in india_eastness_md_GMTED2010_md.tif  india_northness_md_GMTED2010_md.tif  india_elevation_md_GMTED2010_md.tif  ; do                                                                                                      
r.in.gdal in=$dem  out=$(basename $dem .tif ) 
done                                                                                                                                                                                                               

g.list rast 


/home/fas/sbsc/ga254/.grass7/addons/bin/r.regression.multi mapx=india_cons_1,india_cons_2,india_cons_3,india_cons_4,india_cons_5,india_cons_6,india_cons_7,india_cons_8,india_cons_9,india_cons_10,india_cons_11,india_cons_12,india_eastness_md_GMTED2010_md,india_northness_md_GMTED2010_md,india_elevation_md_GMTED2010_md mapy=$(basename $file .tif)   residuals=res_$(basename $file .tif) estimates=est_$(basename $file .tif) output=regres_coef_$(basename $file .tif).txt

r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff     input=res_$(basename $file .tif)         output=$OUTDIR/res_$(basename $file)
r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff     input=est_$(basename $file .tif)         output=$OUTDIR/est_$(basename $file)

checkjob -v $PBS_JOBID  

exit 
