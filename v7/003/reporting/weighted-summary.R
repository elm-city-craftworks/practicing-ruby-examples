##3. the drag effect, calculate the expotentially smoothed average of 20 data points 
##and compare it to the global average

library("TTR")
source("helpers.R")

timestamp_to_day <- function(ts_start, ts_current) {
  1 + ((ts_current - ts_start) / 86000)
}

data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
starting_timestamp <- data[1, 1]

data$V1 <- apply(data, 1, function(row) 
  timestamp_to_day(starting_timestamp, as.numeric(row[1])))

data_mean_EMA <- EMA(data$V2,n=20)
data_mean <- mean(data$V2)
data_sd <- sd(data$V2)


draw_jpg("weighted-average-summary", function() {
  # TODO: Put some tick marks indicating the days on the x-axis
  graph <- plot(data$V1,data_mean_EMA,type="l",col="red",ylim=c(1,9),
      main="Weighted average of mood ratings over time", ylab="Mood rating",
       xlab="Number of days from study start date", xaxt="n", yaxt="n",
       xlim=c(0,round_up(max(data$V3))))

  axis(side=1)
  axis(side=2, at=c(1:9))

  abline(h=data_mean,col="green")
  abline(h=data_mean+data_sd,col="gray")
  abline(h=data_mean-data_sd,col="gray")
})
