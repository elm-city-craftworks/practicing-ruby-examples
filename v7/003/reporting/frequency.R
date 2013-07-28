##1. individual days, relationship between mood and time of the day patterns.
##days break into 3 hours 8am to 11pm, 15 hours. 
#38-11, 11-2, 2-5, 5-8, 8-11. 

source("helpers.R")

drawGraph <- function(data, range) {
  data  <- data[data$hour %in% range ,]

  title <- paste(as.character(min(range)),
                 ":00 to ",as.character(max(range) + 1), ":00", sep="")

  graph <- hist(data$rating,
                freq   = F,
                ylim   = c(0,0.5),
                xaxt   = 'n',
                xlim   = c(0,10),
                breaks = c(0:9),
                xlab   = "", 
                ylab   = "",
                main   = title, 
                col    = "lightblue",
                cex.lab=2.5, cex.main=4, cex.sub=2.5, cex.axis=2.5)

  axis(side=1, at=graph$mids, labels=c(1:9), lwd=0.5, cex.axis=2.5)
}

data <- read_data()

time_period <- list(c(8:10),c(11:13),c(14:16),c(17:19),c(20:22))
data_time   <- list()

for(i in c(1:length(time_period))){
  data_time[[i]] <- data[data$hour %in% time_period[[i]],2]

  data[data$hour %in% time_period[[i]], 7] = i

  draw_jpg(paste("frequency", i, sep=''), function() drawGraph(data, time_period[[i]]))
}
