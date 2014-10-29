library(gdata)

############
#Set Data Folder
############
if ( Sys.info()["sysname"] == "Linux" ){
  setwd("/home/joebrew/Documents/misc/jane_ritho") } else {
    setwd("C:\\Users\\jnr5443\\Committent_meds")
  }

############
# READ IN ALL DATA INTO LIST
############
temp = list.files(pattern="*.xlsx")
myfiles = lapply(temp, read.xls, skip=5)

############
# RBIND ALL ELEMENTS OF THE MYFILES LIST INTO ONE DF
############
library(plyr)
raw.dat <- rbind.fill(myfiles)

