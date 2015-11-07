module unload Apps/R/3.2.2-generic
module load Apps/R/3.0.2-generic

#Classify on environmental features (columns) of spatial units (rows) of data object

#Provides "optimal" clustering solution via gap statistic (cluster::clusGap; see ?clusGap and Tibshirani et al. 2001)

#   and cluster stability information (fpc::clusterboot; consistency of class identities across subsampled replicated clustering)

#Map/visual comparison against (faster) pam/pamk/clara shows hclust/agnes generate qualitatively better map output and are inherently more sensibly nested



if (!require("cluster")) {  install.packages("cluster", dependencies = TRUE);  library(cluster) }

#note fpc may fail on "robustbase" dependency, requiring local install via, e.g., https://urldefense.proofpoint.com/v2/url?u=http-3A__cran.r-2Dproject.org_bin_macosx_mavericks_contrib_3.1_robustbase-5F0.92-2D1.tgz&d=AwIGAg&c=-dg2m7zWuuDZ0MUcV7Sdqw&r=MXazMdKSnmM5Mf9FIedcjvkS-lLqGXZJ4pWDg01pvls&m=22ZP5syqtY4bAusPBiU7ijMIcRxi8oymPkWhoKgGFko&s=y3CwdAhD-KH9OIvU2GcrGXfcaelW4IPO2hzoogFTv9k&e= 

if (!require("fpc")) {  install.packages("fpc", dependencies = TRUE) ; library(fpc)}

if (!require("fastcluster")) {  install.packages("fastcluster", dependencies = TRUE) ; library(fastcluster)}



streamCluster = function (

  scef,  #(s)tream (c)umulative (e)nvi (f)eatures dataframe (or @data of SpatialDataFrame) object with rows=cells, cols=aggregated/weighted environmental variables

  feat = colnames(scef), # to allow subsets of environmental features if desired

  maxClasses = 5, #default set low

  randSeed = 9797, #should not matter much

  gapBoots = 100 #the underlying function default

) 

{  

  set.seed(randSeed)

  scef.scale = scale(scef[,feat]) #scale values (default: subtract mean and divide by sd) before calc euclidean distances (nrow by nrow matrix)

  hc = hclust(dist(scef.scale, method="euclidean"), method="ward.D2") #the basic hierarchical solution

  #clusGap requires that hierarchical methods have a wrapper w/cuttree 

  #   note output is equivalent to cluster::agnes given equivalent settings, i.e., 'ward'=='ward.D2'

  #   but fastcluster masks the hclust name for speedup

  hcl_wrap = function(x, k) list(cluster = cutree(hclust(dist(x, method="euclidean"), method = "ward.D2"), k=k))

  cg = clusGap(x=scef.scale, FUNcluster=hcl_wrap, K.max=maxClasses, B=gapBoots)

  #Using default firstSEmax rule on gap, generate cluster stability

  cb = clusterboot(data=scef.scale, B=100, seed=randSeed, bootmethod="boot", multipleboot=FALSE,

                   clustermethod=hclustCBI, method="ward.D2", 

                   scaling=F, k=maxSE(cg$Tab[,"gap"], cg$Tab[,"SE.sim"]))

  return(list(hc=hc, cg=cg, cb=cb))

} #end function



toy = rbind(iris, iris, iris, iris)

toy.clus <- streamCluster(scef = toy, feat=c("Sepal.Length", "Sepal.Width"), maxClasses = 10)



#~5.8 sec on my machine



#a few plots

if (!require("mclust")) {  install.packages("mclust", dependencies = TRUE) ; library(mclust)}

clPairs(toy[,1:2], toy.clus$cb$partition)

plot(toy.clus$cg, bty="l", las=1, xlab="Number of classes")

points(maxSE(toy.clus$cg$Tab[,"gap"], toy.clus$cg$Tab[,"SE.sim"]), toy.clus$cg$Tab[maxSE(toy.clus$cg$Tab[,"gap"], toy.clus$cg$Tab[,"SE.sim"]), "gap"], pch=8, col=2, cex=1.2)

