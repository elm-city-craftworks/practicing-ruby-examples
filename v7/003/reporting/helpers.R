errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col,lwd=2);
}

draw_jpg <- function(file, callback) {
  jpeg(filename=paste('images/', file, '.jpg', sep=''), width=800, height=600)
  callback()
  dev.off()
}

read_data <- function() {
  data <- read.table("data/mood-logs.csv",header=FALSE,sep=",")
  names(data)[1]<-"sec"
  names(data)[2]<-"rating"
  names(data)[3]<-"day"
  names(data)[4]<-"hour"
  names(data)[5]<-"weekdayname"
  names(data)[6]<-"weekdaynum"

  data
}

round_up <- function(x) ceiling(max(x)/10)*10

timestamp_to_day <- function(ts_start, ts_current) {
  1 + ((ts_current - ts_start) / 86000)
}
