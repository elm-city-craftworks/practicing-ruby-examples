##1. individual days, relationship between mood and time of the day patterns.
##days break into 3 hours 8am to 11pm, 15 hours. 
#38-11, 11-2, 2-5, 5-8, 8-11. 

drawGraph <- function(data, range) {
  data <- data[data$hour %in% range ,]
  graph <- hist(data$rating,freq=F,ylim=c(0,0.5),xaxt='n',xlim=c(0,10),
                breaks=c(0:9),xlab="Mood Rating",ylab="Density",
                main="Density Map of Mood Rating")
  axis(side=1, at=graph$mids, labels=c(1:9), lwd=0.5)
}

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[2]<-"rating"
names(data)[4]<-"hour"

time_period<-list(c(8:10),c(11:13),c(14:16),c(17:19),c(20:22))
data_time<-list()
for(i in c(1:length(time_period))){
  data_time[[i]] <- data[data$hour %in% time_period[[i]],2]
  data[data$hour %in% time_period[[i]],7]=i
  drawGraph(data, time_period[[i]])
}
data<-data[data$V7 %in% c(1:7) ,]
t.test(data_time[[1]],data_time[[2]]) #4 stands out to be worst than most
anova(lm(data$rating ~ data$V7)
#oneway.test(data$rating ~ data$V7,var.equal=TRUE)

