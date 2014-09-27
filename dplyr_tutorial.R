# From http://www.youtube.com/watch?v=jWjqLW-u3hc&feature=youtu.be

# load packages
library(dplyr)
library(hflights)

# explore data
data(hflights)
head(hflights)

# convert to local dataframe
flights <- tbl_df(hflights)

# printing only shows 10 rows and as many columns can fit on your screen
flights # with local data frames, defaults to 10 rows
print(flights, n = 30)

# for regular data frame print out
data.frame(head(flights))

## FILTERING

# base R approach to filtering rows
flights[flights$Month == 1 & flights$DayofMonth == 1, ]

# dplyr approach - nothing is modified in place - if i want modification, use assig operator
filter(flights, Month == 1, DayofMonth == 1) # you can use & instead of , also

# use pipe for or condition
filter(flights, UniqueCarrier == "AA" | UniqueCarrier == "UA")

# you can also use %in% operator
filter(flights, UniqueCarrier %in% c("AA", "UA"))


## SELECTING
# (picking columns by name)

# base R approach to selecting columns
flights[,c("DepTime", "ArrTime", "FlightNum")]

# dplyr approach (same syntax as filter command)
select(flights, DepTime, ArrTime, FlightNum)

# fancier things: use columns between year and day of month as well as any column containing "taxi" or "delay"
select(flights, Year:DayofMonth, contains("Taxi", contains("Delay")))
# (one can also use things like starts_with, ends_with, and matches [regex])

## CHAINING
# (this isn't dplyr, but is how we should write dplyr code)

# base R approach to selecting and filtering
filter(select(flights, UniqueCarrier, DepDelay), DepDelay > 60)

# chaining approach (comes from magrittr, imported into dplyr)
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  filter(DepDelay > 60) 
# read outloud the chain operator as "then," as in a sequential "then do this"

# using chaining outside of dplyr

# base r method
x1 <- 1:5; x2 <- 2:6
sqrt(sum((x1-x2)^2))

# chain method
(x1-x2)^2 %>% sum() %>% sqrt()


## ARRANGE (reordering or rows)

# base r approach to select UniqueCarrier and DepDelay columns and sort by DepDelay
flights[order(flights$DepDelay), c("UniqueCarrier", "DepDelay")]

# dplyr approach
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(DepDelay)

# use 'desc' for descending
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay))


# MUTATE (add new variables)

# base r approach to adding new variables
flights$Speed <- flights$Distance / flights$AirTime*60
flights[, c("Distance", "AirTime", "Speed")]

# dplyr approach (prints new variable but does not store it)
flights %>%
  select(Distance, AirTime) %>%
  mutate(Speed = Distance / AirTime * 60)

# store the new variable
flights <- flights %>% mutate(Speed = Distance / AirTime * 60)


## SUMMARISE: reduce variables to values
# group_by = creates groups that will be operated on
# summarize = uses the provided aggregation function to summarise each group

# base r approach to calculate average arrival delay to each destination
head(with(flights, tapply(ArrDelay, Dest, mean, na.rm = TRUE)))
head(aggregate(ArrDelay ~ Dest, flights, mean))

# dplyr approach :
# create a table grouped by destination, and then summarise each group by taking 
# the mean of ArrDelay (average delay)
flights %>% 
  group_by(Dest) %>%
  summarise(avg_delay = mean(ArrDelay, na.rm=TRUE))

# summarise_each: allows you to apply the same summary function to multiple columns at once
# (you can also do mutate_each)

# for each carrier, calculate the percentage of flights cancelled or diverted
# (whenver you see the words "for each" think "group_by")
flights %>% 
  group_by(UniqueCarrier) %>%
  summarise_each(funs(mean), Cancelled, Diverted) 
#funs works like this = funs(functions I want to run)
#Cancelled and Diverted are 0 and 1 columns, so this makes it easy

# for each carrier, calculate the minimum and maxiumum arrival and departure delays
flights %>%
  group_by(UniqueCarrier) %>% # group by carrier
  summarise_each(funs(min(., na.rm = TRUE), max(., na.rm = TRUE)), # for each carrier, calculate min and max arr and dep delays
                 matches("Delay")) # match any columns with the word delay in it
# the . is just a placeholder for the data you're passing in

# Some helper functions:
# n() = counts number of rows in a group
# n_distinct() = counts number of unique items in a vector

# For each day of the year, count total number of flights and sort in descending order
flights %>%
  group_by(Month, DayofMonth) %>%
  summarise(flight_count = n()) %>%
  arrange(desc(flight_count))

# rewrite more simply with the tally() function
flights %>% 
  group_by(Month, DayofMonth) %>%
  tally(sort = TRUE)
# basically did same as above, but using tally, you can't define column name...

# for each destination, count the total number of flights and the
# number of distinct planes that flew there
flights %>%
  group_by(Dest) %>%
  summarise(flight_count = n(), plane_count = n_distinct(TailNum))

# Grouping can sometimes be useful without summarising

# for each desination show the number of cancelled/ not cancelled flights
flights %>%
  group_by(Dest) %>%
  select(Cancelled) %>%
  table() %>%
  head()

## WINDOW FUNCTIONS
# Aggregation function (like 'mean') takes n inputs and returns 1 value
# Window functions, on the other hand, take n inputs and returns n values
# (this includes ranking and ordering functions (like 'min_rank'),
# offset functions ('lead' and 'lag'), and cumulative aggregates ('cum_mean'))
# think of window functions like rank: you give ten numbers, you rank, and then you get 10 back


# For each carrier, calculate which 2 days of the year they had
# their longest departure delays
# (note: smallest (not largest) value is ranked as 1, so you have to use
# 'desc' to rank by largest value)

flights %>% 
  group_by(UniqueCarrier) %>%
  select(Month, DayofMonth, DepDelay) %>%
  filter(min_rank(desc(DepDelay)) <= 2) %>%
  arrange(UniqueCarrier, desc(DepDelay))

# rewrite more simly with the top_n function
flights %>%
  group_by(UniqueCarrier) %>%
  select(Month, DayofMonth, DepDelay) %>%
  top_n(2) %>%
  arrange(UniqueCarrier, desc(DepDelay))

# for each month, calculate the number of flights and the change from the previous month
flights %>%
  group_by(Month) %>%
  summarise(flight_count = n()) %>%
  mutate(change = flight_count - lag(flight_count))
#lag: looks at prevoius value
# lead: looks at next value

# rewrite more simply with the `tally` function
flights %>%
  group_by(Month) %>%
  tally() %>%
  mutate(change = n - lag(n))


## OTHER USEFUL CONVENIENCE FUNCTIONS

# randomly sample a fixed number of rows, without replacement
flights %>% sample_n(5)
  
# randomly sample a fraction of rows, with replacement
flights %>% sample_frac(0.25, replace=TRUE)

# base R approach to view the structure of an object
str(flights)

# dplyr approach: better formatting, and adapts to your screen width
glimpse(flights)


## CONNECTING TO DATABASES

# connect to an SQLite database containing the hflights data
my_db <- src_sqlite("my_db.sqlite3")

# connect to the "hflights" table in that database
flights_tbl <- tbl(my_db, "hflights")

# example query with our data frame
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay))

# identical query using the database
flights_tbl %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay))

# send SQL commands to the database
tbl(my_db, sql("SELECT * FROM hflights LIMIT 100"))

# ask dplyr for the SQL commands
flights_tbl %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay)) %>%
  explain()