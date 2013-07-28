##3. the drag effect, calculate the expotentially smoothed average of 20 data points 
##and compare it to the global average

library("TTR")
source("helpers.R")

data <- read_data()
starting_timestamp <- data$sec[1]

data$exactday <- apply(data, 1, function(row) 
  timestamp_to_day(starting_timestamp, as.numeric(row[1])))

data_mean_EMA <- EMA(data$rating,n=20)
data_mean     <- mean(data$rating)
data_sd       <- sd(data$rating)

draw_jpg("weighted-average-summary", function() {
  graph <- plot(data$exactday,data_mean_EMA,
                type = "l",
                col  = "darkcyan",
                ylim = c(1,9),
                xaxt = "n",
                yaxt = "n",
                xlim = c(0,round_up(max(data$day))),
                lwd  = 3,
                main = "Weighted average of mood ratings over time", 
                ylab = "Mood rating",
                xlab = "Number of days since start of study",
                cex.lab=1.5, cex.main=2)

  axis(side=1, cex.axis=1.5)
  axis(side=2, at=c(1:9), cex.axis=1.5)

  abline(h=data_mean,col="darkgreen")
  abline(h=data_mean+data_sd,col="cornsilk4")
  abline(h=data_mean-data_sd,col="cornsilk4")
})
