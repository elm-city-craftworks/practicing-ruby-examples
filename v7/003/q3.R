##3. the drag effect, calculate the expotentially smoothed average of 20 data points 
##and compare it to the global average
library("TTR")
file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[1]<-"time"
names(data)[2]<-"rating"
names(data)[3]<-"day"

data_mean_EMA <- EMA(data$rating,n=20)
data_mean <- mean(data$rating)
data_sd <- sd(data$rating)

#not accurate, but probably looks good enough
x_at<-aggregate(data$time,by=list(data$day),FUN=mean)
x_label<-aggregate(data$day,by=list(data$day),FUN=mean)
  
plot(data$time,data_mean_EMA,type="l",col="red",xaxt="n",ylim=c(1,9),xlab="day",
     ylab="Moving Average of Rating")

axis(side=1,at=x_at$x,labels=x_label$x)

abline(h=data_mean,col="green")
abline(h=data_mean+data_sd,col="gray")
abline(h=data_mean-data_sd,col="gray")
