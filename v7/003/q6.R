#q6, day of the week effect

errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}

file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
names(data)[1]<-"sec"
names(data)[2]<-"rating"
names(data)[3]<-"day"
names(data)[4]<-"hour"
names(data)[5]<-"weekdayname"
names(data)[6]<-"weekdaynum"

week <- c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")

data_day_mean <- aggregate(data$rating, by=list(data$weekdaynum),FUN=mean)
data_day_sd <- aggregate(data$rating, by=list(data$weekdaynum),FUN=sd)

plot(data_day_mean$Group.1,data_day_mean$x,xlim=c(0,6), ylim=c(0,10),type="o",xaxt="n",xlab="Day of the Week",ylab="Mood Rating")
axis(side=1,at=c(0:6),label=week)
errorbars(c(0:6),data_day_mean$x,data_day_sd$x,0.05,'red')


#status, compare the mean of each day. same as q1
#1. grab the data in list
data_day=list()
for(i in c(1:7)){
  data_day[[i]] <- data[data$weekdaynum %in% c(i-1) ,2]
}
#2. compare variance
var.test(data_day[[1]],data_day[[2]],alternatiive=c("two.sided"))
var.test(data_day[[1]],data_day[[3]],alternatiive=c("two.sided"))
var.test(data_day[[1]],data_day[[4]],alternatiive=c("two.sided"))
#significant, unequal variance

#3. oneway anova
oneway.test(rating ~ weekdaynum, data=data,var.equal=F)
#significant

#4. t tests
t.test(data_day[[1]],data_day[[2]])
t.test(data_day[[1]],data_day[[3]])
t.test(data_day[[1]],data_day[[4]])
t.test(data_day[[1]],data_day[[5]])
t.test(data_day[[1]],data_day[[6]])
t.test(data_day[[1]],data_day[[7]])
#1 vs 4 and 1 vs 7 different, sunday is different from wed and sat
#then test tuesday. ......