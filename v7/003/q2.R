##2. work day or rest day, mood difference

errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}

summary_plot <- function(data,col_mean,col_sd,title){

	data_mean <- aggregate(data$rating,by=list(data$hour),FUN=mean)
	data_sd <- aggregate(data$rating,by=list(data$hour),FUN=sd)

	plot(data_mean$Group.1,data_mean$x,type="o",ylim =c(0,10),col =col_mean,xlab="hour",
       ylab="rating",main=title)
	errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col=col_sd);

}

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[2]<-"rating"
names(data)[4]<-"hour"

work_rest_code <- read.table("work_rest.txt",header=FALSE,sep="\t")

data$V7 = apply(data, 1, function(row) work_rest_code[row[3],  2] )
names(data)[7]<-"day_type"

data <- data[data$hour %in% c(8:22) ,]

work <- data[data$day_type %in% c('work') ,c(2,4)]
rest <- data[data$day_type %in% c('rest') ,c(2,4)]

summary_plot(work, 'blue','gray','work')
summary_plot(rest, 'red','gray','rest')

#stats1: merging all the hours, treating ratings in either day_type (wor/rest) as one group
#1. test the variance
var.test(work$rating,rest$rating)
#result, p<.001. significant, unequal variance

#2. run independent t test of the work and rest groups
t.test(work$rating,rest$rating,var.equal = FALSE)
#result, p < .001. significantly different. work has a higher mean than rest
