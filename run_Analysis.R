## Set working directory
setwd("./Users/tmoniz/datasciencecoursera/GettingandCleaningData/Course Project/UCI Har Dataset")


##Checking for and creating directory titled:wearable_data
if (!file.exists("UCI Har Dataset")) {
  dir.create("UCI Har Dataset")
}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./UCI Har Dataset/wearable_data.csv", 
              method="curl")
list.files("./UCI Har Dataset")

## Read Data -- General
features<-read.table('./features.txt',header=FALSE)
activity_labels<-read.table('./activity_labels.txt',header=FALSE)

## Give column names
colnames(activity_labels)=c("activityID","typeActivity")

##Read Data -- Train
subject_train<-read.table('./train/subject_train.txt',header=FALSE)
y_train<-read.table('./train/y_train.txt',header=FALSE)
x_train<-read.table('./train/x_train.txt',header=FALSE)

## Give column names
colnames(subject_train) = "SubjectID"
colnames(y_train) = "activityID"
colnames(x_train) = "features[,2]"

##merge all "training" files to create one data set called Data_train
Data_train<-cbind(subject_train,y_train,x_train)

## Repeat previous steps for the Test Data Files
## Read Data -- Test
subject_test<-read.table('./test/subject_test.txt',header=FALSE)
y_test<-read.table('./test/y_test/txt',header=FALSE)
x_test<-read.table('./test/x_test/txt',header=FALSE)

## Give column names
colnames(subject_test) = "SubjectID"
colnames(y_test) = "activityID"
colnames(x_test) = features[,2]

##merge all "test" files to create one data set called Data_test
Data_test<-cbind(subject_test,y_test,x_test)

##then merge the two "Data_train" and "Data_test" files to create a merged file
merged_file<-rbind(Data_train,Data_test)

## Give column names to merged_file
colNames=colnames(merged_file)

##Get measurements on mean and std. dev of the original measurements
logicalVector = (grepl("activity..",colNames) | grepl("subject..",colNames) | 
                grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | 
                grepl("-std..",colNames) & !grepl("-std()..-",colNames))

merged_file <- merged_file[logicalVector==TRUE]

## add column names from Activity data set
merged_file <- merge(merged_file,activity_labels,by='activityID', all.x=TRUE)
colNames = colnames(merged_file)

for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
  colNames[i] = gsub("^(t)","time",colNames[i])
  colNames[i] = gsub("^(f)","freq",colNames[i])
  colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
}

colnames(merged_file) = colNames

##Create a new tidy data set using past steps
final_data <- merged_file[,names(merged_file) != 'activity_labels']

final_tidy <- aggregate(final_data[,names(final_data) != c('activityID','subjectID')],by=list(activityID=final_data$activityID,subjectID = final_data$subjectID),mean)

final_tidy <- merge(tidyData,activity_labels,by='activityID',all.x=TRUE)

##Export Tidy Data
write.table(final_tidy,'./final_tidy.txt',row.names=TRUE,sep='\t')




