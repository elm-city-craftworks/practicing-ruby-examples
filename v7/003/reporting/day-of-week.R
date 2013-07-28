source("helpers.R")

data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
names(data)[1]<-"sec"
names(data)[2]<-"rating"
names(data)[3]<-"day"
names(data)[4]<-"hour"
names(data)[5]<-"weekdayname"
names(data)[6]<-"weekdaynum"

week <- c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")

data_day_mean <- aggregate(data$rating, by=list(data$weekdaynum),FUN=mean)
data_day_sd <- aggregate(data$rating, by=list(data$weekdaynum),FUN=sd)

draw_jpg("day-of-week-summary", function() {
  plot(data_day_mean$Group.1,data_day_mean$x,xlim=c(0,6), ylim=c(1,9),type="o",
       xaxt="n",xlab="Day of week",ylab="Mood rating",yaxt="n",
       main="Average mood by day of week", cex.lab=1.5, cex.main=2, lwd=3)
  axis(side=1,at=c(0:6),label=week, cex.axis=1.5)
  axis(side=2, at=c(1:9), cex.axis=1.5)
  errorbars(c(0:6),data_day_mean$x,data_day_sd$x,0.05,'darkcyan')
})
