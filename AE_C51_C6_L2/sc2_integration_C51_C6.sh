# for DAYc  in `cat /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt` ; do bash /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_C6_L2/sc2_integration_C51_C6.sh  $DAYc  15 ; done 
# for DAYc  in `cat /lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/day_list.txt` ; do  qsub -v DAYc=$DAYc,WIND=15  /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/AE_C51_C6_L2/sc2_integration_C51_C6.sh   ; done 


#PBS -S /bin/bash
#PBS -q fas_normal
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout
#PBS -e /lustre0/scratch/ga254/stderr

# DAYc=$1
# WIND=$2

INDIRC51=/lustre0/scratch/ga254/dem_bj/AE_C51_MOD04_L2_MYD04_L2/mean_${WIND}/tif
INDIRC6=/lustre0/scratch/ga254/dem_bj/AE_C6_MYD04_L2/mean_${WIND}_C6/tif
OUTDIR=/lustre0/scratch/ga254/dem_bj/AE_C51_C6_L2/integration_${WIND}/tif
DAYc=$DAYc
WIND=$WIND

echo merge the two dataset AE_C51_MOD04_L2_MYD04_L2 and AE_C6_MYD04_L2 



gdalbuildvrt  -separate    -overwrite $OUTDIR/output$DAYc.vrt  $INDIRC51/AOD_550_mean_day$DAYc.tif $INDIRC6/AOD_550_Dark_Target_Deep_Blue_day$DAYc.tif
gdal_translate $OUTDIR/output$DAYc.vrt  $OUTDIR/output$DAYc.tif 

oft-calc -inv  $OUTDIR/output$DAYc.tif   $OUTDIR/integration$DAYc.tif  <<EOF 
1
#2 -51 > #2 #1 ?
EOF

pkgetmask  -min -51  --max 5001 -data 1 -nodata 0  -i   $OUTDIR/integration$DAYc.tif    -o    $OUTDIR/integration${DAYc}_mask.tif
pkfillnodata  -m   $OUTDIR/integration${DAYc}_mask.tif   -d 1 -it 1   -i   $OUTDIR/integration${DAYc}.tif   -o   $OUTDIR/integration${DAYc}_fill.tif  
gdalwarp -srcnodata -9999   -dstnodata -9999 -overwrite  -r cubicspline -tr 0.0083333333333333  0.0083333333333333  -co COMPRESS=LZW -co ZLEVEL=9  $OUTDIR/integration${DAYc}_fill.tif $OUTDIR/integration${DAYc}_1km.tif
rm  $OUTDIR/integration${DAYc}_mask.tif $OUTDIR/output$DAYc.tif $OUTDIR/output$DAYc.vrt   $OUTDIR/integration${DAYc}_fill.tif  


# for 



pkgetmask  -min -1  --max 5001 -data 1 -nodata 0  -i   $OUTDIR/integration$DAYc.tif    -o    $OUTDIR/integration${DAYc}_mask.tif    


oft-calc  -ot Float32  -um $OUTDIR/integration${DAYc}_mask.tif   $OUTDIR/integration${DAYc}_fill.tif   $OUTDIR/integration${DAYc}_div.tif      <<EOF
1
#1 1000 /  
EOF



oft-calc -inv  -ot Float32  -um $OUTDIR/integration${DAYc}_mask.tif   $OUTDIR/integration${DAYc}_div.tif   $OUTDIR/integration${DAYc}_refl.tif      <<EOF
1
#1 2.718281828   
EOF









