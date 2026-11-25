## ----load-packages-------------------------------------
library(dplyr)
library(readr)


## ----download-data-------------------------------------
if (!file.exists("data")) {
  dir.create("data")
}
noaa_url <- "https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/"
file_names <- c("StormEvents_details-ftp_v1.0_d2024_c20261119.csv.gz",
                "StormEvents_fatalities-ftp_v1.0_d2024_c20261119.csv.gz",
                "StormEvents_locations-ftp_v1.0_d2024_c20261119.csv.gz")
for (f in file_names) {
  if (!file.exists(paste("data/", f, sep = ""))) {
    download.file(paste(noaa_url, f, sep = ""),
                  destfile = paste("data/", f, sep = ""), mode = "wb")
  }
}


## ----load-data, cache=TRUE-----------------------------
details    <- read_csv("data/StormEvents_details-ftp_v1.0_d2024_c20261119.csv.gz")
fatalities <- read_csv("data/StormEvents_fatalities-ftp_v1.0_d2024_c20261119.csv.gz")
locations  <- read_csv("data/StormEvents_locations-ftp_v1.0_d2024_c20261119.csv.gz")

joined_data <- details %>%
  left_join(locations, by = "EVENT_ID") %>%
  left_join(fatalities, by = "EVENT_ID")

write_csv(joined_data, "data/StormEvents_joined_data.csv")


## ----join-check----------------------------------------
data.frame(
  dataset       = c("details", "joined_data"),
  rows          = c(nrow(details), nrow(joined_data)),
  direct_deaths = c(sum(details$DEATHS_DIRECT, na.rm = TRUE),
                    sum(joined_data$DEATHS_DIRECT, na.rm = TRUE))
)
max(table(details$EVENT_ID))   


## ----clean-months--------------------------------------
details <- details %>%
  mutate(MONTH_NAME = factor(MONTH_NAME,
                             levels = c("January", "February", "March", "April", "May", "June",
                                        "July", "August", "September", "October", "November", "December")))


## ----combine-heat--------------------------------------
table(details$EVENT_TYPE)[c("Heat", "Excessive Heat")]

details <- details %>%
  mutate(EVENT_TYPE = ifelse(EVENT_TYPE == "Excessive Heat", "Heat", EVENT_TYPE))


## ----health-total--------------------------------------
details <- details %>%
  mutate(HEALTH_TOTAL = DEATHS_DIRECT + DEATHS_INDIRECT +
                        INJURIES_DIRECT + INJURIES_INDIRECT)


## ----convert-damage------------------------------------
convert_damage <- function(x) {
  number     <- as.numeric(gsub("[KMB]", "", x))
  multiplier <- ifelse(grepl("K", x), 1000,
                ifelse(grepl("M", x), 1000000,
                ifelse(grepl("B", x), 1000000000, 1)))
  number * multiplier
}

details <- details %>%
  mutate(PROPERTY_DMG = convert_damage(DAMAGE_PROPERTY),
         CROP_DMG     = convert_damage(DAMAGE_CROPS))
sum(is.na(details$PROPERTY_DMG))   
sum(is.na(details$CROP_DMG))      


## ----filter-states-------------------------------------
details_states <- details %>%
  filter(!(STATE %in% c("AMERICAN SAMOA", "GUAM", "PUERTO RICO", "VIRGIN ISLANDS",
                        "ATLANTIC NORTH", "ATLANTIC SOUTH", "E PACIFIC", "GUAM WATERS",
                        "GULF OF ALASKA", "GULF OF MEXICO", "LAKE ERIE", "LAKE HURON",
                        "LAKE MICHIGAN", "LAKE ONTARIO", "LAKE ST CLAIR", "LAKE SUPERIOR",
                        "ST LAWRENCE R")))

nrow(details_states)  


## ----q1-table------------------------------------------
health_by_type <- details %>%
  group_by(EVENT_TYPE) %>%
  summarize(deaths       = sum(DEATHS_DIRECT + DEATHS_INDIRECT),
            injuries     = sum(INJURIES_DIRECT + INJURIES_INDIRECT),
            health_total = sum(HEALTH_TOTAL)) %>%
  arrange(desc(health_total))

head(health_by_type, 10)


## ----q1-plot, fig.width=9, fig.height=6----------------
top10 <- head(health_by_type, 10)
par(mar = c(10, 4, 3, 1))
barplot(top10$health_total,
        names.arg = top10$EVENT_TYPE,
        ylim = c(0, 800),
        las = 2,
        col = c("firebrick", "steelblue", rep("gray80", 8)),
        main = "Top 10 Storm Event Types by Deaths and Injuries, U.S. 2024",
        ylab = "Total deaths and injuries")


## ----q2-table------------------------------------------
state_type_counts <- as.data.frame(table(details_states$STATE, details_states$EVENT_TYPE)) %>%
  rename(STATE = Var1, EVENT_TYPE = Var2, events = Freq)

top_type_by_state <- state_type_counts %>%
  group_by(STATE) %>%
  filter(events == max(events)) %>%
  arrange(desc(events)) %>%
  as.data.frame()

top_type_by_state


## ----q2-plot, fig.width=9, fig.height=6----------------
top_type_counts <- sort(table(as.character(top_type_by_state$EVENT_TYPE)), decreasing = TRUE)
par(mar = c(9, 4, 3, 1))
barplot(top_type_counts,
        ylim = c(0, 40),
        las = 2,
        col = c("darkorange", rep("gray80", 8)),
        main = "Most Common Storm Event Type in Each State, U.S. 2024",
        ylab = "Number of states (including DC)")


## ----q3-table------------------------------------------
top10_types <- names(head(sort(table(details$EVENT_TYPE), decreasing = TRUE), 10))

top_types_data <- details %>%
  filter(EVENT_TYPE %in% top10_types)

peak_month_by_type <- as.data.frame(table(top_types_data$EVENT_TYPE, top_types_data$MONTH_NAME)) %>%
  rename(EVENT_TYPE = Var1, MONTH = Var2, events = Freq) %>%
  group_by(EVENT_TYPE) %>%
  filter(events == max(events)) %>%
  arrange(MONTH) %>%
  as.data.frame()

peak_month_by_type
round(nrow(top_types_data) / nrow(details) * 100, 1)  


## ----q3-plot, fig.width=10, fig.height=14--------------
par(mfrow = c(5, 2), mar = c(3, 3, 3, 1))
for (type in top10_types) {
  type_months <- top_types_data$MONTH_NAME[top_types_data$EVENT_TYPE == type]
  barplot(table(type_months),
          names.arg = c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"),
          col = ifelse(table(type_months) == max(table(type_months)), "seagreen", "gray80"),
          main = type)
}


## ----q4-table------------------------------------------
damage_by_type <- details %>%
  group_by(EVENT_TYPE) %>%
  summarize(events            = length(EVENT_ID),   # counts the events in each type, so "76 events" shows up
            property_millions = sum(PROPERTY_DMG, na.rm = TRUE) / 1000000,
            crop_millions     = sum(CROP_DMG, na.rm = TRUE) / 1000000) %>%
  mutate(total_millions = property_millions + crop_millions) %>%
  mutate(property_millions = round(property_millions, digits = 1),
         crop_millions     = round(crop_millions, digits = 1),
         total_millions    = round(total_millions, digits = 1)) %>%
  arrange(desc(total_millions)) %>%
  as.data.frame()

head(damage_by_type, 10)


## ----q4-plot, fig.width=9, fig.height=6----------------
top10_damage <- head(damage_by_type, 10)
par(mar = c(10, 5, 3, 1))
barplot(top10_damage$total_millions,
        names.arg = top10_damage$EVENT_TYPE,
        ylim = c(0, 7000),
        las = 2,
        col = c("darkgoldenrod", rep("gray80", 9)),
        main = "Top 10 Storm Event Types by Damage, U.S. 2024",
        ylab = "Total damage (millions of dollars)")


## ----session-info--------------------------------------
sessionInfo()

