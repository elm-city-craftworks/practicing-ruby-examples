##3. the drag effect, calculate the expotentially smoothed average of 20 data points 
##and compare it to the global average
library("TTR")
file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")

data_mean_EMA <- EMA(data$V2,n=20)
data_mean <- mean(data$V2)
data_sd <- sd(data$V2)

plot(data$V1,data_mean_EMA,type="l",col="red",xaxt="n",ylim=c(1,9))

abline(h=data_mean,col="green")
abline(h=data_mean+data_sd,col="gray")
abline(h=data_mean-data_sd,col="gray")
