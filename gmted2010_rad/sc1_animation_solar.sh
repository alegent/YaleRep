# for DIR in accesibility  pop  rdensity_masked kernel lodes2 roads2   ; do qsub  -v DIR=$DIR  /lustre/home/client/fas/sbsc/ga254/scripts/URBAN_k/sc1_animation_accesibility.sh  ; done 
# bash /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_rad/sc1_animation_solar.sh 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module load Apps/R/3.0.2 


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_Hrad*_month*_km10.tif  | xargs -n 1 -P 8 bash -c $' 

# gdalwarp -srcnodata -1 -dstnodata -1 -multi -tr 0.083333333333 0.083333333333 -r cubic  -co COMPRESS=LZW  -co ZLEVEL=9  $file /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/${filename}_km10.tif 

export file=$1
export filename=$( basename $file .tif )
export DIR=$( echo $filename | awk \'{ gsub("beam_Hrad","") ; gsub("_"," ") ;  print  $1  }\'  )
export MM=$( echo $filename | awk \'{ gsub("month"," ") ; gsub("_"," ") ;  print  $3  }\'  )


R --vanilla --no-readline   -q  <<'EOF'


# source ("/home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_animationR.sh")
.libPaths( c( .libPaths(), "/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0") )

library(raster)
library(lattice , lib.loc ="/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0")
library(rasterVis)
library(foreach)

file = Sys.getenv(c("file"))
filename = Sys.getenv(c("filename"))
DIR = Sys.getenv(c("DIR"))
MM = Sys.getenv(c("MM"))

rmr=function(x){
## function to truly delete raster and temporary files associated with them
if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
file.remove(x@file@name,sub("grd","gri",x@file@name))
rm(x)
}
}


# for parallel
# you can use a foreach to do it in parallel too, if you like

# foreach(file=files.list) %dopar%{

## not sure exactly what this does, but there is basename(file) too...

png(paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/",filename,".png", sep=""),width=2000,height=900)

day001=raster(paste(file,sep=""))

day001

## be careful with this, it will recalculate the whole image into a temporary directory and not automatically delete it..
## I would suggest deleting it at the end of the loop...

if ( MM == "01" ) { month="January" }
if ( MM == "02" ) { month="February" }
if ( MM == "03" ) { month="March" }
if ( MM == "04" ) { month="April" }
if ( MM == "05" ) { month="May" }
if ( MM == "06" ) { month="June" }
if ( MM == "07" ) { month="July" }
if ( MM == "08" ) { month="August" }
if ( MM == "09" ) { month="September" }
if ( MM == "10" ) { month="October" }
if ( MM == "11" ) { month="November" }
if ( MM == "12" ) { month="December" }
 

if ( DIR  == "CA") { colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" )) ; des="Direct Solar Radiation - Real-Sky (Wh/m^2/day)"   ; min=0 ; max=12000 } 
if ( DIR  == "T")  { colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" )) ; des="Direct Solar Radiation - Clear-Sky (Wh/m^2/day)" ; min=0 ; max=12000 } 


n=100
at=seq(min,max,length=n)
cols=colR(n)
res=1e6 # res=1e4 for testing and res=1e6 for the final product
greg=list(ylim=c(-56,84),xlim=c(-180,180))

par(cex.axis=2, cex.lab=2, cex.main=2, cex.sub=2)

day001[day001>max] <- max
day001[day001<min] <- min


print ( levelplot(day001,col.regions=colR(n),  scales=list(cex=2) ,   cuts=99,at=at,colorkey=list(space="right",adj=2 , labels=list( cex=2.5)), panel=panel.levelplot.raster,   margin=T,maxpixels=res,ylab="", xlab=list(paste(des,sep="") , cex=3 , space="left" ) ,useRaster=T)  + layer(panel.text(160, 80, paste(month,sep=""),cex=2 ))   )

rmr(day001) # really  remove raster files, this will delete the temporary file
dev.off() 

EOF

' _ 


convert  -delay 50  -loop 0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month*_km10.png    /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradCA_month_km10.gif 
convert  -delay 50  -loop 0  /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradT_month*_km10.png    /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_month_merge/beam_HradT_month_km10.gif


