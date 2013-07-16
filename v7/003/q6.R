#q6, day of the week effect

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[1]<-"sec"
names(data)[2]<-"rating"
names(data)[3]<-"day"
names(data)[4]<-"hour"
names(data)[5]<-"weekday"

week <- c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")
color <- c("black","blue","gray","red","pink","green","orange")

dev.new()
plot.new()
for(i in c(1:length(week))){
	day_name <- week[i]
	data_day <- data[data$weekday %in% c(day_name),]
	data_hour <- aggregate(data_day$rating, by=list(data_day$hour),FUN=mean)
	if(i==1){
		plot(data_hour$Group.1, data_hour$x, type="l",col=color[i])
	}
	else{lines(data_hour$Group.1, data_hour$x, col=color[i])
	}
}
legend(5,legend=week,col=color,lty=1)
