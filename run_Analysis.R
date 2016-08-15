library(plyr)
setwd("~/datasciencecoursera/2GettingandCleaningData/Course Project")

##Access data and download file
if(!file.exists("./Project_Dataset")) {
  dir.create("./Project_Dataset")
}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./Project_Dataset/dataset.zip", method="curl")
##Unzip File
unzip(zipfile = "./Project_Dataset/dataset.zip", exdir="./Project_Dataset")
list.files("./Project_Dataset")

##Read Data from all data sets 
##Train Data
x_train <- read.table("./Project_Dataset/UCI Har Dataset/train/X_train.txt")
y_train <- read.table("./Project_Dataset/UCI Har Dataset/train/y_train.txt")
subject_train <- read.table("./Project_Dataset/UCI Har Dataset/train/subject_train.txt")
##Test Data
x_test <- read.table("./Project_Dataset/UCI Har Dataset/test/X_test.txt")
y_test <- read.table("./Project_Dataset/UCI Har Dataset/test/y_test.txt")
subject_test <- read.table("./Project_Dataset/UCI Har Dataset/test/subject_test.txt")

##Read data from supporting files
features <- read.table('./Project_Dataset/UCI HAR Dataset/features.txt')
activityLabels = read.table('./Project_Dataset/UCI HAR Dataset/activity_labels.txt')

##give column names
colnames(x_train) <- features[,2]
colnames(y_train) <- "activityID"
colnames(subject_train) <- "SubjectID"
colnames(x_test) <- features[,2]
colnames(y_test) <- "activityID"
colnames(subject_test) <- "SubjectID"
colnames(activityLabels) <-c('activityID','activityType')

##Combine all data into one set
##train merge and test merge
Data_train<-cbind (y_train,subject_train,x_train)
Data_test<-cbind (y_test,subject_test,x_test)
##Merge both together
Merge_Data <- rbind(Data_train,Data_test)
## Set Column names for merged file
colNames <- colnames(Merge_Data)


##Get measurements on mean and std. dev of original measurements
mean_std <- (grepl("activityID", colNames) | 
                    grepl("SubjectID", colNames) | 
                    grepl("mean..", colNames) | 
                    grepl("std..", colNames)
            )
subset_mean <- Merge_Data[ , mean_std == TRUE]
give_names <- merge(subset_mean, activityLabels, by='activityID', all.x=TRUE)

##Final step, combine into tidy data set
tidy_data <- aggregate(. ~SubjectID + activityID, give_names, mean)
tidy_data <- tidy_data[order(tidy_data$SubjectID, tidy_data$activityID), ]
write.table(tidy_data,"tidy_data.txt", row.name=FALSE)


