### Peer-graded Assignment: Getting and Cleaning Data Course Project

# ================================================================== Human
# Activity Recognition Using Smartphones Dataset Version 1.0 
# ================================================================== Jorge L.
# Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto. Smartlab - Non
# Linear Complex Systems Laboratory DITEN - Università degli Studi di Genova. 
# Via Opera Pia 11A, I-16145, Genoa, Italy. activityrecognition@smartlab.ws 
# www.smartlab.ws 
# ==================================================================
# 
# The experiments have been carried out with a group of 30 volunteers within an
# age bracket of 19-48 years. Each person performed six activities (WALKING,
# WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a
# smartphone (Samsung Galaxy S II) on the waist. Using its embedded
# accelerometer and gyroscope, we captured 3-axial linear acceleration and
# 3-axial angular velocity at a constant rate of 50Hz. The experiments have been
# video-recorded to label the data manually. The obtained dataset has been
# randomly partitioned into two sets, where 70% of the volunteers was selected
# for generating the training data and 30% the test data.
# 
# The sensor signals (accelerometer and gyroscope) were pre-processed by
# applying noise filters and then sampled in fixed-width sliding windows of 2.56
# sec and 50% overlap (128 readings/window). The sensor acceleration signal,
# which has gravitational and body motion components, was separated using a
# Butterworth low-pass filter into body acceleration and gravity. The
# gravitational force is assumed to have only low frequency components,
# therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a
# vector of features was obtained by calculating variables from the time and
# frequency domain. See 'features_info.txt' for more details.
# 
# For each record it is provided: 
# ======================================
# 
# - Triaxial acceleration from the accelerometer (total acceleration) and the
# estimated body acceleration. 
# - Triaxial Angular velocity from the gyroscope. 
# - A 561-feature vector with time and frequency domain variables. 
# - Its activity label. 
# - An identifier of the subject who carried out the experiment.

### Load packages
library(tidyverse)

### Download and unzip data
location <- "H:/Kurse/DataScience/DCleaning/Week4/data/UCI HAR Dataset"
setwd(location)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")


# Read subject files
subTrain <- tbl_df(read.table(file.path(location, "train", "subject_train.txt")))
subTest  <- tbl_df(read.table(file.path(location, "test" , "subject_test.txt" )))

# Read activity files
activityTrain <- tbl_df(read.table(file.path(location, "train", "Y_train.txt")))
activityTest  <- tbl_df(read.table(file.path(location, "test" , "Y_test.txt" )))

# Read data files
dataTrain <- tbl_df(read.table(file.path(location, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(location, "test" , "X_test.txt" )))

# 1. Merge the training and the test sets to create one data set.

# Merge training and test data for subjects and activity and rename
subdataAll <- rbind(subTrain, subTest)
subdataAll <- rename(subdataAll, subject = V1)
acdataAll <- rbind(activityTrain, activityTest)
acdataAll <- rename(acdataAll, activityType = V1)

# Merge training and test data and rename variables based on feature
dataMerge <- rbind(dataTrain, dataTest)
Features <- tbl_df(read.table(file.path(location, "features.txt")))
Features <- rename(Features, Number = V1, trackedVariable = V2)
colnames(dataMerge) <- Features$trackedVariable

# Merge to full data set 
subjectActivityAll <- cbind(subdataAll, acdataAll)
dataMerge <- cbind(subjectActivityAll, dataMerge)

# 2. Extract only the measurements on the mean and standard deviation for each measurement.

dataMeasureMean <- grep("mean\\(\\)|std\\(\\)", Features$trackedVariable, value=TRUE) 
dataMeasureMean <- union(c("subject","activityType"), dataMeasureMean)
dataMerge <- subset(dataMerge, select = dataMeasureMean)

# 3. Uses descriptive activity names to name the activities in the data set.

labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)
dataMerge$activityType <- labels[dataMerge$activityType, 2]

# 4. Appropriately labels the data set with descriptive variable names

# remove non-alphanumeric symbols
# Improve visiblity of mean and std by capital letters

names(dataMerge) <- gsub("[^[:alnum:]]", "", names(dataMerge))
names(dataMerge) <- gsub ("std", "SD", names(dataMerge))
names(dataMerge) <- gsub ("mean", "Mean", names(dataMerge))
head(str(dataMerge),2)


# 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each 
#    activity and each subject.

# Beginning from the third column calculate means for each subject and activity
aggregatedData <- aggregate(dataMerge[, 3:ncol(dataMerge)],
                       by=list(subject = dataMerge$subject, 
                               activityType = dataMerge$activityType),
                       mean)

# create txt file
write.table(aggregatedData, file = "Tidy.txt", row.names = FALSE)
