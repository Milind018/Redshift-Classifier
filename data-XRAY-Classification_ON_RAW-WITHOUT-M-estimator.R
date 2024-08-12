
## THIS HOLDS THE ADDRESS OF OUTPUT PLOTS AND FILES. Change the address according to where you want to store the output plots ##
PLOTaddr <- "CURRENT_ANALYSIS/Graphics/XRAY/RAW_WITHOUT_M-estimator/"

## CREATES THE FOLDERS WHERE RESULTS ARE KEPT ##
if(!dir.exists('CURRENT_ANALYSIS')){dir.create('CURRENT_ANALYSIS')}
if(!dir.exists('CURRENT_ANALYSIS/Graphics')){dir.create('CURRENT_ANALYSIS/Graphics')}
if(!dir.exists('CURRENT_ANALYSIS/Graphics/XRAY')){dir.create('CURRENT_ANALYSIS/Graphics/XRAY')}
if(!dir.exists('CURRENT_ANALYSIS/Graphics/XRAY/RAW_WITHOUT_M-estimator')){dir.create('CURRENT_ANALYSIS/Graphics/XRAY/RAW_WITHOUT_M-estimator')}


require(ggplot2)
require(gplots)
require(SuperLearner)
require(foreach)
require(parallel)
require(doParallel)
require(unbalanced)
require(plyr)
require(party)
require(ROCR)
require(pROC)
require(rbind)
require(cbind)
require(abind)
require(caret)
require(glmnet)
require(e1071)
require(GGally)

## For running the code in parallel on different cores ##
numCores = detectCores()  # Leave two cores out so you can still use your machine or if you use the cluster then use all the cores
cluster=parallel::makeCluster(numCores,outfile="")
parallel::clusterEvalQ(cluster, library(SuperLearner))
parallel::clusterSetRNGStream(cluster, 1)

## Sourcing the external R pacakge. Change the address according to where you save these files. ## which you can find in the next upload and I shall send you in the email before the lecture.
#source('/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/sl_glmnet_interactions.R')
#source('/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/sl_gam.R')
#source('/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/miss.SLOB.R')
#source('/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/importance.R')
#source("/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/slobeC/R/slope_admm.R")
#source('/home/jarvis-astro/PhD/NAOJ_Maria-Giovanna-Dainotti/GRBmachinelearning/Dankworth_SULI_2021/internals.R')
source('sl_svm.R')


## Loading the raw data with errorbars. This data contains the GRBs with some missing variables, some of which are alreday assigned as NA. Other missing variables which are not assigned as NA, we will assign them as NA later in the code ##
run_locally = F
if(run_locally){
GRBData_raw_data_w_errorbar <- read.csv(file = "NEW-XRAY_DATA_RAW_w_errorbar_WITHOUT-M-estimator.csv",
                                        header=TRUE)
cutoff=3.0} else {
  args <- commandArgs(trailingOnly = TRUE)
  cutoff <- as.numeric(args[2])
  input_file <- args[1]
  output_file <- args[3]
  GRBData_raw_data_w_errorbar <- read.csv(input_file, header = TRUE)
}


str(GRBData_raw_data_w_errorbar)  # Reading the dataset as string
dim(GRBData_raw_data_w_errorbar)  # Reading the dimension (number of elements) of the dataset
nrow(GRBData_raw_data_w_errorbar) # Reading the number of rows in the dataset


GRBData_raw_1 <- data.frame(matrix(ncol = 0, nrow = nrow(GRBData_raw_data_w_errorbar)))
GRBData_raw_1$GRB_Name <- GRBData_raw_data_w_errorbar$X
GRBData_raw_1$z <- GRBData_raw_data_w_errorbar$Redshift_crosscheck
GRBData_raw_1$log10T90 <- log10(GRBData_raw_data_w_errorbar$T90)
GRBData_raw_1$log10Fluence <- GRBData_raw_data_w_errorbar$log10Fluence
GRBData_raw_1$log10PeakFlux <- GRBData_raw_data_w_errorbar$log10PeakFlux
GRBData_raw_1$PhotonIndex <- GRBData_raw_data_w_errorbar$PhotonIndex
GRBData_raw_1$log10NH <- GRBData_raw_data_w_errorbar$log10NH
GRBData_raw_1$log10Fa <- GRBData_raw_data_w_errorbar$log10Fa
GRBData_raw_1$log10Ta <- GRBData_raw_data_w_errorbar$log10Ta
GRBData_raw_1$Alpha <- GRBData_raw_data_w_errorbar$Alpha
GRBData_raw_1$Beta <- GRBData_raw_data_w_errorbar$Beta
GRBData_raw_1$Gamma <- GRBData_raw_data_w_errorbar$Gamma
GRBData_raw_1$log10T90Err <- GRBData_raw_data_w_errorbar$T90Err / (GRBData_raw_data_w_errorbar$T90 * log(10))  ## Defining the T90 error in log values
GRBData_raw_1$log10FluenceErr <- GRBData_raw_data_w_errorbar$FluenceErr / ((10**GRBData_raw_data_w_errorbar$log10Fluence) * log(10))  ## Defining the Fluence error in log values
GRBData_raw_1$log10PeakFluxErr <- GRBData_raw_data_w_errorbar$PeakFluxErr / ((10**GRBData_raw_data_w_errorbar$log10PeakFlux) * log(10))  ## Defining the Fluence error in log values
GRBData_raw_1$PhotonIndexErr <- GRBData_raw_data_w_errorbar$PhotonIndexErr
GRBData_raw_1$log10FaErr <- GRBData_raw_data_w_errorbar$log10FaErr
GRBData_raw_1$log10TaErr <- GRBData_raw_data_w_errorbar$log10TaErr
GRBData_raw_1$AlphaErr <- GRBData_raw_data_w_errorbar$AlphaErr
GRBData_raw_1$BetaErr <- GRBData_raw_data_w_errorbar$BetaErr

str(GRBData_raw_1)


GRBData_raw_1$log10NH[GRBData_raw_1$log10NH < 20] <- NA
GRBData_raw_1$PhotonIndex[GRBData_raw_1$PhotonIndex < 0] <- NA
GRBData_raw_1$PhotonIndexErr[is.na(GRBData_raw_1$PhotonIndex)] <- NA
#GRBData_raw_1$log10PeakFlux[10**(GRBData_raw_1$log10PeakFlux) == 0] <- NA
#GRBData_raw_1$log10PeakFluxErr[10**(GRBData_raw_1$log10PeakFlux) == 0] <- NA
GRBData_raw_1$Alpha[GRBData_raw_1$Alpha > 3] <- NA
GRBData_raw_1$AlphaErr[is.na(GRBData_raw_1$Alpha)] <- NA
GRBData_raw_1$Beta[GRBData_raw_1$Beta > 3] <- NA
GRBData_raw_1$BetaErr[is.na(GRBData_raw_1$Beta)] <- NA
GRBData_raw_1$Gamma[GRBData_raw_1$Gamma > 3] <- NA
GRBData_raw_1$log10NH[GRBData_raw_1$log10NH < 20] <- NA
GRBData_raw_1$PhotonIndex[GRBData_raw_1$PhotonIndex < 0] <- NA
GRBData_raw_1$PhotonIndexErr[is.na(GRBData_raw_1$PhotonIndex)] <- NA
GRBData_raw_1$PhotonIndexErr[GRBData_raw_1$PhotonIndexErr == 0] <- NA
#GRBData_raw_1$log10PeakFlux[10**(GRBData_raw_1$log10PeakFlux) == 0] <- NA
#GRBData_raw_1$log10PeakFluxErr[10**(GRBData_raw_1$log10PeakFlux) == 0] <- NA
GRBData_raw_1$log10PeakFluxErr[GRBData_raw_1$log10PeakFluxErr == 0] <- NA
GRBData_raw_1$log10FluenceErr[GRBData_raw_1$log10FluenceErr == 0] <- NA
GRBData_raw_1$Alpha[GRBData_raw_1$Alpha > 3] <- NA
GRBData_raw_1$AlphaErr[is.na(GRBData_raw_1$Alpha)] <- NA
GRBData_raw_1$AlphaErr[GRBData_raw_1$AlphaErr == 0] <- NA
GRBData_raw_1$Beta[GRBData_raw_1$Beta > 3] <- NA
GRBData_raw_1$BetaErr[is.na(GRBData_raw_1$Beta)] <- NA
GRBData_raw_1$BetaErr[GRBData_raw_1$BetaErr == 0] <- NA
GRBData_raw_1$Gamma[GRBData_raw_1$Gamma > 3] <- NA


GRBData_raw_2 <- na.omit(GRBData_raw_1)  # Omit NA values from the data
## Adding log10(z+1) as extra variable ##
GRBData_raw_2$log10z <- log10(GRBData_raw_2$z+1)
str(GRBData_raw_2)


GRBData1 <- GRBData_raw_2
#GRBData1 <- na.omit(GRBData1)  # Omit NA values from the data
str(GRBData1)
dim(GRBData1)
nrow(GRBData1)

GRBData1$log10T90_error_bar <- ifelse(GRBData1$log10T90Err / GRBData1$log10T90 < 1, 0, 1)  # 0 if TRUE, 1 if FALSE
GRBData1$log10Fluence_error_bar <- ifelse(GRBData1$log10FluenceErr / GRBData1$log10Fluence < 1, 0, 1)
GRBData1$log10PeakFlux_error_bar <- ifelse(GRBData1$log10PeakFluxErr / GRBData1$log10PeakFlux < 1, 0, 1)
GRBData1$log10PhotonIndex_error_bar <- ifelse(GRBData1$PhotonIndexErr / GRBData1$PhotonIndex < 1, 0, 1)
GRBData1$log10Fa_error_bar <- ifelse(GRBData1$log10FaErr / GRBData1$log10Fa < 1, 0, 1)
GRBData1$log10Ta_error_bar <- ifelse(GRBData1$log10TaErr / GRBData1$log10Ta < 1, 0, 1)
GRBData1$Alpha_error_bar <- ifelse(GRBData1$AlphaErr / GRBData1$Alpha < 1, 0, 1)
GRBData1$Beta_error_bar <- ifelse(GRBData1$BetaErr / GRBData1$Beta < 1, 0, 1)

print(GRBData1$log10T90_error_bar)
print(GRBData1$log10Fluence_error_bar)
print(GRBData1$log10PeakFlux_error_bar)
print(GRBData1$log10PhotonIndex_error_bar)
print(GRBData1$log10Fa_error_bar)
print(GRBData1$log10Ta_error_bar)
print(GRBData1$Alpha_error_bar)
print(GRBData1$Beta_error_bar)


print("Conditions:")

print(paste("Initial:","GRBData1:", nrow(GRBData1)))

## Pairs Outliers, discarding the data points with error bar > 1 and taking only the data points with error bar < 1 ##
GRBData2 <- GRBData1[GRBData1$log10T90_error_bar == 0,] # 0 is error bar < 1, 1 is error bar > 1
GRBData3 <- GRBData2[GRBData2$log10Fluence_error_bar == 0,]
GRBData4 <- GRBData3[GRBData3$log10PeakFlux_error_bar == 0,]
GRBData5 <- GRBData4[GRBData4$log10PhotonIndex_error_bar == 0,]
GRBData6 <- GRBData5[GRBData5$log10Fa_error_bar == 0,]
GRBData7 <- GRBData6[GRBData6$log10Ta_error_bar == 0,]
GRBData8 <- GRBData7[GRBData7$Alpha_error_bar == 0,]
GRBData9 <- GRBData8[GRBData8$Beta_error_bar == 0,]

print(paste("After removing pairs outliers", "GRBData2:", nrow(GRBData2), " |", "GRBData3:", nrow(GRBData3), " |", "GRBData4:", nrow(GRBData4), " |", "GRBData5:", nrow(GRBData5), " |", "GRBData6:", nrow(GRBData6), " |", "GRBData7:", nrow(GRBData7), " |", "GRBData8:", nrow(GRBData8), " |", "GRBData9:", nrow(GRBData9)))


str(GRBData9)
dim(GRBData9)
nrow(GRBData9)


## Removing the columns which are not required ##
GRBData10 <- GRBData9[,-c(1,13:20,22:29)]
GRBData10$invz <- 1/(GRBData10$z+1)
GRBData10$Len <- ifelse(GRBData10$z <= cutoff, 0, 1) # 0 if TRUE, 1 if FALSE, this is the redshift (z) cutoff to define low-z and high-z GRBs, you can change this cutoff ##

nrow(GRBData10[GRBData10$z > cutoff,])  # Reading how many GRBs are high-z according to the defined cutoff ##


str(GRBData10)
dim(GRBData10)
nrow(GRBData10)


#set.seed(1)
#data_threshold = sort(sample(nrow(GRBData10), nrow(GRBData10)*.8))  # 80% data as Training Set, rest 20% as Prediction/Test Set
#TrainingData<-GRBData10[data_threshold,]
#TestData<-GRBData10[-data_threshold,]

# Determine the number of rows for Training and Test sets
n_training <- round(nrow(GRBData10) * 0.8)  # 80% of the data for Training Set
n_test <- nrow(GRBData10) - n_training  # Remaining data for Test Set

# Split the data into Training and Test sets using specific row indices
TrainingData <- GRBData10[1:n_training, ]
TestData <- GRBData10[(n_training + 1):nrow(GRBData10), ]
str(TrainingData)
dim(TrainingData)
str(TestData)
dim(TestData)

print(nrow(TrainingData[TrainingData$z > cutoff,])) ##
print(nrow(TestData[TestData$z > cutoff,])) ##


# Lasso feature selection function definition
LASSO <- function(X,Y)
{
  X<-as.matrix(X) # THE TRAINING DATA
  Y<-as.vector(Y) # THE RESPONSE VECTOR
  lasso_model<-cv.glmnet(X,Y,family="binomial",alpha=1) # LASSO REGRESSION
  return(lasso_model)
}


sz = 200  # Defining the size of the plots
cols <- colnames(GRBData10[,-c(1,12:14)])  # it excludes from the reading the columns 10-13
print(cols)
cols_1 <- colnames(TrainingData[,-c(1,12:14)])
print(cols_1)


#  Lasso feature selection usage (SOMETIMES VARIABLES PICKED BY LASSO VARY. HENCE TO ENSURE CONSISTENCY, WE RUN LASSO 1000 TIMES.)
z_scale <- TrainingData$Len
lasso_cols <- colnames(TrainingData[,-c(1,12:14)])
lasmod<-LASSO(TrainingData[,lasso_cols], z_scale)
lasso_coef<-as.data.frame(lasmod$glmnet.fit$beta[,lasmod$glmnet.fit$lambda==lasmod$lambda.1se])

for (a in 1:100) {
  lasmod<-LASSO(TrainingData[,lasso_cols],z_scale) # LASSO IS PERFORMED
  lasso_coef<-cbind(lasso_coef,lasmod$glmnet.fit$beta[,lasmod$glmnet.fit$lambda==lasmod$lambda.1se])
}

par(mar=c(5,9,4,4))
barplot(
  rowMeans(lasso_coef),
  horiz = T, las=2,
  names.arg = colnames(TrainingData[,lasso_cols]),
  xpd=T
)


# Variables picked by Lasso and saving the plot in the directory defined in the beginning
png(filename = paste(PLOTaddr,'LassoFeatures.png',sep = ''), width = 23*sz,height = 20*sz, pointsize = 100) # this saves the plot directly into the designated folder, comment this out if you want to see the plot here first

# Set plot parameters
par(lwd = 17, pty='s', font.axis = 2, font.lab = 2, cex.axis = 1.5, cex.lab = 1.5, cex.main = 2)
#par(lwd = 3, font = 2, cex.axis = 1.5, cex.lab = 1.5, cex.main = 2)

barplot(
  rowMeans(lasso_coef),
  horiz = T, las=2,
  border = "black",
  col = 'red',
  density = 100,
  names.arg = colnames(TrainingData[,lasso_cols]),
  main=paste('LASSO Feature Selection'),
  xpd=T,
  cex.names = 1.2,   # Increase the size of the names
  xaxt = 'n'
)

# Draw x-axis with bold line and ticks
#axis(1, lwd = 3, tck = -0.02, col.axis = 'black')
axis(1, lwd = 20, lwd.ticks = 20, cex.axis = 1.5, col.axis = 'black')

dev.off() # this saves the plot directly into the designated folder, comment this out if you want to see the plot here first


# Predictors with more than 2% weight
lc<-data.frame(co=rowMeans(lasso_coef))
LassoVars<-row.names(lc)[10*abs(lc$co)>0.02] # CHOOSE THOSE PARAMETERS WHICH HAVE MORE THAN 2% WEIGHT
print(LassoVars)

# Define the file paths
LassoVars_file_path <- paste0(PLOTaddr, "LAASO_features.txt")

# Save the LASSO selected variables to text files in the defined location
#write.csv(LassoVars, LassoVars_file_path, row.names = FALSE, quote = FALSE)
writeLines(LassoVars, LassoVars_file_path)


#png(filename = paste(PLOTaddr,'Scatterplot full dataset.png'),width = 20*sz,height = 20*sz, pointsize = 68)
#pairs(as.matrix(GRBData10[,c('log10z', colnames(GRBData10[,cols]))]),
#      horOdd = T ,
#      pch=19,
#      col = 'darkgreen',
#      cex=0.8,
#      cex.labels=0.9,
#      main=paste('Scatter Plot of Full Data Sample of ',dim(GRBData10)[1],' GRBs')
#)
#dev.off()

plot <- ggpairs(as.matrix(GRBData10[,-c(13:14)]),
        columns = colnames(GRBData10[,-c(13:14)]),
        aes(color='red'),
        axisLabels = c("show"),
        columnLabels = colnames(GRBData10[,-c(13:14)]),
        upper=list(continuous=GGally::wrap("cor", method="pearson", stars=FALSE, size=1.3,col='blue')),
        lower = list(continuous = wrap("points", size = 0.5)),
        #title = paste('Scatter Matrix Plot of',dim(Totdata)[1],' samples'),
        diag = list(continuous = wrap("barDiag", bins=10, fill='red', col='black')),) +theme_bw()+theme(panel.background = element_rect(colour = 'white'), 
                                                                                                        panel.grid = element_blank(), axis.text = element_text(colour = 'black'), 
                                                                                                        strip.text=ggplot2::element_text(size=5,face="bold")
)

## Modify axis text size ##
plot <- plot + theme(axis.text.x = element_text(size = 4),
                     axis.text.y = element_text(size = 4))

#show(plot)
ggsave(paste0(PLOTaddr,'Scatter Plot of Full Data Sample of ',dim(GRBData10)[1],' GRBs.png'), plot, width = 10, height = 10, dpi = 300, limitsize = FALSE)


png(filename = paste(PLOTaddr,'Scatterplot TrainingData.png'),width = 20*sz,height = 20*sz, pointsize = 68)
pairs(as.matrix(TrainingData[,c('log10z', colnames(TrainingData[,cols]))]),
      horOdd = T ,
      pch=19,
      col = 'darkgreen',
      cex=0.8,
      cex.labels=0.9,
      main=paste('Scatter Plot of Training Dataset of ',dim(TrainingData)[1],' GRBs')
)
dev.off()


png(filename = paste(PLOTaddr,'Scatterplot TestData.png'),width = 20*sz,height = 20*sz, pointsize = 68)
pairs(as.matrix(TestData[,c('log10z', colnames(TestData[,cols]))]),
      horOdd = T ,
      pch=19,
      col = 'darkgreen',
      cex=0.8,
      cex.labels=0.9,
      main=paste('Scatter Plot of Test Dataset of ',dim(TestData)[1],' GRBs')
)
dev.off()


RedshiftVec <- GRBData10[,'z']
invRedshiftVec <- GRBData10[,'invz']
log10RedshiftVec <- GRBData10[,'log10z']
T90binary2 <- GRBData10[,'Len']


png(filename = paste(PLOTaddr,'RedshiftDistribution fulldataset.png'),width = 23*sz,height = 20*sz, pointsize = 100)
par(mar=c(5,5,4,2)+0.1, lwd = 10)
hist(RedshiftVec,
     main=paste("Histogram of redshifts of ",length(RedshiftVec),' GRBs'),
     xlab = "z",ylab = 'Number of GRBs',breaks = 50)
abline(v = cutoff , col = "red", lwd = 10) ##
dev.off()


## Here we apply a transformation of the variables ##
png(filename = paste(PLOTaddr,'InvRedshiftDistribution fulldataset.png'),width = 23*sz,height = 20*sz, pointsize = 100)
par(mar=c(5,5,4,2)+0.1, lwd = 10)
hist(invRedshiftVec,
     main=paste("Histogram of redshifts of ",length(invRedshiftVec),' GRBs in 1/(z+1) scale'),
     xlab = "1/(z+1)",ylab = 'Number of GRBs',breaks = 50)
dev.off()


## Here we apply a transformation of the variables ##
png(filename = paste(PLOTaddr,'log10RedshiftDistribution fulldataset.png'),width = 23*sz,height = 20*sz, pointsize = 100)
par(mar=c(5,5,4,2)+0.1, lwd = 10)
hist(log10RedshiftVec,
     main=paste("Histogram of redshifts of ",length(log10RedshiftVec),' GRBs in log10(z+1) scale'),
     xlab = "log10(z+1)",ylab = 'Number of GRBs',breaks = 50)
dev.off()



## Using every algorithm to test which algorithm is the best one within the SL ##
libs_SL=c('SL.cforest', 'SL.glm', 'SL.glmnet', 'SL.kernelKnn', 'SL.ksvm', 'SL.svm', 'SL.lda', 'SL.lm', 'SL.qda', 'SL.ranger', 'SL.randomForest', 'SL.speedglm', 'SL.speedlm', 'SL.xgboost', 'SL.biglasso', 'SL.bayesglm', 'SL.caret.rpart', 'SL.earth')
#libs_SL=c('SL.glm', 'SL.glmnet', 'SL.lm', 'SL.randomForest', 'SL.bayesglm', 'SL.earth', 'SL.svm')


## No need to change anything here except where mentioned ## Assigning the variables
Training_len <- TrainingData$Len
Test_len <- TestData$Len
#set.seed(12345)
system.time({
  numCores = detectCores() - 2  # Leaving two cores out so you can still use your machine or if you use the cluster then use all the cores
  registerDoParallel(numCores)
  loop = 10  # Looping the SL over 100 times to compute the prediction error, we don't need to use the pacakges for the list of models in .packages because they are already inside the SuperLearner package
  SL_CVmodel<-foreach(i = 1:loop, .packages=c("SuperLearner"), .export = libs_SL)

    SL_model<-CV.SuperLearner(Y = Training_len,X =TrainingData[,LassoVars], cvControl= list(V = 10, stratifyCV=T), family = binomial(), method = "method.AUC", SL.library = libs_SL, control = list(saveFitLibrary=T)) # 10-fold CV with LASSO variables


    })


## Displays the coefficients for each algorithm ##
AlgoCoef_SL<-data.frame(Algo=libs_SL,Coeffs=colMeans(SL_model$coef))

## Displays the risks for each algorithm. Uncomment this if you want to see the risk values for each algorithm ##
#AlgoRisk_SL<-data.frame(Algo=libs_SL,Coeffs=colMeans(SL_model$cvRisk))

print(AlgoCoef_SL)
#print(AlgoRisk_SL)  # Uncomment this if you want to see the risk values for each algorithm


## Here we can see visually the coefficients of the ensamble method ##
png(filename = paste(PLOTaddr,'Testing_SL_Coefficients_Plot.png',sep = ''), width = 23*sz,height = 20*sz, pointsize = 100)

par(mar=c(5,10,5,5), lwd=17, pty='s', font.axis = 2, font.lab = 2, cex.axis = 1.5, cex.lab = 1.5, cex.main = 2)

barplot(as.numeric(AlgoCoef_SL$Coeffs), horiz = T, las=2,
        names.arg=AlgoCoef_SL$Algo,
        xlim = c(0, 0.2),
        main=paste('SuperLearner Coefficients Plot'),
        xpd = F,
        density = 100,
        cex.names = 1.2,   # Increase the size of the names
        xaxt = 'n'
        )
abline(v = 0.05, col = "red", lwd = 25)

# Draw x-axis with bold line and ticks
axis(1, lwd = 20, lwd.ticks = 20, cex.axis = 1.5, col.axis = 'black')

dev.off()


## HERE YOU CAN CHANGE THE WEIGHTS TO SELECT THE BEST SL ALGORITHM ACCORDING TO THE DATA SAMPLE ##
libs_SL_CV <- c(AlgoCoef_SL$Algo[AlgoCoef_SL$Coeffs > 0.05])
print(libs_SL_CV)

# Define the file paths
SL_algo_file_path <- paste0(PLOTaddr, "SL_algo.txt")

# Save the SL selected algorithms to text files in the defined location
#write.csv(libs_SL_CV, SL_algo_file_path, row.names = FALSE, quote = FALSE)
writeLines(libs_SL_CV, SL_algo_file_path)


libs_SL_CV = c("SL.cforest", "SL.kernelKnn", "SL.qda", "SL.ranger", "SL.randomForest")
loop <- 100
plotnames<-paste("_",length(libs_SL_CV),"algo_",ncol(TrainingData[,LassoVars]),"vrb_",loop,"times",sep = "")


## No need to change anything here except where mentioned ##
#set.seed(12345)
system.time({
  numCores = detectCores() - 3  # Leaving two cores out so you can still use your machine or if you use the cluster then use all the cores
  registerDoParallel(numCores)
  loop = 10
  CVmodel<-foreach(i = 1:loop, .packages=c("SuperLearner"), .export = libs_SL_CV
                   )  %dopar% {
    gc()
    CV<-CV.SuperLearner(Y = Training_len,X =TrainingData[,LassoVars], cvControl= list(V = 10, stratifyCV=T), family = binomial(), method = "method.AUC", SL.library = libs_SL_CV, control = list(saveFitLibrary=T))

    ValPred<-predict(CV$AllSL$`1`,TestData[,LassoVars])$pred
    ValPred<-cbind(ValPred,predict(CV$AllSL$`2`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`3`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`4`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`5`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`6`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`7`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`8`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`9`,TestData[,LassoVars])$pred)
    ValPred<-cbind(ValPred,predict(CV$AllSL$`10`,TestData[,LassoVars])$pred)

    ValAlgoPred<-predict(CV$AllSL$`1`,TestData[,LassoVars])$library.predict
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`2`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`3`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`4`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`5`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`6`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`7`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`8`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`9`,TestData[,LassoVars])$library.predict,along = 3)
    ValAlgoPred<-abind(ValAlgoPred,predict(CV$AllSL$`10`,TestData[,LassoVars])$library.predict,along = 3)


    # THIS EXTRACTS THE CROSS VALIDATIONED RISK VALUE FOR THE ALGORITHMs

    r<-CV$AllSL$`1`$cvRisk
    r<-rbind(r,CV$AllSL$`2`$cvRisk)
    r<-rbind(r,CV$AllSL$`3`$cvRisk)
    r<-rbind(r,CV$AllSL$`4`$cvRisk)
    r<-rbind(r,CV$AllSL$`5`$cvRisk)
    r<-rbind(r,CV$AllSL$`6`$cvRisk)
    r<-rbind(r,CV$AllSL$`7`$cvRisk)
    r<-rbind(r,CV$AllSL$`8`$cvRisk)
    r<-rbind(r,CV$AllSL$`9`$cvRisk)
    r<-rbind(r,CV$AllSL$`10`$cvRisk)

    s<-summary(CV)$Table$Ave[c(-1,-2)]
    xgbAccu<-sum((CV$library.predict>.5)==TrainingData$Len) / length(CV$library.predict)

    return(list(colMeans(coef(CV)),CV$SL.predict,rowMeans(ValPred),s,xgbAccu,CV$library.predict,apply(ValAlgoPred,c(1,2),mean)))
    # 1st column = Coefficients of algorithms, averaged over each fold of the 10fCV
    # 2nd column = The 10fCV predictions
    # 3rd column = TestData prediction
    # 4th column = average risk estimate for the V folds
    # 5th column = accuracy of folds vs. TestData
    # 6th column = 10fcv predictions again, but per algorithm



  }
})


accu<-as.vector(0)
LinearAccu<-as.vector(0)

TestAccu<-as.vector(0) # HOLD THE ACCURACY VALUES OF THE TEST SET

trainLevels <-matrix(nrow = length(Training_len),ncol = loop) #holds levels loop times, for wacky ROCR reasons

preds<-matrix(nrow = length(Training_len),ncol = loop) #JUST TO HOLD THE PREDICTION VALUES. LATER ITS AVERAGED OVER TO GET THE CV PLOT
Testpreds<-matrix(nrow = length(Test_len),ncol = loop)

algopreds<-array(dim=c(length(Training_len), loop, length(libs_SL_CV)))
Valalgopreds<-array(dim=c(length(Test_len), loop, length(libs_SL_CV)))

co<-matrix(nrow = loop,ncol = length(libs_SL_CV))
AlgoRisks<-matrix(nrow = loop,ncol = length(libs_SL_CV))

xgbrisk<-matrix(nrow = length(libs_SL_CV),ncol = loop)
xgbaccu<-matrix(nrow = length(libs_SL_CV),ncol = loop)

for (j in 1:loop) {
  print(j)
  trainLevels[,j]<-Training_len
  preds[,j]<-CVmodel[[j]][[2]]
  Testpreds[,j]<-CVmodel[[j]][[3]]
  co[j,]<-CVmodel[[j]][[1]]
  AlgoRisks[j,]<-CVmodel[[j]][[4]]

  xgbrisk[,j]<-CVmodel[[j]][[4]]
  xgbaccu[,j] <- CVmodel[[j]][[5]]

  algopreds[,j,]<-CVmodel[[j]][[6]]
  Valalgopreds[,j,]<-CVmodel[[j]][[7]]

  print(co[j,])
  accu[j]<-sum((preds[,j]>.5)==Training_len)/length(preds[,j])

  TestAccu[j]<-sum((Testpreds[,j]>.5)==Test_len)/length(Testpreds[,j]) # ASSIGNING THE ACCURACY VALUES OF TEST DATA

  print(mean(accu))
  print(mean(TestAccu))


  png(filename = paste(PLOTaddr,"/AlgoWeightHisto_w_acc_",j,".png",sep=""))
  barplot(as.numeric(co[j,]), horiz = T, las=2,
          names.arg=libs_SL_CV,
          main = paste("Coefficients | 10 fold CV accuracy=",signif(accu,4)),
          xpd = F)
  dev.off()
  png(filename = paste(PLOTaddr,"/AlgoRiskHisto_w_acc_",j,".png",sep=""))
  barplot(as.numeric(AlgoRisks[j,]-min(AlgoRisks[j,])), horiz = T, las=2,
          names.arg=libs_SL_CV,
          main = paste("Risks | 10 fold CV accuracy=",signif(accu,4)),
          xpd = F)
  dev.off()
}


## In our case True +ve are high-z GRBs, while True -ve are low-z GRBs ##
## For the example of Confusion matrix you can refer to my slide and to Wikipedia https://en.wikipedia.org/wiki/Confusion_matrix ##
CVmeanpreds<-round(rowMeans(preds))
CVconfusion<-confusionMatrix(factor(CVmeanpreds),factor(Training_len),"1",c("Predicted","Reference"))
print(CVconfusion)

Testmeanpreds<-round(rowMeans(Testpreds))
Testconfusion<-confusionMatrix(factor(Testmeanpreds),factor(Test_len),"1",c("Predicted","Reference"))
print(Testconfusion)

# Function to save confusion matrix to a file
save_confusion_matrix <- function(confusion_matrix, file_path) {
  output <- capture.output(print(confusion_matrix))
  writeLines(output, file_path)
}

# Define the file paths
cv_confusion_file_path <- paste0(PLOTaddr, "CVconfusion.txt")
test_confusion_file_path <- paste0(PLOTaddr, "Testconfusion.txt")

# Save the confusion matrices to text files in the defined location
save_confusion_matrix(CVconfusion, cv_confusion_file_path)
save_confusion_matrix(Testconfusion, test_confusion_file_path)


ROCpred = ROCR::prediction(rowMeans(preds), Training_len, label.ordering = c(0,1))# training data predictions
ROCperf = ROCR::performance(ROCpred, "tpr", "fpr")

ROCvalpred = ROCR::prediction(rowMeans(Testpreds), Test_len, label.ordering = c(0,1))# test data predictions
ROCvalperf = ROCR::performance(ROCvalpred, "tpr", "fpr")

Trainingarea = ROCR::performance(ROCpred, measure = "auc", x.measure = "cutoff")@y.values[[1]]
Testarea = ROCR::performance(ROCvalpred, measure = "auc", x.measure = "cutoff")@y.values[[1]]

print(Trainingarea)
#print(ROCperf)
print(Testarea)
#print(ROCvalperf)


## Please refer to my slide and to https://en.wikipedia.org/wiki/Receiver_operating_characteristic ##
#par(pty='s', lwd=20, mar = c(5, 4, 4, 2) + 0.1, font.axis = 2, font.lab = 2)
#par(mar=c(5,10,5,5), lwd=17, pty='s', font.axis = 10, font.lab = 10, cex.axis = 6.5, cex.lab = 6.5, cex.main = 5)
par(pty='s', lwd=20, font.axis = 10, font.lab = 10)

png(filename = paste(PLOTaddr,'TrainingData_ROC.png'), width = 23*sz,height = 20*sz, pointsize = 100)
#ROCR::plot(ROCperf, avg="threshold", spread.estimate="boxplot", main = paste("Training data | Area under curve = ",Trainingarea), colorize=TRUE, lwd=20)
ROCR::plot(ROCperf, avg="threshold", spread.estimate="boxplot", colorize=TRUE, lwd=20, cex.lab=1.3, font.lab=2)
abline(a=0, b=1)
# Draw x-axis with bold lines and ticks
axis(1, lwd=20, lwd.ticks=20, col.axis='black', font=2)
axis(2, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Invert y-axis tick numbering on the right side
#y_ticks <- pretty(range(ROCperf@y.values[[1]]))  # Get pretty tick marks
#axis(4, at=y_ticks, labels=y_ticks, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Draw the box with bold lines
box(lwd=20)
# Bold title
title(main=paste("Training data | Area under curve =", Trainingarea), font.main=2, cex.main=1.65)
dev.off()


png(filename = paste(PLOTaddr,'TrainingData_Accuracy.png'), width = 23*sz,height = 20*sz, pointsize = 100)
accuperf = ROCR::performance(ROCpred, measure="acc")
ROCR::plot(accuperf, lwd=20, cex.lab=1.3, font.lab=2)
# Draw x-axis with bold lines and ticks
axis(1, lwd=20, lwd.ticks=20, col.axis='black', font=2)
axis(2, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Draw the box with bold lines
box(lwd=20)
dev.off()

png(filename = paste(PLOTaddr,'TestData_ROC.png'), width = 23*sz,height = 20*sz, pointsize = 100)
ROCR::plot(ROCvalperf, avg="threshold", spread.estimate="boxplot", colorize=TRUE, lwd=20, cex.lab=1.3, font.lab=2)
abline(a=0, b=1)
# Draw x-axis with bold lines and ticks
axis(1, lwd=20, lwd.ticks=20, col.axis='black', font=2)
axis(2, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Invert y-axis tick numbering on the right side
#y_ticks <- pretty(range(ROCperf@y.values[[1]]))  # Get pretty tick marks
#axis(4, at=y_ticks, labels=y_ticks, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Draw the box with bold lines
box(lwd=20)
# Bold title
title(main=paste("Test data | Area under curve =", Trainingarea), font.main=2, cex.main=1.7)
dev.off()

png(filename = paste(PLOTaddr,'TestData_Accuracy.png'), width = 23*sz,height = 20*sz, pointsize = 100)
valaccuperf = ROCR::performance(ROCvalpred, measure="acc")
ROCR::plot(valaccuperf, lwd=20, cex.lab=1.3, font.lab=2)
# Draw x-axis with bold lines and ticks
axis(1, lwd=20, lwd.ticks=20, col.axis='black', font=2)
axis(2, lwd=20, lwd.ticks=20, col.axis='black', font=2)
# Draw the box with bold lines
box(lwd=20)
dev.off()


#par(pty='s', lwd=20, font.axis = 10, font.lab = 10, mar=c(5, 5, 4, 2) + 0.1)

ROCpal = palette.colors(palette = "ggplot2", n = length(libs_SL_CV)+1)
TrainAUCs <- as.vector(0)

par(lwd=20, mar = c(5, 4, 4, 2) + 0.1, font.axis = 2, font.lab = 2)

png(filename = paste(PLOTaddr,'TrainingData_AUC.png'), width = 23*sz,height = 20*sz, pointsize = 100)
plot(pROC::roc(Training_len, rowMeans(preds),direction="<"), col="black", cex.lab = 1.7, lwd = 20, font.lab=2, cex.axis = 1.2, font=2, lwd.ticks=20, col.axis='black') #system for training ROCs
for(j in 1:length(libs_SL_CV)) {
  temproc <- pROC::roc(Training_len,rowMeans(algopreds[,,j]),direction="<")
  ROC_val<-plot(temproc, print.auc = FALSE, print.auc.y = (0.1 * j), add = TRUE, col=ROCpal[j+1], lwd=15, cex.lab=1.3, font.lab=2, cex.axis = 1.7)
  TrainAUCs[[j]] = pROC::auc(temproc)
}
ROC_val<-plot(pROC::roc(Training_len,rowMeans(preds),direction="<"), print.auc = FALSE, print.auc.y = 0.1*(length(libs_SL_CV)+1), add=TRUE, col="black", lwd=15, cex.lab=1.3, font.lab=2, cex.axis = 1.7)
#legend(x = .53, y =0.44, legend = paste(c("Combined SL", libs_SL_CV),", AUC = ",signif(c(Trainingarea,TrainAUCs), 4),sep=""), col = ROCpal, lwd = 30, cex = 1, text.font = 2, bty = "n")
# Legend settings
legend_text <- paste(c("Combined SL", libs_SL_CV), ", AUC = ", signif(c(Trainingarea, TrainAUCs), 4), sep = "")
legend_y <- 0.05 + 0.041 * (length(libs_SL_CV) + 1)
legend(x = 0.53, y = legend_y, legend = legend_text, col = ROCpal, lwd = 30, cex = 1, text.font = 2, bty = "n")   # set manually the position of the legend here
# Draw thick border around legend box, set manually here the position of the box around the legend
rect_x <- 0.52
rect_y_bottom <- legend_y - 0.043 * (length(libs_SL_CV) + 2)
rect(0.52, rect_y_bottom, -0.1, legend_y,
     border = "black", lwd = 15)
#rect(0.52, 0.0, -0.1, 0.43,
#     border = "black", lwd = 15)
# Draw thick borders around the plot
rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], border = "black", lwd = 35)
dev.off()

TestAUCs <- as.vector(0)
png(filename = paste(PLOTaddr,'TestData_AUC.png'), width = 23*sz,height = 20*sz, pointsize = 100)
#ROC_val<-plot(pROC::roc(Test_len,rowMeans(Testpreds),direction="<"), col="black") # Test ROCs
plot(pROC::roc(Test_len,rowMeans(Testpreds),direction="<"), col="black", cex.lab = 1.7, lwd = 20, font.lab=2, cex.axis = 1.2, font=2, lwd.ticks=20, col.axis='black') # Test ROCs
for(j in 1:length(libs_SL_CV)) {
  temproc1 <- pROC::roc(Test_len,rowMeans(Valalgopreds[,,j]),direction="<")
  ROC_val<-plot(temproc1, print.auc = FALSE, print.auc.y = (0.1 * j), add = TRUE, col=ROCpal[j+1], lwd=15)
  TestAUCs[[j]] = pROC::auc(temproc1)
}
#for(j in 1:length(libs_SL_CV)) {
#  ROC_val<-plot(pROC::roc(Test_len,rowMeans(Valalgopreds[,,j]),direction="<"), print.auc = TRUE, print.auc.y = (0.1 * j), add = TRUE, col=ROCpal[j+1], lwd=15)
#}
ROC_val<-plot(pROC::roc(Test_len,rowMeans(Valalgopreds),direction="<"), print.auc = FALSE, print.auc.y = 0.1*(length(libs_SL_CV)+1), add=TRUE, col="black", lwd=15, cex.lab=1.3, font.lab=2, cex.axis = 1.7)
#legend(x = .6, y = .62, legend = paste(c("Combined SL", libs_SL_CV),", AUC = ",signif(c(Testarea,TestAUCs), 4),sep=""), col = ROCpal, lwd=15, cex.lab=1.3, font.lab=2, cex.axis = 1.7)
legend_text <- paste(c("Combined SL", libs_SL_CV), ", AUC = ", signif(c(Testarea,TestAUCs), 4), sep = "")
legend_y <- 0.05 + 0.041 * (length(libs_SL_CV) + 1)
legend(x = 0.53, y = legend_y, legend = legend_text, col = ROCpal, lwd = 30, cex = 1, text.font = 2, bty = "n")   # set manually the position of the legend here
#ROC_val<-plot(pROC::roc(Test_len, rowMeans(Testpreds),direction="<"), print.auc = TRUE, print.auc.y = 0.1*(length(libs_SL_CV)+1), add=TRUE, col="black", lwd=15)
#ROC_val
# Draw thick border around legend box, set manually here the position of the box around the legend
rect_x <- 0.52
rect_y_bottom <- legend_y - 0.043 * (length(libs_SL_CV) + 2)
rect(rect_x, rect_y_bottom, -0.1, legend_y,
     border = "black", lwd = 15)
#rect(0.52, 0.0, -0.1, 0.43,
#     border = "black", lwd = 15)
# Draw thick borders around the plot
rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], border = "black", lwd = 35)
dev.off()


png(filename = paste(PLOTaddr,'TrainingData Precision-Recall.png'),width = 3*sz,height = 2.5*sz)
precrec = ROCR::performance(ROCpred,"prec","rec")
ROCR::plot(precrec, main="Precision/Recall | Training data")
dev.off()

png(filename = paste(PLOTaddr,'TestData Precision-Recall.png'),width = 3*sz,height = 2.5*sz)
valprecrec = ROCR::performance(ROCvalpred, "prec","rec")
ROCR::plot(valprecrec, main="Precision/Recall | Test data")
dev.off()
