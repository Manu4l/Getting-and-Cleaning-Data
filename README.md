# Peer-graded Assignment: Getting and Cleaning Data Course Project

This repo contains four files:

* README.md - gives an overview over this repo and the used code
* CodeBook.rmd - includes information regarding the data set and the code
* run_analysis.R - the actual r file
* Tidy.txt - the actual cleaned and tidied data set as TXT file
* Tidy.csv - the cleaned and tidied data set as CSV file (looks cleaner than TXT)

## Actual tasks

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

You should create one R script called run_analysis.R that does the following.

   1. Merges the training and the test sets to create one data set.
   2. Extracts only the measurements on the mean and standard deviation for each measurement.
   3. Uses descriptive activity names to name the activities in the data set
   4. Appropriately labels the data set with descriptive variable names.
   5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each     activity and each subject.
   
## Approach

1. Download data
2. Unzip data
3. Start merging data
4. Start cleaning data
5. Summarize data
6. Create Repo including all required files

#Scripts are how they are connected

## Download and unzip data
```
location <- "H:/Kurse/DataScience/DCleaning/Week4/data/UCI HAR Dataset"
setwd(location)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
```

Read subject files
```
subTrain <- tbl_df(read.table(file.path(location, "train", "subject_train.txt")))
subTest  <- tbl_df(read.table(file.path(location, "test" , "subject_test.txt" )))
```
Read activity files
```
activityTrain <- tbl_df(read.table(file.path(location, "train", "Y_train.txt")))
activityTest  <- tbl_df(read.table(file.path(location, "test" , "Y_test.txt" )))
```
Read data files
```
dataTrain <- tbl_df(read.table(file.path(location, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(location, "test" , "X_test.txt" )))
```
## 1. Merge the training and the test sets to create one data set.

Merge training and test data for subjects and activity and rename
```
subdataAll <- rbind(subTrain, subTest)
subdataAll <- rename(subdataAll, subject = V1)
acdataAll <- rbind(activityTrain, activityTest)
acdataAll <- rename(acdataAll, activityType = V1)
```
Merge training and test data and rename variables based on feature
```
dataMerge <- rbind(dataTrain, dataTest)
Features <- tbl_df(read.table(file.path(location, "features.txt")))
Features <- rename(Features, Number = V1, trackedVariable = V2)
colnames(dataMerge) <- Features$trackedVariable
```
Merge to full data set 
```
subjectActivityAll <- cbind(subdataAll, acdataAll)
dataMerge <- cbind(subjectActivityAll, dataMerge)
```
## 2. Extract only the measurements on the mean and standard deviation for each measurement.
```
dataMeasureMean <- grep("mean\\(\\)|std\\(\\)", Features$trackedVariable, value=TRUE) 
dataMeasureMean <- union(c("subject","activityType"), dataMeasureMean)
dataMerge <- subset(dataMerge, select = dataMeasureMean)
```
## 3. Use descriptive activity names to name the activities in the data set.
```
labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)
dataMerge$activityType <- labels[dataMerge$activityType, 2]
```
## 4. Appropriately label the data set with descriptive variable names

Remove non-alphanumeric symbols.
Improve visiblity of mean and std by capital letters.
```
names(dataMerge) <- gsub("[^[:alnum:]]", "", names(dataMerge))
names(dataMerge) <- gsub ("std", "SD", names(dataMerge))
names(dataMerge) <- gsub ("mean", "Mean", names(dataMerge))
head(str(dataMerge),2)
```
## 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

Beginning from the third column calculate means for each subject and activity.
```
aggregatedData <- aggregate(dataMerge[, 3:ncol(dataMerge)],
                       by=list(subject = dataMerge$subject, 
                               activityType = dataMerge$activityType),
                       mean)
