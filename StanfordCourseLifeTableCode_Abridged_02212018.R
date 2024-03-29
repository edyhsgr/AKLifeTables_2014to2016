##############################################################################################################################
##R CODE FOR A PERIOD LIFE TABLE, REPRODUCED FROM ONLINE MATERIALS FOR THE 2006 FORMAL DEMOGRAPHY WORKSHOP AT STANFORD UNIVERSITY
##THE ORIGINAL POSTING OF THIS CODE IS AVAILABLE AT: http://www.stanford.edu/group/heeh/cgi-bin/web/node/75
##############################################################################################################################

##############################################################################################################################
#STEP 1: Read in and review the population and death data
##############################################################################################################################

DeathsAndPopulation<-read.table(file="https://raw.githubusercontent.com/edyhsgr/AKLifeTables_2014to2016/master/DeathsAndPopulation_AK2014to2016InputsAbridged.csv",header=TRUE,sep=",")
DeathsAndPopulation

##############################################################################################################################
#STEP 2: Read in or create the fundamental pieces of the life table (age groupings, deaths by age, population by age ->death rates by age
##############################################################################################################################

x <- c(0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85)
#note that R collapses a single column to a vector when it pulls out the result out of a data.frame
nDxTotal <- DeathsAndPopulation$nDxTotal
nKxTotal <- DeathsAndPopulation$nKxTotal
nMxTotal <- nDxTotal / nKxTotal

nDxFemale <- DeathsAndPopulation$nDxFemale
nKxFemale <- DeathsAndPopulation$nKxFemale
nMxFemale <- nDxFemale / nKxFemale

nDxMale <- DeathsAndPopulation$nDxMale
nKxMale <- DeathsAndPopulation$nKxMale
nMxMale <- nDxMale / nKxMale

##############################################################################################################################
#STEP 3: Read in the period life table function
##############################################################################################################################

life.table <- function( x, nMx){
## simple lifetable using Keyfitz and Flieger separation factors and 
## exponential tail of death distribution (to close out life table)
b0 <- 0.07;   b1<- 1.7;      
nmax <- length(x)
#nMx = nDx/nKx   
n <- c(diff(x),999)          		#width of the intervals
nax <- n / 2;		            	# default to .5 of interval
nax[1] <- b0 + b1 *nMx[1]    		# from Keyfitz & Flieger(1968)
nax[2] <- 1.5  ;              
nax[nmax] <- 1/nMx[nmax] 	  	# e_x at open age interval
nqx <- (n*nMx) / (1 + (n-nax)*nMx)
nqx<-ifelse( nqx > 1, 1, nqx);		# necessary for high nMx
nqx[nmax] <- 1.0
lx <- c(1,cumprod(1-nqx)) ;  		# survivorship lx
lx <- lx[1:length(nMx)]
ndx <- lx * nqx ;
#Edited by EddieH (below line is my edit of this line) - February 2018 #nLx <- n*lx - nax*ndx;       		# equivalent to n*l(x+n) + (n-nax)*ndx
nLx <- n*lx - (n-nax)*ndx;       		# equivalent to n*l(x+n) + nax*ndx
nLx[nmax] <- lx[nmax]*nax[nmax]
Tx <- rev(cumsum(rev(nLx)))
ex <- ifelse( lx[1:nmax] > 0, Tx/lx[1:nmax] , NA);
lt <- data.frame(x=x,nax=nax,nmx=nMx,nqx=nqx,lx=lx,ndx=ndx,nLx=nLx,Tx=Tx,ex=ex)
return(lt)
}

##############################################################################################################################
#STEP 4: Apply the function to the data, and review the created life table
##############################################################################################################################

LifeTable_T<-life.table(x,nMxTotal)
LifeTable_T

LifeTable_F<-life.table(x,nMxFemale)
LifeTable_F

LifeTable_M<-life.table(x,nMxMale)
LifeTable_M

write.table(LifeTable_T, file="C:/Users/brocejh/Desktop/AbridgedLifeTableTotal_AK2014to2016Output.csv", sep=",", row.names=FALSE)
write.table(LifeTable_F, file="C:/Users/brocejh/Desktop/AbridgedLifeTableFemale_AK2014to2016Output.csv", sep=",", row.names=FALSE)
write.table(LifeTable_M, file="C:/Users/brocejh/Desktop/AbridgedLifeTableMale_AK2014to2016Output.csv", sep=",", row.names=FALSE)
