## Importing libraries required for the project

library(tidyverse)
library(lubridate)
library(ggplot2)



## Setting working directory

setwd("C:/Users/Saurabh/Downloads/Google Capstone Case Study 1")



## Collecting Data

q1_2020 <- read_csv("Divvy_Trips_2020_Q1.csv")
q2_2019 <- read_csv("Divvy_Trips_2019_Q2.csv")
q3_2019 <- read_csv("Divvy_Trips_2019_Q3.csv")
q4_2019 <- read_csv("Divvy_Trips_2019_Q4.csv")



## Checking and comparing column names

colnames(q1_2020)
colnames(q2_2019)
colnames(q3_2019)
colnames(q4_2019)



## Renaming columns to those in q1_2020

q2_2019 <- rename(q2_2019
                  ,ride_id = "01 - Rental Details Rental ID"
                  ,rideable_type = "01 - Rental Details Bike ID" 
                  ,started_at = "01 - Rental Details Local Start Time"  
                  ,ended_at = "01 - Rental Details Local End Time"  
                  ,start_station_name = "03 - Rental Start Station Name" 
                  ,start_station_id = "03 - Rental Start Station ID"
                  ,end_station_name = "02 - Rental End Station Name" 
                  ,end_station_id = "02 - Rental End Station ID"
                  ,member_casual = "User Type")

q3_2019 <- rename(q3_2019
                  ,ride_id = trip_id
                  ,rideable_type = bikeid 
                  ,started_at = start_time  
                  ,ended_at = end_time  
                  ,start_station_name = from_station_name 
                  ,start_station_id = from_station_id 
                  ,end_station_name = to_station_name 
                  ,end_station_id = to_station_id 
                  ,member_casual = usertype)

q4_2019 <- rename(q4_2019
                  ,ride_id = trip_id
                  ,rideable_type = bikeid 
                  ,started_at = start_time  
                  ,ended_at = end_time  
                  ,start_station_name = from_station_name 
                  ,start_station_id = from_station_id 
                  ,end_station_name = to_station_name 
                  ,end_station_id = to_station_id 
                  ,member_casual = usertype)



## Inspecting Dataframes

str(q1_2020)
str(q2_2019)
str(q3_2019)
str(q4_2019)




## Converting ride_id and rideable_type so that the dataframes combine properly

q2_2019 <-  mutate(q2_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 

q3_2019 <-  mutate(q3_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type))

q4_2019 <-  mutate(q4_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 



## Combining all 4 dataframes as all_trips

all_trips <- bind_rows(q1_2020, q2_2019, q3_2019, q4_2019)



## Dropping useless columns

all_trips <- all_trips %>%
  select(-c(start_lat, start_lng, end_lat, end_lng, "01 - Rental Details Duration In Seconds Uncapped"
            , "Member Gender", "05 - Member Details Member Birthday Year", tripduration, gender, birthyear))



## Inspecting the new dataframe

colnames(all_trips)
str(all_trips)



## Making the "member_casual" column consistent
## Replacing "Subscriber" with "member" and "Customer" with "casual"

table(all_trips$member_casual)

all_trips <- all_trips %>%
  mutate(member_casual = recode(member_casual
                                , "Subscriber" = "member"
                                , "Customer" = "casual"))



## Adding columns for listing date, month, and day of the week of started_at

all_trips$date <- as.Date(all_trips$started_at)
all_trips$month <- format(as.Date(all_trips$date),"%m")
all_trips$day_of_week <- format(as.Date(all_trips$date),"%A")



## Adding a "trip_duration" column for future analysis

all_trips$trip_duration <- difftime(all_trips$ended_at, all_trips$started_at)

str(all_trips$trip_duration)



## Converting "trip_duration" to numeric from where it is in factor.

all_trips$trip_duration <- as.numeric(as.character(all_trips$trip_duration)) 
is.numeric(all_trips$trip_duration)



## Removing BAD data

all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$trip_duration < 0),]



## Analyzing data

aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = max)



## Comparing members and casuals for each day of the week

aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

all_trips_v2 %>%
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n(), average_duration = mean(trip_duration)) %>%
  arrange(member_casual, day_of_week)



## Plotting bar graphs comparing number of rides of members and casuals

all_trips_v2 %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n()) %>%
  arrange(member_casual, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) + geom_col(position = "dodge")



## Plotting bar graphs comparing average trip duration of members and casuals

all_trips_v2 %>%
  group_by(member_casual, day_of_week) %>%
  summarise(average_duration = mean(trip_duration)) %>%
  arrange(member_casual, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = average_duration, fill = member_casual)) + geom_col(position = "dodge")



## Creating a summary file ad exporting it for further analysis

summary <- aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(summary,file = 'summary.csv', row.names = FALSE)


