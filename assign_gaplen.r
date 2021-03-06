F.assign.gaplen <- function(df){
#
#   Function to look for and assign gaps in sampling
#

#   Make sure data base is sorted
df <- df[order(df$trapPositionID, df$sampleEnd),]


#   Look for gaps by trapPositionID
gpl  <- NULL
u.traps <- unique( df$trapPositionID )
for( trap in u.traps ){
    df2 <- df[df$trapPositionID == trap,]

    end.prev <- df2$sampleEnd[ -nrow(df2) ]
    strt.next <- df2$sampleStart[ -1 ]

    gap.len <- difftime(strt.next, end.prev, units="hours")
    gap.len <- c(gap.len, 0 )   # could assign 0 here.  Really, its NA

    gpl <- c(gpl, gap.len)
}

df$sampleGapLenHrs <- gpl

df

}


    
