# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc41_plotVariableGMTED_levelplot.R.sh" ) 

# rm(list = ls())

# AREA = "alps"

# require(raster)
# require(rgdal)
# require(rasterVis)
# require(gridExtra)

# GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"

# e=extent( 8.80, 9.80, 46.57, 47.20)

# for ( file in c("tpi","tri","vrm","roughness","slope","aspect-cosine","aspect-sine","eastness","northness" ,"elevation","dx","dxx","dy","dyy","pcurv","tcurv")) {
#          file
#  	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_md_GMTED2010_md_km1.tif")) 
#          raster[raster == -9999 ] <- NA
#          raster = crop (raster , e)
#  	assign(paste0(file,"_GMTED") , raster  )
#  }

# elevation_psd_GMTED = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_psd_GMTED2010_sd_km1.tif")
# elevation_psd_GMTED = crop (elevation_psd_GMTED , e)
# elevation_sd_GMTED  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_sd_GMTED2010_md_km1.tif")
# elevation_sd_GMTED  = crop (elevation_sd_GMTED , e)

# for ( file in c("geomorphic_uni","geomorphic_count","geomorphic_ent","geomorphic_majority","geomorphic_shannon","geomorphic_class3")) {
# 	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_GMTED2010_md_km1.tif"))
#         raster = crop (raster , e)
# 	assign(paste0(file,"_GMTED") , raster  )
# }

# rm(raster, GMTED , file  , AREA )

# aspectcosine_GMTED = get(paste0("aspect-cosine_GMTED"))
# aspectsine_GMTED   = get(paste0("aspect-sine_GMTED"))

# stack = stack(elevation_GMTED,elevation_sd_GMTED,elevation_psd_GMTED,tpi_GMTED,tri_GMTED,vrm_GMTED,roughness_GMTED,slope_GMTED,aspectcosine_GMTED,aspectsine_GMTED,eastness_GMTED,northness_GMTED,pcurv_GMTED,tcurv_GMTED,dx_GMTED,dxx_GMTED,dy_GMTED,dyy_GMTED,geomorphic_majority_GMTED,geomorphic_class3_GMTED, geomorphic_count_GMTED,geomorphic_shannon_GMTED,geomorphic_uni_GMTED,geomorphic_ent_GMTED)

# n=100
# colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
# cols=colR(n)

# options(scipen=10)
# trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

# plot=rasterVis::levelplot(get(file), main=list(label=des, cex=0.4 , font.main = 1 , lineheight.main=-1 ) ,   col.regions=colR(n), margin=F, scales=list(draw=TRUE , x=list(tick.number=4 , alternating=0 , tck=0.2) ,  y=list(tick.number=6 , alternating=0 , tck=0.2)  ),   colorkey=list( lwd=0.01 ,  space="right", labels=list( cex=0.3 ,  at=seq (min,max, ((max-min)/3))  , lab=trunc(seq (min,max, ((max-min)/3)) , prec=4) ) , width=0.5  , size=3 ,  cex=0.3  ),  panel=panel.levelplot.raster, maxpixels=res,ylab="", xlab="",  par.settings=list(layout.heights=list(top.padding=-1, bottom.padding=-1), layout.widths=list(left.padding=.5 , right.padding=.5)))

# assign(paste("plot_",file,sep="") , plot ) 

# grid.arrange( plot_elevation_GMTED,plot_elevation_sd_GMTED,plot_elevation_psd_GMTED,plot_tpi_GMTED,plot_tri_GMTED,plot_vrm_GMTED,plot_roughness_GMTED,plot_slope_GMTED,plot_aspectcosine_GMTED,plot_aspectsine_GMTED,plot_eastness_GMTED,plot_northness_GMTED,plot_pcurv_GMTED,plot_tcurv_GMTED,plot_dx_GMTED,plot_dxx_GMTED,plot_dy_GMTED,plot_dyy_GMTED,plot_geomorphic_majority_GMTED,plot_geomorphic_class1_GMTED,plot_geomorphic_count_GMTED,plot_geomorphic_shannon_GMTED,plot_geomorphic_uni_GMTED,plot_geomorphic_ent_GMTED , ncol=4 ) 

# dev.off()

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps") ,  paper="special" ,  horizo=F , width=6, height=7.5   )
par (oma=c(2,2,2,1) , mar=c(0.4,0.5,1,2) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,   mfrow=c(6,4) ,  xpd=NA    )

for ( file in c("elevation_GMTED","elevation_sd_GMTED","elevation_psd_GMTED","tpi_GMTED","tri_GMTED","vrm_GMTED","roughness_GMTED","slope_GMTED","aspectcosine_GMTED","aspectsine_GMTED","eastness_GMTED","northness_GMTED","pcurv_GMTED","tcurv_GMTED","dx_GMTED","dxx_GMTED","dy_GMTED","dyy_GMTED","geomorphic_majority_GMTED","geomorphic_class3_GMTED","geomorphic_count_GMTED","geomorphic_shannon_GMTED","geomorphic_uni_GMTED","geomorphic_ent_GMTED") )  { 

raster=get(file)

if(file == "elevation_GMTED" )    {  des="Elevation Median" ; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "elevation_sd_GMTED" ) {  des="Elevation St. Dev." ; max=300  ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "elevation_psd_GMTED") {  des="Elevation Pooled St. Dev."; max=100 ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "tpi_GMTED" )          {  des="Topographic Position Index" ; max=25 ; min=-25 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }

if(file == "tri_GMTED" )          {  des="Terrain Roughness Index"; max=150 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "vrm_GMTED" )          {  des="Vector Ruggedness Measure" ; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( 0  : 1 ) ; labels=pretty( 0  : 1 ) }
if(file == "roughness_GMTED" )    {  des="Roughness"; max=600 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "slope_GMTED" )        {  des="Slope"; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }

if(file == "aspectcosine_GMTED" ) {  des="Aspect Cosine" ; max=1 ; min=-1 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "aspectsine_GMTED" )   {  des="Aspect Sine" ; max=1 ; min=-1  ; at=pretty( min  : max ) ; labels=pretty( min  : max ) }
if(file == "eastness_GMTED" )     {  des="Eastness"  ; max=+0.6  ; min=-0.6   ; at=c(-0.6,-0.3,0,0.3, 0.6  ) ; labels=c(-0.6,-0.3,0,0.3, 0.6  ) }
if(file == "northness_GMTED" )    {  des="Northness" ; max=+0.6  ; min=-0.6  ; at=c(-0.6,-0.3,0,0.3, 0.6  ) ; labels=c(-0.6,-0.3,0,0.3, 0.6  ) }

if(file == "pcurv_GMTED" )        {  des="Profile curvature" ; max=0.0005  ; min=-0.0005 ;    at=seq (min , max  , 0.00025) ; labels=seq (min , max , 0.00025) }
if(file == "tcurv_GMTED" )        {  des="Tangential curvature" ;  max=0.0005  ; min=-0.0005 ;    at=seq (min , max  , 0.00025) ; labels=seq (min , max , 0.00025) }
if(file == "dx_GMTED" )           {  des="1st partial derivative (E-W slope)" ; max=0.8 ; min=-0.8 ;  at=seq (min , max  , 0.4) ; labels=seq (min , max , 0.4) }
if(file == "dxx_GMTED" )          {  des="2nd partial derivative (E-W slope)" ; max=0.001  ; min=-0.001 ;  at=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; labels=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) }

if(file == "dy_GMTED" )   {  des="1st partial derivative (N-S slope)" ;  max=0.8  ; min=-0.8     ; at=seq (min , max  , 0.4) ; labels=seq (min , max , 0.4) }
if(file == "dyy_GMTED" )  {  des="2nd partial derivative (N-S slope)" ;  max=0.001  ; min=-0.001 ;  at=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; labels=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) }
if(file == "geomorphic_majority_GMTED" ){  des="Geomorphic classes majority"; max=10 ; min=get(file)@data@min ; at=seq (1 , 10  , 1) ;  labels=c("flat","summit","ridge","shoulder","spur","slope","hollow","footslope","valley","depression") }
if(file == "geomorphic_class3_GMTED" )  {  des="Geomorphic ridge percentage" ; raster=raster/100  ;   max=100 ; min=raster@data@min ; at=seq (min , max  , 25 ) ; labels=seq (min , max , 25 ) }

if(file == "geomorphic_count_GMTED" )   {  des="Geomorphic classes count" ; max=10 ; min=1 ; at=seq (min , max  , 2 ) ; labels=seq (min , max , 2 ) }
if(file == "geomorphic_shannon_GMTED" ) {  des="Geomorphic classes shannon";  max=1.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )    }
if(file == "geomorphic_uni_GMTED" )     {  des="Geomorphic classes uniformity" ; max=1 ; min=0 ;  at=seq (min , max  , 0.2 ) ; labels=seq (min , max , 0.2 )    }
if(file == "geomorphic_ent_GMTED" )     {  des="Geomorphic classes entropy"  ; max=2.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )    } 



raster[raster  > max] <-  max
raster[raster  < min] <-  min


if (( file != "geomorphic_count_GMTED" ) &&  ( file != "geomorphic_majority_GMTED" ))  { 
plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.6 , font.main=1 )
plot(raster, axis.args=list(  at=at , labels=labels  , line=-0.68, tck=0  ), smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols)
}

if ( file == "geomorphic_majority_GMTED" ) { 
plot(raster   , col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10) , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.6 , font.main=1 )
plot(raster, axis.args=list(at=at ,  labels=labels   , line=-0.68, tck=0  ), smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10)  )
}

if ( file == "geomorphic_count_GMTED"  )   { 
plot(raster , col=cols , yaxp=c(46.6 , 47.2 , 4 ) , xaxp=c(8.8 , 9.8 , 4 ) ,  main=des   , legend=FALSE   , cex.main=0.6 , font.main=1   )
plot(raster , axis.args=list( at=at  , labels=labels  , line=-0.68, tck=0  ) , smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols , nlevel=4 )
}
} 

dev.off()



# system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps")



# system("ps2pdf /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.pdf")
# system("convert -flatten -density 300 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.png")
# system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var.eps")

