# from bmscblog.wordpress.com/2013/01/23/error-bars-with-r 

source("helpers.R")

data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
data_mean <- aggregate(data$V2,by=list(data$V3),FUN=mean)
data_sd <- aggregate(data$V2,by=list(data$V3),FUN=sd)
data_max <- aggregate(data$V2,by=list(data$V3),FUN=max)
data_min <- aggregate(data$V2,by=list(data$V3),FUN=min)
data_count <- aggregate(data$V2,by=list(data$V3),FUN=length)

draw_jpg("daily-min-max", function() {
  plot(data_min$Group.1, data_min$x, type="l", lty=2,col="red",
       xlim=c(0,round_up(max(data$V3))), xaxt="n")
  axis(side=1)
  axis(side=2, at=c(1:9))
  lines(data_max$Group.1, data_max$x, type="l", lty=2,
        col="blue")
})
