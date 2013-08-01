source("helpers.R")

data <- read_data()

week <- c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")

data_day_mean <- aggregate(data$rating, by=list(data$weekdaynum),FUN=mean)
data_day_sd   <- aggregate(data$rating, by=list(data$weekdaynum),FUN=sd)

draw_jpg("day-of-week-summary", function() {
  plot(data_day_mean$Group.1,data_day_mean$x,
       xlim = c(0,6), 
       ylim = c(1,9),
       type = "o",
       xaxt = "n", 
       yaxt = "n",
       xlab = "Day of week",
       ylab = "Mood rating",
       main = "Average mood by day of week", 
       cex.lab=1.5, cex.main=2, lwd=3)

  axis(side=1,at=c(0:6),label=week, cex.axis=1.5)
  axis(side=2, at=c(1:9), cex.axis=1.5)

  errorbars(c(0:6), data_day_mean$x, data_day_sd$x, 0.05, 'darkcyan')
})

#print variance
tapply(data$rating,data$weekdaynum,FUN=var)
#compare variance
var.test(data[data$weekdaynum %in% 0,2],data[data$weekdaynum %in% 1,2],alternatiive=c("two.sided"))
var.test(data[data$weekdaynum %in% 0,2],data[data$weekdaynum %in% 2,2],alternatiive=c("two.sided"))
var.test(data[data$weekdaynum %in% 0,2],data[data$weekdaynum %in% 3,2],alternatiive=c("two.sided"))

#ANOVA to compare the means
oneway.test(rating ~ weekdaynum, data=data,var.equal=F)

#result: p = 0.0034, significantly different.
#It means there is at least two groups that have different means.

#3. posthoc t tests between each pair, used FDR adjustment
pairwise.t.test(data$rating, data$weekdaynum,p.adj = "fdr" )
#result: Mon-Wed, Mon-Sat,Tue-Sat,Wed-Fri,Fri-Sat are different
#Saturday different from Mon, Tue and Fri
#Wed different from Mon and Fri

#4. print out the mean for each group to confirm
tapply(data$rating,data$weekdaynum,FUN=mean)
