
source("helpers.R")

data <- read_data()

data_max <- aggregate(rating ~ day, data, max)
data_min <- aggregate(rating ~ day, data, min)

draw_jpg("daily-min-max", function() {
  plot(data_min$day, data_min$rating, 
       type = "l",
       col  = "coral1",
       xlim = c(0,round_up(max(data$day))), 
       xaxt = "n", 
       yaxt = "n",
       main = "Minimum and maximum mood ratings by day",
       ylab = "Mood rating", 
       xlab = "Number of days since start of study",
       cex.main=2, cex.lab=1.5, lwd=2)

  axis(side=1, cex.axis=1.5)
  axis(side=2, at=c(1:9), cex.axis=1.5)

  lines(data_max$day, data_max$rating, type="l", lwd=2, col="darkgreen")
})
