##2. work day or rest day, mood difference

source("helpers.R")

summary_plot <- function(data,col_mean,col_sd,label,filename){
	data_mean <- aggregate(data$V2,by=list(data$V4),FUN=mean)
	data_sd <- aggregate(data$V2,by=list(data$V4),FUN=sd)
	data_max <- aggregate(data$V2,by=list(data$V4),FUN=max)
	data_min <- aggregate(data$V2,by=list(data$V4),FUN=min)

  draw_jpg(filename, function() {
	  plot(data_mean$Group.1,data_mean$x,type="o",ylim =c(0,10),
          col=col_mean, main=label, ylab="Mood rating", xlab="Time of day")
  	errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col=col_sd) })
}


data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")

work_rest_code <- read.table("data/work_rest.txt",header=FALSE,sep="\t")

data$V6 = apply(data, 1, function(row) work_rest_code[row[3],  2] )


data <- data[data$V4 %in% c(8:22) ,]

work <- data[data$V6 %in% c('work') ,]
rest <- data[data$V6 %in% c('rest') ,]

summary_plot(work, 'blue','gray', "Average mood by time of day for work days","work-average")
summary_plot(rest, 'red','gray', "Average mood by time of day for rest days",
             "rest-average")
