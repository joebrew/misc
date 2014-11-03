myinfo <- 
  list(
    Name="SHARC Research Assistants: Jane Ritho, Tyrone Wizzard", 
    Current="CURRENT PROJECTS",
    Projects=data.frame(
      Projects=c("WHAT_IF CLINICAL TRIAL", "MMP SURVEILLANCE STUDY", 
                  "FLORIDA COHORT SURVEY")),
    office="CTRB 4206", 
    phone ="352-872-9534",
    email ="jnr5443@ufl.edu")
myinfo

cat("\n\n***TEST PROGRAM TO READ CONCURRENT MEDICATION LIST DATA***\n")


############
#Set Data Folder
############
if ( Sys.info()["sysname"] == "Linux" ){
  setwd("/home/joebrew/Documents/misc/jane_ritho") } else if(
    Sys.info()["user"] == "BrewJR"){
    setwd("C:/Users/BrewJR/Documents/misc/jane_ritho")
  }else {
    setwd("C:\\Users\\jnr5443\\Documents\\Fall2014\\SHARC\\Projects\\what_if\\Committent_meds\\Committent_meds\\")
  }


############
# READ IN ALL DATA INTO LISTS
############
require(gdata)
temp = list.files(pattern="*.xlsx")
myfiles = lapply(temp, read.xls, skip=5)
my_ids <- lapply(temp, read.xls, skip=1)

############
#ADD ID COLUMN
############
for (i in 1:length(myfiles)){
  myfiles[[i]]$id <- 
    as.numeric(as.character(my_ids[[i]]$X.6))[1]
}
rm(my_ids, temp)

############
# RBIND ALL ELEMENTS OF THE MYFILES LIST INTO ONE DF
############
require(plyr)
raw.dat <- rbind.fill(myfiles) 
raw.dat

# remove rows with NA for drug name
raw.dat <- raw.dat[which(!is.na(raw.dat$Drug.Name)),]
# also remove rows with empty drug name
raw.dat <- raw.dat[which(raw.dat$Drug.Name != ""),]

##########
# WRITE RAW DATA TO A SCV
##########
write.csv(raw.dat, 
            file=paste0(getwd(), "/WHAT_IF_Raw.csv"), 
            row.names = FALSE)

