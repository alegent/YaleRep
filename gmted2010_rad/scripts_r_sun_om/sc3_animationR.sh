# module load Apps/R/3.0.2 
# source ("/home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_animationR.sh")
# .libPaths( c( .libPaths(), "/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0") )

library(raster)
library(lattice , lib.loc ='/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0')
library(rasterVis)
library(foreach)

 #  gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  -ot Int32  -a_nodata -9999   integration001.tif    integration001a.tif

rmr=function(x){
## function to truly delete raster and temporary files associated with them
if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
file.remove(x@file@name,sub("grd","gri",x@file@name))
rm(x)
}
}


path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_day_merge/"

# for parallel
# you can use a foreach to do it in parallel too, if you like


# foreach(file=files.list) %dopar%{

for(day  in c(1:2) ) {
 
basename=paste("beam_HradT_day",day,sep="")
## not sure exactly what this does, but there is basename(file) too...

png(paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/radiation/beam_Hrad_day_merge_png/",basename,".png",sep=""),width=2000,height=1000)

## add width and height to specify the size of the png, otherwise it will be small (100x100, I think)

print("importing") 

day001=raster(paste(path,"beam_HradT_day",day,".tif",sep=""))

# refl001=1-(2.718281828 ^ ( 0 - (day001/1000  ) ))
## be careful with this, it will recalculate the whole image into a temporary directory and not automatically delete it..
## I would suggest deleting it at the end of the loop...
 
n=100
at=seq(0,1,length=n)
colR=colorRampPalette(c("yellow", "red", "brown"))
 
cols=colR(n)
res=1e2 # res=1e4 for testing and res=1e6 for the final product
greg=list(ylim=c(-90,90),xlim=c(-180,180))
 
print (  levelplot(day001,col.regions=colR(n) , cuts=99,at=at,colorkey=list(space="right",adj=1), panel=panel.levelplot.raster,margin=F,maxpixels=res,ylab="",xlab="",useRaster=T,ylim=greg$ylim) + layer(panel.text(160, 85, paste('Julian day ',day,sep=""),cex=2 ))  )

rmr(day001) # really  remove raster files, this will delete the temporary file
 
dev.off() 
 
}

# move the data to litoria /home/giuseppea/tmp/animation_MERRAero  and run ffmepg 
#  ffmpeg -r 25  -i mean%03d.png    -vcodec libx264  -pix_fmt yuv420p -r 25 animation_MERRAero.mp4



# ls integration???.tif | xargs -n 1 -P 20 bash -c $' 

# export file=$1

# R  --vanilla --no-readline   -q  <<EOF

# library(raster)
# library(lattice , lib.loc ="/home2/ga254/R/x86_64-unknown-linux-gnu-library/3.0")
# library(rasterVis)
# library(foreach)

# rmr=function(x){
# ## function to truly delete raster and temporary files associated with them
# if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
# file.remove(x@file@name,sub("grd","gri",x@file@name))
# rm(x)
# }
# }

# file = Sys.getenv(c("file"))
# print(file)

# basename=substr(file,0,14)
# print(basename)

# day=substr (basename,12,14)
 
# png(paste("/lustre0/scratch/ga254/dem_bj/AE_C51_C6_L2/integration_15/png/",basename , ".png" ,sep=""),width=2000,height=1000)
# ## add width and height to specify the size of the png, otherwise it will be small (100x100, I think)
 
# day001=raster(paste("/lustre0/scratch/ga254/dem_bj/AE_C51_C6_L2/integration_15/tif/",file,sep=""))
 
# refl001=1-(2.718281828 ^ ( 0 - (day001 * 0.001 ) ))
# ## be careful with this, it will recalculate the whole image into a temporary directory and not automatically delete it..
# ## I would suggest deleting it at the end of the loop...
 
# n=100
# at=seq(0,1,length=n)
# colR=colorRampPalette(c("yellow", "red", "brown"))
 
# cols=colR(n)
# res=1e6 # res=1e4 for testing and res=1e6 for the final product
# greg=list(ylim=c(-90,90),xlim=c(-180,180))
 
# print (  levelplot(refl001,col.regions=colR(n) , cuts=99,at=at,colorkey=list(space="right",adj=1), panel=panel.levelplot.raster,margin=F,maxpixels=res,ylab="",xlab="",useRaster=T,ylim=greg\$ylim) + layer(panel.text(160, 85, paste("Julian day ",day,sep=""),cex=3 ))  )

# rmr(refl001) # really  remove raster files, this will delete the temporary file
 
# dev.off()

# EOF

# ' _




