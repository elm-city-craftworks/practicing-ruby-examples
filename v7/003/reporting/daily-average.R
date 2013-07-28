# from bmscblog.wordpress.com/2013/01/23/error-bars-with-r 

source("helpers.R")

#separate days with fewer than 5 points
errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}

data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
data_mean <- aggregate(data$V2,by=list(data$V3),FUN=mean)
data_sd <- aggregate(data$V2,by=list(data$V3),FUN=sd)
data_max <- aggregate(data$V2,by=list(data$V3),FUN=max)
data_min <- aggregate(data$V2,by=list(data$V3),FUN=min)
data_count <- aggregate(data$V2,by=list(data$V3),FUN=length)

draw_jpg("daily-average", function() {
  plot(data_mean$Group.1,data_mean$x,type="o",ylim =c(0,10),col ="red")
  errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col="gray");
})
