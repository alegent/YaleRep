# qsub /home/fas/sbsc/ga254/scripts/NHD/sc1_wget.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/NHD/HighResolution
# wget  ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/Hydrography/NHD/National/HighResolution/GDB/National_NHD.zip


wget -c ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/Hydrography/NHD/National/HighResolution/GDB/National_NHD_20161117.zip 

# wget ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/Hydrography/NHD/National/HighResolution/GDB/NHDPointEvents_pgdb.zip

# wget ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/Hydrography/NHD/National/HighResolution/GDB/NHDPointEvents_fgdb.gdb.zip


