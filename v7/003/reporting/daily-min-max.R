# from bmscblog.wordpress.com/2013/01/23/error-bars-with-r 

source("helpers.R")

data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
data_max <- aggregate(data$V2,by=list(data$V3),FUN=max)
data_min <- aggregate(data$V2,by=list(data$V3),FUN=min)

draw_jpg("daily-min-max", function() {
  plot(data_min$Group.1, data_min$x, type="l",col="coral1",
       xlim=c(0,round_up(max(data$V3))), xaxt="n",
       main="Minimum and maximum mood ratings by day",
       ylab="Mood rating", xlab="Number of days since start of study",
       cex.main=2, cex.lab=1.5, lwd=2, yaxt="n")
  axis(side=1, cex.axis=1.5)
  axis(side=2, at=c(1:9), cex.axis=1.5)
  lines(data_max$Group.1, data_max$x, type="l", lwd=2,
        col="darkgreen")
})
