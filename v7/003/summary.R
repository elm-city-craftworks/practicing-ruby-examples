
# from bmscblog.wordpress.com/2013/01/23/error-bars-with-r 

#separate days with fewer than 5 points
errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col);
}


file <- download.file("http://sleepy-shore-7394.herokuapp.com/mood-logs.csv", destfile="mood-logs.csv")

data <- read.table("mood-logs.csv",header=FALSE,sep=",")
data_mean <- aggregate(data$V2,by=list(data$V3),FUN=mean)
data_sd <- aggregate(data$V2,by=list(data$V3),FUN=sd)
data_max <- aggregate(data$V2,by=list(data$V3),FUN=max)
data_min <- aggregate(data$V2,by=list(data$V3),FUN=min)
data_count <- aggregate(data$V2,by=list(data$V3),FUN=length)

plot(data_mean$Group.1,data_mean$x,type="o",ylim =c(0,10),col ="red")
errorbars(data_mean$Group.1,data_mean$x,data_sd$x,0.05,col="gray");

#lines(data_max$Group.1,data_max$x,col = "black",lty=1)
#lines(data_min$Group.1,data_min$x,col = "black",lty=1)

#total_mean <- mean(data$V2)
#total_sd <- sd(data$V2)
#lines(data_mean$Group.1,rep(c(total_mean),dim(data_mean)[1]),col = "red")
#lines(data_mean$Group.1,rep(c(total_mean+total_sd),dim(data_mean)[1]),col = "red",lty=2)
#lines(data_mean$Group.1,rep(c(total_mean-total_sd),dim(data_mean)[1]),col = "red",lty=2)

