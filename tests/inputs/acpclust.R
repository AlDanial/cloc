### Code by Eric Lecoutre, Universite catholique de Louvain, Belgium
### Winner of the R Homepage graphics competition 2004
# http://www.r-project.org/misc/acpclust.R

### Created using R 1.8.1, still works in 2.9.2

require(ade4)
## require(mva)   # was merged into stats
require(RColorBrewer)
require(pixmap)

ltitle <- function(x,backcolor="#e8c9c1",forecolor="darkred",cex=2,ypos=0.4)
{	
    plot(x=c(-1,1),y=c(0,1),xlim=c(0,1),ylim=c(0,1),type="n",axes=FALSE)
    polygon(x=c(-2,-2,2,2),y=c(-2,2,2,-2),col=backcolor,border=NA)
    text(x=0,y=ypos,pos=4,cex=cex,labels=x,col=forecolor)
}

plotacpclust <- function(data,xax=1,yax=2,hcut,cor=TRUE,clustermethod="ave",
                         colbacktitle="#e8c9c1",wcos=3,Rpowered=FALSE,...)
{
    ## data: data.frame to analyze
    ## xax, yax: Factors to select for graphs
    
    ## Parameters for hclust
    ##   hcut
    ##   clustermethod
    
    require(ade4)
    
    pcr=princomp(data,cor=cor)
    
    datac=t((t(data)-pcr$center )/pcr$scale)
    
    hc=hclust(dist(data),method=clustermethod)
    if (missing(hcut)) hcut=quantile(hc$height,c(0.97))
    
    def.par <- par(no.readonly = TRUE)
    on.exit(par(def.par))
    
    mylayout=layout(matrix(c(1,2,3,4,5,1,2,3,4,6,7,7,7,8,9,7,7,7,10,11),ncol=4),widths=c(4/18,2/18,6/18,6/18),heights=c(lcm(1),3/6,1/6,lcm(1),1/3))
    
    par(mar = c(0.1, 0.1, 0.1, 0.1))
    par(oma = rep(1,4))
    ltitle(paste("PCA ",dim(unclass(pcr$loadings))[2], "vars"),cex=1.6,ypos=0.7)
    text(x=0,y=0.2,pos=4,cex=1,labels=deparse(pcr$call),col="black")
    pcl=unclass(pcr$loadings)
    pclperc=100*(pcr$sdev)/sum(pcr$sdev)
    s.corcircle(pcl[,c(xax,yax)],1,2,sub=paste("(",xax,"-",yax,") ",
                                     round(sum(pclperc[c(xax,yax)]),0),"%",sep=""),
                possub="bottomright",csub=3,clabel=2)
    wsel=c(xax,yax)
    scatterutil.eigen(pcr$sdev,wsel=wsel,sub="")
    
    dend=hc
    dend$labels=rep("",length(dend$labels))
    dend=as.dendrogram(dend)

    ngrp=length(cut(dend,hcut)$lower)
    
    ltitle(paste("Clustering ",ngrp, "groups"),cex=1.6,ypos=0.4)
    
    par(mar = c(3, 0.3, 1, 0.5))
    
    ## Dendrogram
    attr(dend,"edgetext") = round(max(hc$height),1)
    plot(dend, edgePar = list(lty=1, col=c("black","darkgrey")), edge.root=FALSE,horiz=TRUE,axes=TRUE)
    
    abline(v=hcut,col="red")
    text(x=hcut,y=length(hc$height),labels=as.character(round(hcut,1)),col="red",pos=4)
    
    
    colorsnames= brewer.pal(ngrp,"Dark2")
    groupes=cutree(hc,h=hcut)
    ttab=table(groupes)
    
    ## Groups
    par(mar = c(0.3, 0.3, 1.6, 0.3))
    mp=barplot(as.vector(rev(ttab)),horiz=TRUE,space=0,col=rev(colorsnames),
               xlim=c(0,max(ttab)+10),axes=FALSE,main="Groups",axisnames=FALSE)
    text(rev(ttab),mp,as.character(rev(ttab)),col=rev(colorsnames),cex=1.2,pos=4)


    
    ## Main ACP scatterplot

    par(mar = c(0.1,0.1, 0.1,0.1))	
    selscores=pcr$scores[,c(xax,yax)]
    
    zi=apply(datac,1,FUN=function(vec)return(sum(vec^2)))
    cosinus= cbind(selscores[,1]^2 / zi,selscores[,2]^2 / zi)
    cosinus= cbind(cosinus,apply(cosinus,1,sum))
    ww= (cosinus[,wcos])*4 +0.5
    
    ## Outliers? Test with median+1.5*IQ
    
    ## Factor #1
    out <- selscores[,1] < median(selscores[,1]) - 1.5 * diff(quantile(selscores[,1],c(0.25,0.75)))
    out = out | selscores[,1] > median(selscores[,1]) + 1.5 * diff(quantile(selscores[,1],c(0.25,0.75)))
    ## factor #2		
    out = out | selscores[,2] < median(selscores[,2]) - 1.5 * diff(quantile(selscores[,2],c(0.25,0.75)))
    out = out | selscores[,2] > median(selscores[,2]) + 1.5 * diff(quantile(selscores[,2],c(0.25,0.75)))

    plot(selscores,axes=FALSE,main="",xlab="",ylab="",type="n")
    abline(h=0,col="black")
    abline(v=0,col="black")
    
    
    points(selscores[!out,1:2],col=(colorsnames[groupes])[!out],cex=ww,pch=16)
    
    
    text(x=selscores[out,1],y=selscores[out,2],labels=dimnames(selscores)[[1]][out],
         col=(colorsnames[groupes])[out], adj=1)
    box()
    
    


    ## Factor 1
    par(mar = c(0.1, 0.1, 0.1, 0.1))
    ltitle(paste("Factor ",xax, " [",round(pclperc[xax],0),"%]",sep="" ),cex=1.6,ypos=0.4)
    plotdens(pcr$scores[,c(xax)])
    
    ## Factor 2
    par(mar = c(0.1, 0.1, 0.1, 0.1))
    ltitle(paste("Factor ",yax," [",round(pclperc[yax],0),"%]",sep=""),cex=1.6,ypos=0.4)
    plotdens(pcr$scores[,c(yax)])
}

confshade2 <- function(y, xlo, xhi, col = 8.)
{
    n <- length(y)
    for(i in 1.:(n - 1.)) {
        polygon(c(xlo[i], xlo[i + 1.], xhi[i + 1.], xhi[i]),
                c(y[i], y[i + 1.], y[i + 1.], y[i]), col = col, border = FALSE)
    }
}

confshade <- function(x, ylo, yhi, col = 8.)
{
    n <- length(x)
    for(i in 1.:(n - 1.)) {
        polygon(c(x[i], x[i + 1.], x[i + 1.], x[i]),
                c(ylo[i], ylo[i + 1.], yhi[i + 1.], yhi[i]), col = col, border = FALSE)
    }
}


plotdens <- function(X, npts = 200, range = 1.5, xlab = "", ylab = "", main = "", ...)
{
    dens <- density(X, n = npts)
    qu <- quantile(X, c(0., 0.25, 0.5, 0.75, 1.))
    x <- dens$x
    y <- dens$y
    fqux <- x[abs(x - qu[2.]) == min(abs(x - qu[2.]))]
    fquy <- y[x == fqux]
    fquX <- as.numeric(qu[2.])
    tqux <- x[abs(x - qu[4.]) == min(abs(x - qu[4.]))]
    tquy <- y[x == tqux]
    tquX <- as.numeric(qu[4.])
    medx <- x[abs(x - qu[3.]) == min(abs(x - qu[3.]))]
    medy <- y[x == medx]
    ## Prepare les donnees a dessiner
    medX <- as.numeric(qu[3.])
    dx <- dens$x
    
    dy <- dens$y
    dx2 <- c(dx[dx <= fquX], fquX, dx[(dx > fquX) &
                (dx <= medX)], medX, dx[(dx > medX) & (dx <= tquX)], tquX, dx[dx > tquX])
    
    dy2 <- 	c(dy[dx <= fquX], fquy, dy[(dx > fquX) & (dx <= medX)], medy,
                  dy[(dx > medX) & (dx <= tquX)], tquy, dy[dx > tquX])
    IQX <- dx2[(dx2 >= fquX) & (dx2 <= tquX)]
    ##
    ##
    ## Initialise le graphique
    ##

    ## Dessine la densite
    IQy <- dy2[(dx2 >= fquX) & (dx2 <= tquX)]
    ## Trace densit sous IQ
    plot(0., 0., xlim = c(min(dx2), max(dx2)), ylim = c(min(dy2), max(dy2)),
         axes = F, xlab = xlab, ylab = ylab, main = main,type="n", ...)
    ## Ajoute mediane
    confshade(IQX, rep(0., length(IQX)), IQy, col = "#bdfcc9")
    bdw <- (tquX - fquX)/20.
    x1 <- c(medX - bdw/2., medX - bdw/2.)
    x2 <- c(medX + bdw/2., medX + bdw/2.)
    y1 <- c(0., medy)
    ## Ajoute lignes wiskers
    polygon(c(x1, rev(x2)), c(y1, rev(y1)), col = 0.)
    lines(x = c(fquX, fquX), y = c(0., fquy))
    ## Ajoute wiskers
    lines(x = c(tquX, tquX), y = c(0., tquy))
    meany <- mean(dy2)
    IQrange <- tquX - fquX
    lines(x = c(medX - range * IQrange, fquX), y = c(meany, meany))
    lines(x = c(tquX, medX + range * IQrange), y = c(meany, meany))
    lines(x = c(medX - range * IQrange, medX - range * IQrange),
          y = c(meany - (max(dy2) - min(dy2))/8., meany + (max(dy2) - min(dy2))/8.))

    ## Ajoute outliers
    
    lines(x = c(medX + range * IQrange, medX + range * IQrange),
          y = c(meany - (max(dy2) - min(dy2))/8., meany + (max(dy2) - min(dy2))/8.))
    out <- c(X[X < medX - range * IQrange], X[X > medX + range * IQrange])

    ## Ajoute les points...
    ## Ajoute l'axe
    points(out, rep(meany, length(out)), pch = 5., col = 2.)
    ## Ajoute l'axe
    points(dx2, dy2, pch = ".", type = "l")
    ##return(x = dessinx2, y = dessiny2)
    axis(1., at = round(c(min(x), fquX, medX, tquX, max(x)), 2.), labels = F,
         pos = 0.)
    invisible(list(x = dx2, y = dy2))
}



BoxDens <- function(data, npts = 200., x = c(0., 100.), y = c(0., 50.), orientation = "paysage",
                    add = TRUE, col = 11., border=FALSE,colline = 1., Fill = TRUE)
{
    dens <- density(data, n = npts)
    dx <- dens$x
    dy <- dens$y
    if(add == FALSE)
        plot(0., 0., axes = F, main = "", xlim = x, ylim = y, xlab = "",
             ylab = "")
    if(orientation == "paysage") {
        dx2 <- (dx - min(dx))/(max(dx) - min(dx)) * (x[2.] - x[1.]) * 0.98 +
            x[1.]
        dy2 <- (dy - min(dy))/(max(dy) - min(dy)) * (y[2.] - y[1.]) * 0.98 +
            y[1.]
        seqbelow <- rep(y[1.], length(dx))
        if(Fill == T)
            confshade(dx2, seqbelow, dy2, col = col)
        if (border==TRUE) points(dx2, dy2, type = "l", col = colline)
    }
    else {
        dy2 <- (dx - min(dx))/(max(dx) - min(dx)) * (y[2.] - y[1.]) * 0.98 +
            y[1.]
        dx2 <- (dy - min(dy))/(max(dy) - min(dy)) * (x[2.] - x[1.]) * 0.98 +
            x[1.]
        seqleft <- rep(x[1.], length(dy))
        if(Fill == T)
            confshade2(dy2, seqleft, dx2, col = col)
        if (border==TRUE) points(dx2, dy2, type = "l", col = colline)
    }
    polygon(x = c(x[1.], x[2.], x[2.], x[1.]),
            y = c(y[2.], y[2.], y[1.], y[1.]), density = 0.)
}


data(swiss)
## png(file="swiss.png", width=600,height=400)
plotacpclust(swiss[,1:5], 1, 3, hcut=48)
## dev.off()

