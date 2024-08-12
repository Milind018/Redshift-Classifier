
## THIS HOLDS THE ADDRESS OF OUTPUT PLOTS AND FILES. Change the address according to where you want to store the output plots ##
PLOTaddr <- "CURRENT_ANALYSIS/Upsampling/XRAY/MICE/TEST/"

## CREATES THE FOLDERS WHERE RESULTS ARE KEPT ##
if(!dir.exists('CURRENT_ANALYSIS')){dir.create('CURRENT_ANALYSIS')}
if(!dir.exists('CURRENT_ANALYSIS/Upsampling')){dir.create('CURRENT_ANALYSIS/Upsampling')}
if(!dir.exists('CURRENT_ANALYSIS/Upsampling/XRAY')){dir.create('CURRENT_ANALYSIS/Upsampling/XRAY')}
if(!dir.exists('CURRENT_ANALYSIS/Upsampling/XRAY/MICE')){dir.create('CURRENT_ANALYSIS/Upsampling/XRAY/MICE')}
if(!dir.exists('CURRENT_ANALYSIS/Upsampling/XRAY/MICE/TEST')){dir.create('CURRENT_ANALYSIS/Upsampling/XRAY/MICE/TEST')}


library(caret)

# Download files manually from https://github.com/dalpozz/unbalanced/tree/master/R
# The needed files are ubBalance.R, ubSMOTE.R, ubSmoteExs.R

source('ubBalance.R')
#source('ubOver.R')
source('ubSMOTE.R')
source('ubSmoteExs.R')


## Loading the raw data without errorbars and MICE imputed. ##
GRBData_raw_1 <- read.csv(file = "CURRENT_ANALYSIS/XRAY/MICE/TEST/NEW-XRAY_DATA_with_errorbar_after_MICE_ON_RAW_with_M-estimator.csv", header = TRUE)

#GRBData_raw <- read.csv(file = "/home/jarvis-gravity/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/CURRENT_ANALYSIS/XRAY/M-estimator/NEW-XRAY_DATA_useable_w_errorbar_after_M-estimator.csv", header = TRUE)


str(GRBData_raw_1)  # Reading the dataset as string
dim(GRBData_raw_1)  # Reading the dimension (number of elements) of the dataset
nrow(GRBData_raw_1) # Reading the number of rows in the dataset


sz = 200
RedshiftVec <- GRBData_raw_1[,'z']
png(filename = paste(PLOTaddr,'RedshiftDistribution fulldataset.png'),width = 23*sz,height = 20*sz, pointsize = 100)
par(mar=c(5,5,4,2)+0.1, lwd = 10)
hist(RedshiftVec,
     main=paste("Histogram of redshifts of ",length(RedshiftVec),' GRBs'),
     xlab = "z",ylab = 'Number of GRBs',breaks = 50, col=rgb(0,1,0,0.5))
#abline(v = 3.0, col = "red", lwd = 10)
dev.off()


GRBData_raw <- GRBData_raw_1[, -1]   # here we remove the first column from the dataset, i.e. the column with GRB names because we it is not required when we do ubBalance Sampling
redshift_cutoff <- 2.5
GRBData_raw$Class <- factor(ifelse(GRBData_raw$z > redshift_cutoff, "1", "0"))
input <- GRBData_raw # here we keep the redshift to compare the redshift distributions later
# input <- GRBPred[, -((ncol(up_train)-2):ncol(up_train))] # this is without redshift
output <- GRBData_raw$Class
perc_over=100
balance_method = "ubSMOTE"
data <- ubBalance(X=input, Y=output, positive=1
                  , type=balance_method
                  , percOver=perc_over
                  , percUnder=0
                  , verbose=TRUE)


## Saving the data file after ubBalance Sampling ##
filename = paste(PLOTaddr, 'ubsampled_NEW-XRAY_DATA_with_errorbar_after_MICE.csv', sep='')
#write.csv(GRBData_raw_4, filename, append = FALSE, row.names = FALSE, col.names = TRUE)
write.csv(data, filename)


## Here we call the ubBalanced Sample created in the above code ##
reimported_ubsampled <- read.csv(file = "CURRENT_ANALYSIS/Upsampling/XRAY/MICE/TEST/ubsampled_NEW-XRAY_DATA_with_errorbar_after_MICE.csv", header = TRUE, row.names = 1)


str(reimported_ubsampled)
dim(reimported_ubsampled)
nrow(reimported_ubsampled)


for (i in 1:ncol(GRBData_raw)) {
colnames(reimported_ubsampled)[i] <- gsub('X.','',colnames(reimported_ubsampled)[i])
}
reimported_ubsampled_corrected = reimported_ubsampled[,c(1:(ncol(reimported_ubsampled)-2))]


str(reimported_ubsampled_corrected)
dim(reimported_ubsampled_corrected)
nrow(reimported_ubsampled_corrected)


png(filename = paste(PLOTaddr,'RedshiftDistribution_after_ubBalance.png'),width = 23*sz,height = 20*sz, pointsize = 100)
par(mar=c(5,5,4,2)+0.1, lwd = 10)
hist(GRBData_raw$z,breaks = 20,col=rgb(0,1,0,0.5)
     ,main=paste0("Balancing method=",balance_method," | Redshift distribution")
     ,ylab="Number of GRBs", xlab="z")
hist(reimported_ubsampled_corrected$z,col=rgb(0,0,1,0.5),add=TRUE,breaks = 20)
legend(
  "topright"
  ,legend = c(
    paste("N of original data = ",nrow(GRBData_raw)),
    paste("N of balanced data = ",nrow(reimported_ubsampled_corrected)),
    paste("N of GRBs with z > ",redshift_cutoff, "=" ,nrow(GRBData_raw[GRBData_raw$z > redshift_cutoff,])),
    paste("N of GRBs with z < ",redshift_cutoff, "=" ,nrow(GRBData_raw[GRBData_raw$z < redshift_cutoff,]))
              )
  ,fill = c(rgb(0,1,0,0.5),rgb(0,0,1,0.5),rgb(0,0.5,0.5,1),rgb(0,1,0,0.5))
)
dev.off()


png(filename = paste0(PLOTaddr,"ubSMOTE_sampling_redshift_distribution_histogram.png"),width = 20*sz,height = 20*sz, pointsize = 100)
par(lwd=10,mar=c(5,5,4,2)+.1)
hist(GRBData_raw$z,col=rgb(1,1,1,0),add=F,freq = T,lty=1,xlim=c(0,9),ylim=c(0,60)
     ,breaks = 20
     ,main="Redshift distribution after balanced sampling",cex.axis=1.5,cex.lab=1.5
     ,xlab=substitute(paste(bold("Redshift"))),ylab=substitute(paste(bold("Number of GRBs")))
)
hist(reimported_ubsampled_corrected$z,col=rgb(1,1,1,0),add=T,freq = T,lty=2
     ,breaks = 20)

legend(
  "topright"
  ,legend = c(
    paste("- N of original data = ",nrow(GRBData_raw)),
    paste("- - N of balanced data = ",nrow(reimported_ubsampled_corrected))
              )
)
dev.off()


filename_1 = paste(PLOTaddr, 'ubsampled_correctheader_NEW-XRAY_DATA_with_errorbar_after_MICE.csv', sep='')
#write.csv(GRBData_raw_4, filename, append = FALSE, row.names = FALSE, col.names = TRUE)
write.csv(reimported_ubsampled_corrected, filename_1)


GRBData_NEW = rbind(GRBData_raw, reimported_ubsampled_corrected)


filename_2 = paste(PLOTaddr, 'FULL_ubsampled_correctheader_XRAY_DATA_with_errorbar_after_MICE_ON_RAW_with_M-estimator.csv', sep='')
write.csv(GRBData_NEW, filename_2)
