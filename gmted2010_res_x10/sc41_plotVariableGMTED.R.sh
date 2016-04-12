
# qsub 

# qsub -X  -I -q fas_devel -l walltime=4:00:00  
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc41_plotVariableGMTED.R.sh") 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:4:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

# andes orizontal 

# alps vertical 
# borneo vertical 
# alps2 vertical 

# echo  andes alps borneo alps2    | xargs -n 1 -P 3 bash -c $'

# export AREA=$1

# R --vanilla --no-readline   -q  <<\'EOF\' 

# AREA = Sys.getenv(c(\'AREA\'))

rm(list = ls())

AREA = "alps"

require(raster)
require(rgdal)
require(rasterVis)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"


e=extent( 8.80, 9.80, 46.60, 47.20)  # xmn=7.30, xmx=8, ymn=45, ymx=45.70 

for ( file in c("tpi","tri","vrm","roughness","slope","aspect-cosine","aspect-sine","eastness","northness" ,"elevation","dx","dxx","dy","dyy","pcurv","tcurv")) {
        file
	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_md_GMTED2010_md_km1.tif")) 
        raster[raster == -9999 ] <- NA
        raster = crop (raster , e)
	assign(paste0(file,"_GMTED") , raster  )
}

elevation_psd_GMTED = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_psd_GMTED2010_sd_km1.tif")
elevation_psd_GMTED = crop (elevation_psd_GMTED , e)

elevation_sd_GMTED  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_sd_GMTED2010_md_km1.tif")
elevation_sd_GMTED = crop (elevation_sd_GMTED , e)

for ( file in c("geomorphic_uni","geomorphic_count","geomorphic_ent","geomorphic_majority","geomorphic_shannon","geomorphic_class1")) {
	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_GMTED2010_md_km1.tif"))
        raster = crop (raster , e)
	assign(paste0(file,"_GMTED") , raster  )
}

rm(raster, GMTED , file  , AREA )

aspectcosine_GMTED = get(paste0("aspect-cosine_GMTED"))
aspectsine_GMTED   = get(paste0("aspect-sine_GMTED"))

# stack = stack(elevation_GMTED, elevation_sd_GMTED , elevation_psd_GMTED ,tpi_GMTED,tri_GMTED,vrm_GMTED,roughness_GMTED,slope_GMTED,aspectcosine_GMTED,aspectsine_GMTED,eastness_GMTED,northness_GMTED,pcurv_GMTED,tcurv_GMTED,dx_GMTED,dxx_GMTED,dy_GMTED,dyy_GMTED,geomorphic_majority_GMTED,geomorphic_class1_GMTED, geomorphic_count_GMTED,geomorphic_shannon_GMTED,geomorphic_uni_GMTED,geomorphic_ent_GMTED)

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps") ,  paper="special" ,  horizo=F , width=6, height=7  )

par (oma=c(2,1,2,1) , mar=c(1,2,1,2) , cex.lab=0.5 , cex=0.6 , cex.axis=0.5  ,   mfrow=c(6,4) ,  xpd=NA )

par.norast = print(par()) 

plot(elevation_GMTED           , col=cols, xaxt="n" , xlab=""            , ylab="" , main="Elevation Median"                            , cex.main=0.6 , font.main=1 )
plot(elevation_sd_GMTED        , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Elevation Standard Deviation"                , cex.main=0.6 , font.main=1 )
plot(elevation_psd_GMTED       , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Elevation Pooled Standard Deviation"         , cex.main=0.6 , font.main=1 )
plot(tpi_GMTED                 , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Topographic Position Index"                  , cex.main=0.6 , font.main=1 ) 

plot(tri_GMTED                 , col=cols, xaxt="n" , xlab=""            , ylab="" , main="Terrain Roughness Index"                     , cex.main=0.6 , font.main=1 )
plot(vrm_GMTED                 , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Vector Ruggedness Measure"                   , cex.main=0.6 , font.main=1 )
plot(roughness_GMTED           , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Roughness"                                   , cex.main=0.6 , font.main=1 )
plot(slope_GMTED               , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Slope"                                       , cex.main=0.6 , font.main=1 ) 

plot(aspectcosine_GMTED        , col=cols, xaxt="n" , xlab=""            , ylab="" , main="Aspect Cosine"                               , cex.main=0.6 , font.main=1 )
plot(aspectsine_GMTED          , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Aspect Sine"                                 , cex.main=0.6 , font.main=1 )
plot(eastness_GMTED            , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Eastness"                                    , cex.main=0.6 , font.main=1 )
plot(northness_GMTED           , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Northness"                                   , cex.main=0.6 , font.main=1 ) 

plot(pcurv_GMTED               , col=cols, xaxt="n" , xlab=""            , ylab="" , main="Profile curvature"                           , cex.main=0.6 , font.main=1 )
plot(tcurv_GMTED               , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Tangential curvature"                        , cex.main=0.6 , font.main=1 )
plot(dx_GMTED                  , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="First order partial derivative (E-W slope )" , cex.main=0.6 , font.main=1 )
plot(dxx_GMTED                 , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Second order partial derivative (E-W slope)" , cex.main=0.6 , font.main=1 ) 

plot(dy_GMTED                  , col=cols, xaxt="n" , xlab=""            , ylab="" , main="First order partial derivative (N-S slope)"  , cex.main=0.6 , font.main=1 )
par.dif = print(par()) 
plot(dyy_GMTED                 , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Second order partial derivative (N-S slope)" , cex.main=0.6 , font.main=1 )
plot(geomorphic_majority_GMTED , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Geomorphic classes majority"                 , cex.main=0.6 , font.main=1 )
plot(geomorphic_class1_GMTED   , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Geomorphic classes 1 percent"                , cex.main=0.6 , font.main=1 ) 

# plot(geomorphic_count_GMTED    , col=cols,          , xlab=""            , ylab="" , main="Geomorphic classes count"                    , cex.main=0.6 , font.main=1 )

plot(geomorphic_count_GMTED    , col=cols,          , xlab=""            , ylab="" , main="Geomorphic classes count"                    , cex.main=0.6 , font.main=1 ,  yaxt="n" ,  xaxt="n" , mar=c(2,2,2,1) ,  xpd=TRUE  )
par(xpd=NA)
axis(side = 1,  at = c(e@xmin , e@xmin + 0.2 , e@xmin + 0.4 )  , lab=c(e@xmin , e@xmin + 0.2 , e@xmin + 0.4 )   ,  tck = -0.1 , xpd=NA )
axis(side = 2,  at = c(e@ymin , e@ymin + 0.2 , e@ymin + 0.4 )  , lab=c(e@ymin , e@ymin + 0.2 , e@xmin + 0.4 )   ,  tck = -1 , xpd=NA)

plot(geomorphic_shannon_GMTED  , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Geomorphic classes shannon"                  , cex.main=0.6 , font.main=1 )
plot(geomorphic_uni_GMTED      , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Geomorphic classes uniformity"               , cex.main=0.6 , font.main=1 )
plot(geomorphic_ent_GMTED      , col=cols, xaxt="n" , xlab="" , yaxt="n" , ylab="" , main="Geomorphic classes entropy"                  , cex.main=0.6 , font.main=1 ) 

dev.off() 

# system("ps2pdf  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.pdf")
# system("convert -flatten -density 300  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.png")
# system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.eps")

system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps")



raster=raster(matrix(runif(100)))

plot(raster ,  xlab="" , ylab=""   , cex.main=0.6 , font.main=1 ,  yaxt="n" ,  xaxt="n" , mar=c(2,2,2,1) ,  xpd=TRUE  )
axis(side = 1,  at = c(0.2,0.4 )  , lab=c(0.2,0.4)   ,  tck = -0.1 , xpd=NA )
