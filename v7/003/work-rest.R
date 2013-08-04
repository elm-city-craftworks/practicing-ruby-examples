##2. work day or rest day, mood difference

source("helpers.R")

summary_plot <- function(data,col_mean,col_sd,label,filename){
  data_mean <- aggregate(data$rating,by=list(data$hour),FUN=mean)
  data_sd   <- aggregate(data$rating,by=list(data$hour),FUN=sd)

  draw_jpg(filename, function() {
	  plot(data_mean$Group.1, data_mean$x,
          type = "o",
          ylim = c(1,9),
          col  = col_mean,
          xaxt = "n",
          yaxt = "n",
          main = label, 
          ylab = "Mood rating", 
          xlab = "Time of day",
          cex.main=2, cex.lab=1.5, lwd=2)

    axis(side=1, at=c(8:22), cex.axis=1.5)
    axis(side=2, at=c(1:9), cex.axis=1.5)

    errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col=col_sd) 
  })
}


data <- read_data()

work_rest_code <- read.table("data/work_rest.csv",header=FALSE, sep=",")

data$category <- apply(data, 1, function(row) work_rest_code[row[3],  2] )


data <- data[data$hour %in% c(8:22) ,]

work <- data[data$category %in% c('work') ,]
rest <- data[data$category %in% c('rest') ,]

summary_plot(work, 'blue',rgb(0.5,0.5,0.5), "Average mood by time of day for work days","work-average")
summary_plot(rest, 'red',rgb(0.5,0.5,0.5), "Average mood by time of day for rest days",
             "rest-average")
