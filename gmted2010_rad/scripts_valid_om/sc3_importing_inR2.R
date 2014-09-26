
# module load Applications/R/3.0.1  
# source ("/home/fas/sbsc/ga254/scripts/gmted2010_rad/scripts_valid_om/sc3_importing_inR2.R")

# setting up the list of observation file  radiation 
library(sp)
library(foreign)  
library(rgl)
library(reshape)
library(latticeExtra)

path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/nsrdb_month_average/"
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


# rm(a)
# names(obs)[2] ="globRobs"
# names(obs)[3] ="beamRobs"
# names(obs)[4] ="diffRobs"
# rm(files.list) ; rm (file) ; rm(perpos)

# import the radiation modelled 
radModel = read.table ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/Hrad_model4nsrdb.txt" , header=TRUE)


d=melt(radModel,id.vars=c("X","Y","IDstat"))
d$month=as.numeric(gsub("\\D", "", d$variable))
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+IDstat+month~type)


radiation.nsrdb = merge (d2 , obs , by.x = c("IDstat","month") , by.y = c("CODE","MO") )



print ("calculate residuals for the radiation.nsrdb   ")  

for (m in 1:12 ) {
radiation.nsrdb$res.beamT   = residuals(lm(subset(radiation.nsrdb , month == m )$bT_m   ~ subset (radiation.nsrdb , month == m )$AVDIF))
radiation.nsrdb$res.beamCA  = residuals(lm(subset(radiation.nsrdb , month == m )$bCA_m  ~ subset (radiation.nsrdb , month == m )$AVDIF))
radiation.nsrdb$res.diffT   = residuals(lm(subset(radiation.nsrdb , month == m )$dT_m   ~ subset (radiation.nsrdb , month == m )$AVDIR))
radiation.nsrdb$res.diffCA  = residuals(lm(subset(radiation.nsrdb , month == m )$dCA_m  ~ subset (radiation.nsrdb , month == m )$AVDIR))
}


# plotting  glob observed versus clear sky modelled , at montly level 

########## beam radiation 

png('beamTnsrdb.png')
xyplot ( bT_m~AVDIR |as.factor(month) , data=radiation.nsrdb , xlab="Observations",  pch=16 , cex=.3 , ylab="Model Prediction - Clear Sky" , xlab.top="Beam (Direct) Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('beamCAnsrdb.png')
xyplot ( bCA_m~AVDIR  |as.factor(month) , data=radiation.nsrdb , xlab="Observations", pch=16 , cex=.3 ,   ylab="Model Prediction - Cloud effect" , xlab.top="Beam (Direct) Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()



png('diffTnsrdb.png')
xyplot ( dT_m~AVDIF |as.factor(month) , data=radiation.nsrdb , xlab="Observations",  pch=16 , cex=.3 , ylab="Model Prediction - Clear Sky" , xlab.top="Diff Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('diffCAnsrdb.png')
xyplot ( dCA_m~AVDIF  |as.factor(month) , data=radiation.nsrdb , xlab="Observations",  pch=16 , cex=.3 , ylab="Model Prediction - AOD effect" , xlab.top="Diff Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()


################################################################ tmy3 ############################################################# 

path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/tmy3_txt/"
files.list = list.files(path , pattern="c*.txt")

# importing the files with 
obs=c(1:12)
for(file in files.list)
{
  perpos <- which(strsplit(file, "")[[1]]==".")
  a = read.table(paste(path,file,sep=""), sep=" " , header=FALSE  , nrows=12)
  a = within(a, rm(V5))
  a$CODE = gsub(" ","",substr(file, 2, perpos-7))
  obs = rbind (obs , a   )
}


rm(a)
names(obs)[1] ="MO"
names(obs)[2] ="global"
names(obs)[3] ="beamNorm" # not good 
names(obs)[4] ="diffHorz" # 
obs$beamHorz=obs$global-obs$diffHorz

# rm(files.list) ; rm (file) ; rm(perpos)

# import the radiation modelled 
radModel = read.table ("/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/Hrad_model4tmy3.txt" , header=TRUE)

d=melt(radModel,id.vars=c("X","Y","IDstat"))
d$month=as.numeric(gsub("\\D", "", d$variable))
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+IDstat+month~type)


radiation.tmy3 = merge (d2 , obs , by.x = c("IDstat","month") , by.y = c("CODE","MO") )



# calculate residuals 

for (m in 1:12 ) {
radiation.tmy3$res.beamT   = residuals(lm(subset(radiation.tmy3 , month == m )$bT_m   ~ subset (radiation.tmy3 , month == m )$diffHorz))
radiation.tmy3$res.beamCA  = residuals(lm(subset(radiation.tmy3 , month == m )$bCA_m  ~ subset (radiation.tmy3 , month == m )$diffHorz))
radiation.tmy3$res.diffT   = residuals(lm(subset(radiation.tmy3 , month == m )$dT_m   ~ subset (radiation.tmy3 , month == m )$beamHorz))
radiation.tmy3$res.diffCA  = residuals(lm(subset(radiation.tmy3 , month == m )$dCA_m  ~ subset (radiation.tmy3 , month == m )$beamHorz))
}


# plotting  glob observed versus clear sky modelled , at montly level 

########## beam radiation 

png('/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/beamTtmy3_new.png')
xyplot ( bT_m~beamHorz |as.factor(month) , data=radiation.tmy3 , xlab="Observations",   pch=16 , cex=.3 , ylab="Model Prediction - Clear Sky" , xlab.top="Beam (Direct) Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/beamCAtmy3_new.png')
xyplot ( bCA_m~beamHorz  |as.factor(month) , data=radiation.tmy3 , xlab="Observations",  pch=16 , cex=.3 ,   ylab="Model Prediction - Cloud effect" , xlab.top="Beam (Direct) Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/diffTtmy3_new.png')
xyplot ( dT_m~diffHorz |as.factor(month) , data=radiation.tmy3 , xlab="Observations",  pch=16 , cex=.3 , ylab="Model Prediction - Clear Sky" , xlab.top="Diffuse Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()

png('/lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/extract/diffCAtmy3_new.png')
xyplot ( dCA_m~diffHorz  |as.factor(month) , data=radiation.tmy3 , xlab="Observations",  pch=16 , cex=.3 , ylab="Model Prediction - AOD effect" , xlab.top="Diffuse Solar Radiation"   )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
dev.off()


