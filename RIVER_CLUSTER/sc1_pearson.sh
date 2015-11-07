# qsub /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc10_varCorrelation.sh

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr



export TEMPDIR=/lustre/scratch/client/fas/sbsc/sd566/global_wsheds/global_results_merged/filled_str_ord_maximum_max50x_lakes_manual_correction

ls $TEMPDIR/bioclim/avg/*.tif $TEMPDIR/elevation/dem_range.tif $TEMPDIR/landuse/wavg/*.tif $TEMPDIR/slope/slope_range.tif $TEMPDIR/soil/wavg/*.tif $TEMPDIR/stream_topo/lentic_lotic01.tif $TEMPDIR/stream_topo/bifurcation_ratio.tif  $TEMPDIR/stream_topo/stream_order_lakes0.tif $TEMPDIR/stream_topo/upcells_land.tif   $TEMPDIR/stream_topo/upcells_stream.tif    | xargs -n 1 -P 8  bash -c $' echo $(basename $1) $( gdalinfo -mm  $1  | grep Computed  )   ' _  >  /lustre/scratch/client/fas/sbsc/ga254/dataproces/RIVER_CLUSTER/min_max.txt


exit 


oft-calc -ot Byte  $INSENS/LST_${SENS}_QC_day${DAY}_wgs84.tif  $OUTSENS/LST_${SENS}_QC_day${DAY}_wgs84_allobsBolean.tif <<EOF
EOF
1
#1 1 > 0 1 ?
EOF



EOF

exit 




ls ~/GMTED2010_bk/*_md_*   ~/GMTED2010_bk/geomorphic* ~/GMTED2010_bk/*sd*   ~/GMTED2010_bk/*range*   | xargs -n 1 -P 8 bash -c $' 
DIR=~/GMTED2010_bk
file1=$( basename $1  )
filename1=$( basename $file1 .tif )

pksetmask -co  COMPRESS=LZW -co ZLEVEL=9 -msknodata 0   -nodata 32767  -m /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/mask/maskLST_4GMTED.tif -i $DIR/$file1 -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/msktif/$filename1.tif 

' _ 

ls ~/GMTED2010_bk/*_md_*   ~/GMTED2010_bk/geomorphic* ~/GMTED2010_bk/*sd*  ~/GMTED2010_bk/*range*  | xargs -n 1 -P 4 bash -c $' 

RAM=/dev/shm
DIR=~/GMTED2010_bk

export filename1=$(basename $1 )
MSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/msktif

rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/$filename.txt

for file2 in $( ls ~/GMTED2010_bk/*_md_*   ~/GMTED2010_bk/geomorphic* ~/GMTED2010_bk/*sd*  ) ; do 

filename2=$(basename $file2  )
echo correlation for $filename1  $filename2
echo $filename1 $filename2 $( pkstat -nodata 32767  -reg -i $MSK/$filename1 -i $MSK/$filename2) >> /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/$filename1.txt
done 

' _ 

exit 


