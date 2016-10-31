# Clears all varibles in memory, makes wd if it does not exists, sets
# WD, and then loads requied libraries 
rm(list=ls())
if(!file.exists("c:\\wd\\data")){dir.create("c:\\wd\\data")}
setwd("c:\\wd\\data")
library(data.table)
library(dplyr)

# Load all project data
feat <- read.table("c:\\wd\\data\\features.txt")
actlab <- read.table("c:\\wd\\data\\activity_labels.txt", header = FALSE)
subtrain <- read.table("c:\\wd\\data\\subject_train.txt", header = FALSE)
acttrain <- read.table("c:\\wd\\data\\y_train.txt", header = FALSE)
feattrain <- read.table("c:\\wd\\data\\X_train.txt", header = FALSE)
subtest <- read.table("c:\\wd\\data\\subject_test.txt", header = FALSE)
acttest <- read.table("c:\\wd\\data\\y_test.txt", header = FALSE)
feattest <- read.table("c:\\wd\\data\\X_test.txt", header = FALSE)

# Combine datasets
subject <- rbind(subtrain, subtest)
activity <- rbind(acttrain, acttest)
features <- rbind(feattrain, feattest)

# Name colmns
colnames(features) <- t(feat[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
completeData <- cbind(features,activity,subject)

# Establish mean and std functions, and keep those
mscols <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)
colms <- c(mscols, 562, 563)

# Establish selected columns
reqcols <- completeData[,colms]

# Rename to include descriptive names
reqcols$Activity <- as.character(reqcols$Activity)
for (i in 1:6){
  reqcols$Activity[reqcols$Activity == i] <- as.character(actlab[i,2])
}
# Factor activity varible again when names are changed
reqcols$Activity <- as.factor(reqcols$Activity)
names(reqcols)<-gsub("Acc", "Accelerometer", names(reqcols))
names(reqcols)<-gsub("Gyro", "Gyroscope", names(reqcols))
names(reqcols)<-gsub("BodyBody", "Body", names(reqcols))
names(reqcols)<-gsub("Mag", "Magnitude", names(reqcols))
names(reqcols)<-gsub("^t", "Time", names(reqcols))
names(reqcols)<-gsub("^f", "Frequency", names(reqcols))
names(reqcols)<-gsub("tBody", "TimeBody", names(reqcols))
names(reqcols)<-gsub("-mean()", "Mean", names(reqcols), ignore.case = TRUE)
names(reqcols)<-gsub("-std()", "STD", names(reqcols), ignore.case = TRUE)
names(reqcols)<-gsub("-freq()", "Frequency", names(reqcols), ignore.case = TRUE)
names(reqcols)<-gsub("angle", "Angle", names(reqcols))
names(reqcols)<-gsub("gravity", "Gravity", names(reqcols))

# Subject as factor 
reqcols$Subject <- as.factor(reqcols$Subject)
reqcols <- data.table(reqcols)
# Make a independent tidy data set
td <- aggregate(. ~Subject + Activity, reqcols, mean)
td <- td[order(td$Subject,td$Activity),]
# Output txt file
write.table(td, file = "TidyData.txt", row.names = FALSE)
