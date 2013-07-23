##1. individual days, relationship between mood and time of the day patterns.
##days break into 3 hours 8am to 11pm, 15 hours. 
#38-11, 11-2, 2-5, 5-8, 8-11. 

drawGraph <- function(data, range) {
  data <- data[data$hour %in% range ,]
  title <- paste("Mood Rating Density During hour",as.character(min(range)),"to",as.character(max(range)))
  graph <- hist(data$rating,freq=F,ylim=c(0,0.5),xaxt='n',xlim=c(0,10),
                breaks=c(0:9),xlab="Mood Rating",ylab="Density",
                main=title)
  axis(side=1, at=graph$mids, labels=c(1:9), lwd=0.5)
}

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[2]<-"rating"
names(data)[3]<-"day"
names(data)[4]<-"hour"
names(data)[5]<-"weekdayname"
names(data)[6]<-"weekdaynum"


time_period<-list(c(8:10),c(11:13),c(14:16),c(17:19),c(20:22))
data_time<-list()
for(i in c(1:length(time_period))){
  data_time[[i]] <- data[data$hour %in% time_period[[i]],2]
  data[data$hour %in% time_period[[i]],7]=i
  drawGraph(data, time_period[[i]])
}
names(data)[7]<-"timenum"
data<-data[data$timenum %in% c(1:7) ,]

#stats
#1. test variance of all the groups, 2 at a time. 
#If in any pair the variance are significantly different, 
#the whole groups have unequal variances.

var.test(data_time[[1]],data_time[[2]],alternatiive=c("two.sided"))
#result, p=0.7661, equal

var.test(data_time[[1]],data_time[[3]],alternatiive=c("two.sided"))
#result, p=0.03268, not equal

#we could print the variance of each group to conceptually verify:
var(data_time[[1]]) #1.71
var(data_time[[2]]) #1.84
var(data_time[[3]]) #2.82
var(data_time[[4]]) #4.82
var(data_time[[5]]) #2.42

#2. One way ANOVA, for comparing means for more than two groups, 
#while controlling the error rate. We run it with unequal variance.
oneway.test(rating ~ timenum, data=data,var.equal=F)
#result: p = 0.0045, significantly different. 
#It means there is at least two groups that have different means.

#3. posthoc t tests between each pair
t.test(data_time[[1]],data_time[[2]]) 
#result: group 4 stands out to be worst than most, 17 to 19

#4. print out the mean for each group to confirm
mean(data_time[[1]])
mean(data_time[[2]])
mean(data_time[[3]])
mean(data_time[[4]])
mean(data_time[[5]])
