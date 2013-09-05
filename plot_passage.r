F.plot.passage <- function( df, max.date, out.file="passage.png" ){
#
#   Plot a time series of passage estimates.  This can be called from
#   Sweave files to put a figure in a report.
#
#   This file produces a bar graph of the passage estimates in df. 
#
#   input:
#   df = passage estimate data frame from F.est.passage.  This is passage summarized by "day", "week", "month" or "year".
#       It is assumed that the percentage of the estimate that was imputed is available in df$pct.imputed.catch. 
#

if( !is.na(out.file) ){
    #   ---- Open PNG device
    out.pass.graphs <- paste(out.file, "_passage.png", sep="")
    if(file.exists(out.pass.graphs)){
        file.remove(out.pass.graphs)
    }
    tryCatch({png(file=out.pass.graphs,width=7,height=7,units="in",res=600)}, error=function(x){png(file=out.pass.graphs)})  # produces hi-res graphs unless there's an error, then uses default png settings
}


#   Construct matrix of bar heights
pass <- matrix( c(df$passage * df$pct.imputed.catch, df$passage * (1 - df$pct.imputed.catch)), ncol=nrow(df), byrow=T )
dimnames(pass) <- list(NULL, df$date)

pass[ is.na(pass) ] <- 0

if( all(pass == 0) ){
    plot( c(0,1), c(0,1), xaxt="n", yaxt="n", type="n", xlab="", ylab="")
    text( .5,.5, "All Zero's\nCheck dates\nCheck that finalRunID is assigned to >=1 fish per visit\nCheck sub-Site were operating between dates")
    dev.off(dev.cur())
    ans <- out.pass.graphs
    return(ans)
}
#   Compute extent of y axis
hgts <- colSums( pass )
lab.y.at <- pretty( hgts )


#   GRaph using barplot

mp <- barplot( pass, beside=FALSE, space=0, col=c("lightblue","darkorange"), 
    legend.text=F, ylab="", xaxt="n", yaxt="n", ylim=range(c(hgts, lab.y.at)), 
    xlab="", cex.lab=1.5 )


mtext( "Passage estimate (# fish)", side=2, line=2.25, cex=1.5)

#   add a smoother line here. 
#lines( supsmu( mp, hgts), lwd=2, col="darkblue" )  # Doug did not like this


#   Add x axis labels
s.by <- capwords(attr(df,"summarized.by"))

if( casefold(s.by) == "day" ){
    season.len <- difftime( max(df$date), min(df$date), units="days")
    cat(paste("Total length of season = ", season.len, "\n"))
    if( season.len > 40 ){
        #   Just label 1st of every month
        dt <- format(df$date, "%m-%y")
        dt <- dt[ !duplicated(dt) ]
        dt <- as.POSIXct( strptime( paste( "1", dt, sep="-" ), format="%d-%m-%y"))
    
        ind <- as.numeric(cut( dt, df$date ))
        dt <- dt[ !is.na(ind) ]
        ind <- ind[!is.na(ind)]   # because first of some month may be less than first date

        lab.x.at <- mp[ind]
        lab.x.lab <- format(dt, "%d%b%y")

        axis( side=1, at=lab.x.at, label=lab.x.lab )

    } else {
        #   Label every day
        dt <- df$date
        ind <- rep(T, length(dt))
        my.las <- 2
        my.line <- 0.65
        my.adj <- 1
        my.cex <- 0.75

        lab.x.at <- mp[ind]
        lab.x.lab <- format(dt, "%d%b%y")
        
        axis( side=1, at=lab.x.at, label=rep("", length(lab.x.at)) )
        for( i in 1:length(dt) ){
            mtext( side=1, at=lab.x.at[i], text=lab.x.lab[i], las=my.las, line=my.line, adj=my.adj, cex=my.cex )
        }
    }
    
} else {
    print( df )
    if( casefold(s.by) == "month" ){
        dt <-  format(df$date, "%b %Y") 
        my.cex <- 1
        #        mons <-  format(df$date, "%b") 
        #        yrs <- format(df$date, "%Y")
        #        dt1 <- paste( "01", mons , sep="" )
        #        mons <-  as.numeric(format(df$date, "%m")) 
        #        dt2 <- as.POSIXct( strptime( paste("1",mons+1,yrs), "%d %m %Y" )) 
        #        dt2 <- dt2 - 24*60*60
        #        dt2 <- format(dt2, "%d%b")
        #        
        #        dt1[1] <- format( min(df$date), "%d%b" )
        #        dt2[length(df$date)] <- format( max(df$date), "%d%b" )
    } else {
        # "weekly"  (yearly does not get plotted)   
        dt1 <- df$date
        dt2 <- c(df$date[-1] - 24*60*60, max.date)
        dt1 <- format(dt1, "%d%b")
        dt2 <- format(dt2, "%d%b")
        dt <- paste(dt1, dt2, sep="-")
        my.cex <- .75
    }

    for( i in 1:length(dt) ){
        mtext( side=1, at=mp[i], text=dt[i], las=2, line=0.1, adj=1, cex=my.cex )
    }
}

#   Add y axis labels
lab.y.lab <- format( lab.y.at, scientific=F, big.mark=",", trim=T )
axis( side=2, at=lab.y.at, label=lab.y.lab )


#   Add total passage
N <- round(sum( df$passage ))
mtext( side=3, at=max(mp),  text=paste("N =", format(N, scientific=F, big.mark="," )), adj=1, cex=1 )

#   Add title
mtext( side=3, at=max(mp), text=attr(df,"site.name"), adj=1, cex=1.5, line=2 )
mtext( side=3, at=max(mp), text= paste(attr(df,"species.name"), ", ", attr(df,"run.name"), " run", sep=""), adj=1, cex=.75, line=1 )


#plot( df$datetime, df$passage ,type="b", xlab="Date", ylab="Number of fish", xaxt="n", cex.lab=1.5)
#mtext(side=3, text=attr(df, "site.name"), cex=1, line=.75 )
#mtext(side=3, text=paste(attr(df, "species.name"), ", ", attr(df, "run.name"), " run", sep=""), line=2, cex=2 )
#
#imp.ind <- df$pct.imputed.catch > 0   # if data summarized by 'week' 'month' or 'year', df$imputed is
#                            # a percentage of the values in that period that were missing.
#
#
#points( df$datetime[imp.ind], df$passage[imp.ind], col="red", pch=1 )
#points( df$datetime[!imp.ind], df$passage[!imp.ind], col="black", pch=16 )
#

legend( "topright", legend=c("Observed","Imputed"),
    fill=c("darkorange", "lightblue"), cex=1)

if( !is.na(out.file) ){
    dev.off(dev.cur())
    ans <- out.pass.graphs
} else {
    ans <- NULL
}

ans

}
