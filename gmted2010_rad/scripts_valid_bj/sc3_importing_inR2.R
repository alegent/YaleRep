
module load Applications/R/3.0.1  


# setting up the list of observation file  radiation 
library(sp)
library(foreign)  
library(rgl)
library(reshape)
library(latticeExtra)

path = "/lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb/monthstats_txt/"
files.list = list.files(path , pattern="c*.txt")

# importing the files with 
obs=c(1:12)
for(file in files.list)
{
  perpos <- which(strsplit(file, "")[[1]]==".")
  a = read.table(paste(path,file,sep=""), sep=" " , header=TRUE) 
  a$CODE = gsub(" ","",substr(file, 2, perpos-1))
  obs = rbind (obs , a   )
}

rm(a)
names(obs)[2] ="globRobs"
names(obs)[3] ="beamRobs"
names(obs)[4] ="diffRobs"
rm(files.list) ; rm (file) ; rm(perpos)

# import the radiation modelled 
radModel = read.dbf ("/lustre0/scratch/ga254/dem_bj/SOLAR/shp_out/merge12.dbf")
radModel = read.dbf ("/lustre0/scratch/ga254/dem_bj/SOLAR/shp_out/merge12_old.dbf")

d=melt(radModel,id.vars=c("X","Y","CODE"))
d$month=as.numeric(gsub("\\D", "", d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)


radiation = merge (d2 , obs , by.x = c("CODE","month") , by.y = c("CODE","MO") )
radiation = subset (radiation , globH  > 0)

# calculate residuals 

for (m in 1:12 ) {
radiation$res.beamH  = residuals(lm(subset(radiation , month == m )$beamH  ~ subset (radiation , month == m )$beamRobs))
radiation$res.beamHC = residuals(lm(subset(radiation , month == m )$beamHC ~ subset (radiation , month == m )$beamRobs))
radiation$res.globH  = residuals(lm(subset(radiation , month == m )$globH  ~ subset (radiation , month == m )$globRobs))
radiation$res.globHC = residuals(lm(subset(radiation , month == m )$globHC ~ subset (radiation , month == m )$globRobs))
}


# plotting  glob observed versus clear sky modelled , at montly level 

########## beam radiation 

png('beamH.png')
xyplot ( beamH~beamRobs |as.factor(month) , data=radiation , xlab="Observations", ylab="Model Prediction - Linke + Albedo" , xlab.top="Beam Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('beamHC.png')
xyplot ( beamHC~beamRobs |as.factor(month) , data=radiation , xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud" , xlab.top="Beam Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()








png('globH.png')
xyplot ( globH~globRobs |as.factor(month) , data=radiation ,  xlab="Observations", ylab="Model Prediction - Linke + Albedo" , xlab.top="Global Solar Radiation" ,xlim=c(0,10000) , ylim=c(0,10000)  )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('globHC.png')
xyplot ( globHC~globRobs |as.factor(month) , data=radiation , xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud" , xlab.top="Global Solar Radiation" ,xlim=c(0,10000) , ylim=c(0,10000) )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()


########
png('globHA_old.png')
xyplot ( globHA~globRobs |as.factor(month) , data=radiation , xlab="Observations", ylab="Model Prediction - Linke + Albedo + Aerosol" , xlab.top="Global Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()
##

xyplot ( beamHC~beamRobs |as.factor(month) , data=radiation , xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud" , xlab.top="Global Solar Radiation" ,xlim=c(0,10000) , ylim=c(0,10000) )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()



xyplot ( globHCA~globRobs |as.factor(month) , data=radiation ,xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud + Aerosol " , xlab.top="Global Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))



