library(tidyr)
library(dplyr)

# << link of our dataset >>
filetodownload <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# << create data directory (if it doesn't exist) >>
if(!file.exists("./data")){dir.create("./data")}

# << download zip file and extract it to the same data directory >>
download.file(filetodownload, destfile = "./data/entireDataSet.zip",method = "curl")
unzip("./data/entireDataSet.zip", exdir = "./data")

# << read train data >>
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# << read test data >>
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# << merge data (test & train) >>
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# << read feature names and assign them to x_data >>
features <- read.table("./data/UCI HAR Dataset/features.txt")
colnames(x_data) <- as.character(features[,2])

# << select data with mean or std as colname >>
mean_std_data <- x_data[grep("-(std|mean).*", names(x_data), ignore.case=T)]

# << read activity labels>>
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# << merge y_data with activity_labels and rename it>>
y_data <- merge(y_data, activity_labels)
colnames(y_data) <- c("y_value","Activity")

# << add Activity Data & Subject data to filtered (mean|std) data >>
finalData <- cbind(subject_data,y_data$Activity,mean_std_data)
colnames(finalData)[1:2] <- c("Subject", "Activity")
finalData$Subject <- as.factor(finalData$Subject)
finalData$Activity <- as.factor(finalData$Activity)

# << get each variable average per activity per subject and save it to a new table/file >>
secondData <- finalData %>% 
  group_by(Subject, Activity) %>%
  summarise_all("mean")

write.table(secondData, "./second_dataset.txt", row.names = FALSE, quote = FALSE)