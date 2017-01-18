# Peer-graded Assignment: Getting and Cleaning Data Course Project

## Load packages
library(tidyverse)

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
