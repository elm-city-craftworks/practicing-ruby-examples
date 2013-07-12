file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")

data1 <- data[data$V4 %in% c(8:10) ,2]
data2 <- data[data$V4 %in% c(11:13) ,2]
data3 <- data[data$V4 %in% c(14:16) ,2]
data4 <- data[data$V4 %in% c(17:19) ,2]
data5 <- data[data$V4 %in% c(20:22) ,2]
t.test(data1,data2) #4 stands out to be worst than most

drawGraph <- function(data, range) {
  dev.new()	
  data <- data[data$V4 %in% range ,]
  graph <- hist(data$V2,freq=F,ylim=c(0,0.5),xaxt='n',xlim=c(0,10), breaks=c(0:9))
  axis(side=1, at=graph$mids, labels=c(1:9), lwd=0.5)
}


drawGraph(data, c(8:10))
drawGraph(data, c(11:13))
drawGraph(data, c(14:16))
drawGraph(data, c(17:19))
drawGraph(data, c(20:22))
