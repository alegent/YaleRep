#  cd    /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
#  scp   giuseppea@litoria.eeb.yale.edu:/mnt/data2/scratch/Clustering_ga_mt/*.tif .

# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/median/eastness_md_GMTED2010_md.tif . 
# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/median/northness_md_GMTED2010_md.tif . 
# scp /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/median_of_md/elevation_md_GMTED2010_md.tif . 

# preparation for solar 
#  ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month??.tif


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=0:04:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/intif
pkcomposite   $( ls  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month??.tif | xargs -n 1 echo -i  ) -dstnodata -1 -srcnodata -1 -min 0 -max 20000 --crule mean   -o beam_HradCA_mean.tif


gdalbuildvrt  -overwrite -separate   beam_HradCA_stack.vrt     /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month??.tif
gdal_translate  -projwin -180 +84  +180 -56     -co  COMPRESS=LZW -co ZLEVEL=9  beam_HradCA_stack.vrt   beam_HradCA_stack.tif 




oft-calc  -ot Int16   beam_HradCA_stack.tif   beam_HradCA_stack2.tif <<EOF
1
#1 #1 *
#2 #2 *
#3 #3 *
#4 #4 *
#5 #5 *
#6 #6 *
#7 #7 *
#8 #8 *
#9 #9 *
#10 #10 *
#11 #11 *
#12 #12 *
EOF

oft-calc  -ot Int16   beam_HradCA_stack2.tif   beam_HradCA_stack2sum.tif <<EOF
12
#1 #2 + #3 + #4 + #5 + #6 + #7 + #8 + #9 + #10 + #11 + #12 +
EOF

oft-calc  -ot Int16   beam_HradCA_stack.tif   beam_HradCA_stacksum.tif <<EOF
12
#1 #2 + #3 + #4 + #5 + #6 + #7 + #8 + #9 + #10 + #11 + #12 +
EO