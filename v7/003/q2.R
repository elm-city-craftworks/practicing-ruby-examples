errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}

summary_plot <- function(data,col_mean,col_sd){

	data_mean <- aggregate(data$V2,by=list(data$V4),FUN=mean)
	data_sd <- aggregate(data$V2,by=list(data$V4),FUN=sd)
	data_max <- aggregate(data$V2,by=list(data$V4),FUN=max)
	data_min <- aggregate(data$V2,by=list(data$V4),FUN=min)

	dev.new()
	plot(data_mean$Group.1,data_mean$x,type="o",ylim =c(0,10),col =col_mean)
	errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col=col_sd);

}

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")

work_rest_code <- read.table("work_rest.txt",header=FALSE,sep="\t")

data$V5 = apply(data, 1, function(row) work_rest_code$V2[row[3]] )

data <- data[data$V4 %in% c(8:22) ,]

work <- data[data$V5 %in% c('work') ,]
rest <- data[data$V5 %in% c('rest') ,]

summary_plot(work, 'blue','gray')
summary_plot(rest, 'red','gray')