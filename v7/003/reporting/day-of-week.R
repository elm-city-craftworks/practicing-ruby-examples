#q6, day of the week effect

source("helpers.R")

errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}


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
  plot(data_day_mean$Group.1,data_day_mean$x,xlim=c(0,6), ylim=c(0,10),type="o",
       xaxt="n",xlab="Day of the Week",ylab="Mood Rating",
       main="Average mood by day of week")
  axis(side=1,at=c(0:6),label=week)
  errorbars(c(0:6),data_day_mean$x,data_day_sd$x,0.05,'red')
})
