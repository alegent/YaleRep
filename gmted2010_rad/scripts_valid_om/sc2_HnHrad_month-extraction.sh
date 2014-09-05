
# using the shape nsrdb  extract information from the month data radiation dif


#PBS -S /bin/bash 
#PBS -q fas_normal 
#PBS -l walltime=10:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr




export INTIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation
export SHPIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/shp_in
export SHPOUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/shp_out


rm -f $SHPOUT/merge*.*

pkextract -i $INTIF/glob_Hrad_usa/glob_HradT_months.tif     -ft Integer  -lt  String -bn globHT    -s  $SHPIN/point_nsrdb.shp      -o $SHPOUT/merge1.shp 
pkextract -i $INTIF/glob_Hrad_usa/glob_HradACA_months.tif   -ft Integer  -lt  String -bn globHACA  -s  $SHPOUT/merge1.shp          -o $SHPOUT/merge2.shp 

pkextract -i $INTIF/beam_Hrad_usa/beam_HradT_months.tif     -ft Integer  -lt  String -bn beamHT    -s  $SHPOUT/merge2.shp          -o $SHPOUT/merge3.shp 
pkextract -i $INTIF/beam_Hrad_usa/beam_HradACA_months.tif   -ft Integer  -lt  String -bn beamHACA  -s  $SHPOUT/merge3.shp          -o $SHPOUT/merge4.shp 

pkextract -i $INTIF/diff_Hrad_usa/diff_HradT_months.tif     -ft Integer  -lt  String -bn diffHT    -s  $SHPOUT/merge4.shp          -o $SHPOUT/merge5.shp 
pkextract -i $INTIF/diff_Hrad_usa/diff_HradACA_months.tif   -ft Integer  -lt  String -bn diffHACA  -s  $SHPOUT/merge5.shp          -o $SHPOUT/merge6.shp 



pkextract -i $INTIF/glob_rad_usa/glob_radACA_months.tif   -ft Integer  -lt  String -bn globACA  -s  $SHPOUT/merge6.shp          -o $SHPOUT/merge7.shp 
pkextract -i $INTIF/beam_rad_usa/beam_radACA_months.tif   -ft Integer  -lt  String -bn beamACA  -s  $SHPOUT/merge7.shp         -o $SHPOUT/merge8.shp 
pkextract -i $INTIF/diff_rad_usa/diff_radACA_months.tif   -ft Integer  -lt  String -bn diffACA  -s  $SHPOUT/merge8.shp         -o $SHPOUT/merge9.shp 
pkextract -i $INTIF/refl_rad_usa/refl_radACA_months.tif   -ft Integer  -lt  String -bn reflACA  -s  $SHPOUT/merge9.shp         -o $SHPOUT/merge10.shp 


rm -f $SHPOUT/merge?.* 

