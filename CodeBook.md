# Codebook

This codebook describes the data, processing steps, and variables used in the report *Health Impact and Timing of Severe Weather Events in the U.S., 2024*. All processing happens in `FinalAnalysis.Rmd`, which starts from the raw files.

## Study design

### Data source

The data come from the NOAA Storm Events Database, which records major storms and other significant weather events in the United States. It includes when and where each event happened and estimates of deaths, injuries, and damage.

- Bulk CSV files: https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/
- NOAA's description of every column: https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/Storm-Data-Bulk-csv-Format.pdf
- Files downloaded on November 23, 2026

### Raw files

| File | Rows | Columns | One row per |
|---|---|---|---|
| `StormEvents_details-ftp_v1.0_d2024_c20261119.csv.gz` | 69,802 | 51 | Storm event |
| `StormEvents_fatalities-ftp_v1.0_d2024_c20261119.csv.gz` | 1,142 | 11 | Person who died |
| `StormEvents_locations-ftp_v1.0_d2024_c20261119.csv.gz` | 40,258 | 11 | Point along an event's path |

In each file name, `d2024` is the data year and `c20261119` is the date NOAA created the file. The three files are linked by `EVENT_ID`.

### Processing steps

The steps run in this order in `FinalAnalysis.Rmd`.

1. **Load and join.** The three raw files are read directly from the compressed `.csv.gz` files and joined by `EVENT_ID` with `left_join()`, keeping every row of the details file. The result, `joined_data`, is saved as `data/StormEvents_joined_data.csv`.
2. **Check the join.** One event can have several location rows and several fatality rows, so the join repeats events. `joined_data` has 85,745 rows for 69,802 events, and its total of direct deaths is 4,852 compared with 774 in the details file. For this reason, every count of events, deaths, injuries, and damage comes from the details table, which has exactly one row per event.
3. **Order the months.** `MONTH_NAME` is converted from text to a factor with the months in calendar order.
4. **Combine the heat categories.** Events recorded as "Excessive Heat" are relabeled "Heat," so heat's impact is not split across two categories. This reduces the number of event types from 50 to 49.
5. **Create a health total.** `HEALTH_TOTAL` adds direct deaths, indirect deaths, direct injuries, and indirect injuries for each event.
6. **Convert damage to dollars.** The text damage values (such as "10.00K") are converted to numeric dollar amounts in `PROPERTY_DMG` and `CROP_DMG`.
7. **Limit Question 2 to states.** `details_states` removes 4 U.S. territories and 13 bodies of water, leaving the 50 states and DC (51 places, 66,388 events). The full details table is kept for the other questions.

### Inclusion choices

- **Year:** 2024 only.
- **Question 2:** the 50 states and DC. Removed areas: American Samoa, Guam, Puerto Rico, Virgin Islands, Atlantic North, Atlantic South, E Pacific, Guam Waters, Gulf of Alaska, Gulf of Mexico, Lake Erie, Lake Huron, Lake Michigan, Lake Ontario, Lake St Clair, Lake Superior, and St Lawrence R.
- **Question 3:** the 10 most common event types, which together make up about 82% of all events. Many other event types have very few events, some only one or two.

### Missing values

- The four death and injury columns have no missing values.
- `DAMAGE_PROPERTY` is missing for 15,046 events and `DAMAGE_CROPS` for 15,413 events. These events stay `NA` after conversion and are left out of the damage totals with `na.rm = TRUE`. Damage totals therefore count only events with a reported estimate.

## Variables

### Original variables used from the details file

Definitions are paraphrased from NOAA's format document linked above.

| Variable | Type | Description |
|---|---|---|
| `EVENT_ID` | Numeric | ID NOAA assigns to each storm event. Links the details, fatalities, and locations files. |
| `STATE` | Character | Name of the state or area where the event happened, in capital letters. Includes territories and bodies of water as well as states. |
| `MONTH_NAME` | Character, converted to factor | Month of the event, spelled out (for example, "January"). Converted to a factor in calendar order during cleaning. |
| `EVENT_TYPE` | Character | Type of weather event, spelled out (for example, "Hail" or "Thunderstorm Wind"). "Excessive Heat" is relabeled "Heat" during cleaning. |
| `DEATHS_DIRECT` | Numeric (count) | Number of deaths directly caused by the event. |
| `DEATHS_INDIRECT` | Numeric (count) | Number of deaths indirectly caused by the event. |
| `INJURIES_DIRECT` | Numeric (count) | Number of injuries directly caused by the event. |
| `INJURIES_INDIRECT` | Numeric (count) | Number of injuries indirectly caused by the event. |
| `DAMAGE_PROPERTY` | Character | Estimated property damage, written as a number and a unit letter: K for thousands, M for millions, B for billions (for example, "10.00K" is $10,000). |
| `DAMAGE_CROPS` | Character | Estimated crop damage, in the same format as `DAMAGE_PROPERTY`. |

### Variables created during cleaning

These are added to the `details` table in `FinalAnalysis.Rmd`.

| Variable | Type | Units | Description |
|---|---|---|---|
| `HEALTH_TOTAL` | Numeric (count) | Deaths plus injuries | `DEATHS_DIRECT + DEATHS_INDIRECT + INJURIES_DIRECT + INJURIES_INDIRECT` for each event. |
| `PROPERTY_DMG` | Numeric | U.S. dollars | `DAMAGE_PROPERTY` converted to a dollar amount. `NA` when no estimate was reported. |
| `CROP_DMG` | Numeric | U.S. dollars | `DAMAGE_CROPS` converted to a dollar amount. `NA` when no estimate was reported. |

### Datasets created

| Dataset | One row per | Description |
|---|---|---|
| `joined_data` | Event, location, and fatality combination | The three raw files joined by `EVENT_ID`. Used only to check the join. |
| `details_states` | Event | The details table limited to the 50 states and DC. Used for Question 2. |
| `health_by_type` | Event type | Deaths, injuries, and health totals by event type (Question 1). |
| `top_type_by_state` | State | The most common event type in each state (Question 2). |
| `peak_month_by_type` | Event type | The peak month for each of the 10 most common event types (Question 3). |
| `damage_by_type` | Event type | Property, crop, and total damage by event type (Question 4). |

### Summary table columns

**`health_by_type` (Question 1)**

| Column | Units | Description |
|---|---|---|
| `EVENT_TYPE` | | Event type |
| `deaths` | Count | Direct plus indirect deaths |
| `injuries` | Count | Direct plus indirect injuries |
| `health_total` | Count | Sum of `HEALTH_TOTAL` for the event type |

**`top_type_by_state` (Question 2)**

| Column | Units | Description |
|---|---|---|
| `STATE` | | State name, or "DISTRICT OF COLUMBIA" |
| `EVENT_TYPE` | | Most common event type in that state |
| `events` | Count | Number of events of that type in that state |

**`peak_month_by_type` (Question 3)**

| Column | Units | Description |
|---|---|---|
| `EVENT_TYPE` | | One of the 10 most common event types |
| `MONTH` | | Month with the most events of that type |
| `events` | Count | Number of events of that type in that month |

**`damage_by_type` (Question 4)**

| Column | Units | Description |
|---|---|---|
| `EVENT_TYPE` | | Event type |
| `property_millions` | Millions of U.S. dollars | Total property damage, rounded to one decimal place |
| `crop_millions` | Millions of U.S. dollars | Total crop damage, rounded to one decimal place |
| `total_millions` | Millions of U.S. dollars | Property plus crop damage, added before rounding and then rounded to one decimal place |