errorbars <- function(X,Y,SE,w,col=1) {
  X0 = X; Y0 = (Y-SE); X1 =X; Y1 = (Y+SE);
  arrows(X0, Y0, X1, Y1, code=3,angle=90,length=w,col=col,lwd=2);
}

draw_jpg <- function(file, callback) {
  jpeg(filename=paste('images/', file, '.jpg', sep=''), width=800, height=600)
  callback()
  dev.off()
}

round_up <- function(x) ceiling(max(x)/10)*10
