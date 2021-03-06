F.summarize.fish.visit.Unassd <- function( catch ){
#
#   Summarize fish count and fork lengths over visits.
#
#   catch = data frame containing one line per fish or fish group with identical lengths.
#       If they did not catch any member of a particular taxon, catch will have 0 rows.  This 
#       data frame will usually be the output of F.get.indiv.fish.data()
#
#   Output = a data frame with one line per visit, with catch summarized.
#

  

  

if( nrow(catch) > 0 ){

    #   These are variables that are constant within a trapVisit, run, and lifestage
    const.vars<-c("ProjID", "trapVisitID", "batchDate", "StartTime", "EndTime", "SampleMinutes", 
        "TrapStatus", "siteID", "siteName", "trapPositionID", "TrapPosition", "sampleGearID", 
        "sampleGear", "halfConeID", "HalfCone", "FinalRun", "lifeStage", "Unassd" )                      # jason 4/14/2015 - add Unassd

    #   indexes = all unique combinations of visit, run, and life stage
    #   indexes = NA for all gaps in the trapping sequence
    indexes <- tapply( 1:nrow(catch), list( catch$trapVisitID, catch$FinalRun, catch$Unassd ) ) # catch$lifeStage ) )   jason 4/14/2015 - change to retain Unassigned
    
    #   Because of the gap lines, there are NA's in indexes (because there are NA's in trapVisitID). 
    #   Fix these.  To assure indexes is same length as catch, we cannot simply remove NA's here. 
    #   Solution: set them to -1, then remove -1 from u.ind.  This way the loop below 
    #   just skips them.
    indexes[ is.na(indexes) ] <- -1

    #   Initialize place to store summarized catches. 
    #u.ind <- sort(unique(indexes))  # NA's in indexes are lost here, in the sort
    #catch.fl <- as.data.frame( matrix( NA, length(u.ind), length(const.vars) + 3 ))
    #names( catch.fl ) <- c(const.vars, "n.tot", "mean.fl", "sd.fl")


    
    u.ind <- indexes[!duplicated(indexes)]
    catch.fl <- catch[!duplicated(indexes),const.vars]  # these are not the right lines, they will be replaced inside the loop.  This just initializes
    catch.fl <- catch.fl[ u.ind > 0, ]    #  Don't want the former NA's, which are now -1's. 
    u.ind <- u.ind[ u.ind > 0 ]  #  Don't want the former NA's, which are now -1's. 
    catch.fl <- cbind( catch.fl, matrix( NA, nrow(catch.fl), 3))
    names( catch.fl ) <- c(const.vars, "n.tot", "mean.fl", "sd.fl")

    

    #   Count number of fish, compute mean fork length, etc per visitID in catch.  
    for( i in 1:length(u.ind) ){

        ind <- (u.ind[i] == indexes) & !is.na(indexes)
    
        #   Copy over constant variables
        catch.fl[i,const.vars] <- catch[ind,const.vars][1,]
        
        catch.fl$n.tot[i]       <- sum( catch$Unmarked[ind], na.rm=T ) # Don't think Unmarked can be missing, but rm just in case.

        #   Take weighted averages of fork lengths using 'n' as weights
        if( !is.na(catch.fl$n.tot[i]) & (catch.fl$n.tot[i] > 0) ){ # I don't actually know whether catch.fl$n.tot[i] can be missing, but just in case
            fl <- rep(catch$forkLength[ind & !is.na(catch$forkLength)], catch$Unmarked[ind & !is.na(catch$forkLength)])  
            catch.fl$mean.fl[i]           <- mean( fl, na.rm=T )   # could have missing fork length
            catch.fl$sd.fl[i]             <- sd( fl , na.rm=T )
        } else {
            catch.fl$mean.fl[i] <- NA
            catch.fl$sd.fl[i] <- NA
        }
        
    }
 

    
    #   Add back in the lines with missing indexes.  These correspond to gaps in trapping
#    tmp <- catch[ indexes < 0, const.vars ]
#    tmp <- cbind( tmp, matrix( NA, sum(indexes < 0), 3))
#    names( tmp ) <- c(const.vars, "n.tot", "mean.fl", "sd.fl")
#    catch.fl <- rbind( catch.fl,  tmp )

    
    #   Sort the result by trap positing and trap visit
    catch.fl <- catch.fl[ order( catch.fl$trapPositionID, catch.fl$EndTime ), ]


} else {
    catch.fl <- NA
}


catch.fl

}
