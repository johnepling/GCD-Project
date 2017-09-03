### Course Project

## packages
library(tidyverse)
library(data.table)
library(dplyr)
library(reshape2)
library(stringr)

## download and unzip data

fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "dataset.zip", method = "curl")
unzip("dataset.zip")

## create and merge datasets

# Train
xtrcols <- read_table2("UCI HAR Dataset/features.txt", col_names = FALSE)
xtr <- read_table("UCI HAR Dataset/train/X_train.txt", col_names = xtrcols$X2)

ytr <- read_table("UCI HAR Dataset/train/y_train.txt", col_names = "Activity")
ytr$Activity <- recode(ytr$Activity, '1' = "Walk", '2' = "WalkUp", '3' = "WalkDown", '4' = "Sit", '5' = "Stand", '6' = "Lay")

subjtr <- read_table("UCI HAR Dataset/train/subject_train.txt", col_names = "Subject")

trdata <- cbind(subjtr, ytr, xtr)
head(trdata)

# Test
xtscols <- read_table2("UCI HAR Dataset/features.txt", col_names = FALSE)
xts <- read_table("UCI HAR Dataset/test/X_test.txt", col_names = xtscols$X2)

yts <- read_table("UCI HAR Dataset/test/y_test.txt", col_names = "Activity")
yts$Activity <- recode(yts$Activity, '1' = "Walk", '2' = "WalkUp", '3' = "WalkDown", '4' = "Sit", '5' = "Stand", '6' = "Lay")

subjts <- read_table("UCI HAR Dataset/test/subject_test.txt", col_names = "Subject")

tsdata <- cbind(subjts, yts, xts)
head(tsdata)

# Combine Train and Test
combdata <- rbind(trdata, tsdata)
head(combdata)

# extract mean and stdev for each measurement - not getting MeanFreq or angle() measurements using means
ecdata <- select(combdata, Subject, Activity, matches(".-(mean|std)."), -matches(".meanFreq."))
labels <- colnames(ecdata)
labels <- gsub("\\(\\)", "", labels)
colnames(ecdata) <- labels

# create another tidy dataframe with means for each variable by subject and activity

bothmeans <- ecdata %>% group_by(Activity, Subject) %>% summarize_all(funs(mean))

# save the dataset
write.table(bothmeans, "td-meansbysubjnact.txt", na = "NA", row.names = FALSE)
