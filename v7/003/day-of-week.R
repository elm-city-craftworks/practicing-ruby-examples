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

# --- statistical testing (prints to console only) ---

#ANOVA to compare the means
oneway.test(rating ~ weekdaynum, data=data,var.equal=F)

# posthoc t tests between each pair, used FDR adjustment
pairwise.t.test(data$rating, data$weekdaynum,p.adj = "fdr" )
#print out the mean for each group to confirm
tapply(data$rating,data$weekdaynum,FUN=mean)
