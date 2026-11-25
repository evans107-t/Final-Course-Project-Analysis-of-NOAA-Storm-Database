# Health Impact and Timing of Severe Weather Events in the U.S., 2024

Final course project for DAT 413 (Data Stewardship), Canisius University.

**Published report:** http://rpubs.com/taylor_evans/noaa-storm-2024

## Overview

This project analyzes the NOAA Storm Events Database for 2024 to answer four questions:

1. Which event types are most harmful to population health?
2. Which event types happen most in which states?
3. Which event types are characteristic of which months?
4. Which event types cause the greatest economic damage?

## Data

The data come from the NOAA Storm Events Database bulk CSV files:
https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/

This analysis uses the 2024 files, version `c20261119`:

- `StormEvents_details-ftp_v1.0_d2024_c20261119.csv.gz`
- `StormEvents_fatalities-ftp_v1.0_d2024_c20261119.csv.gz`
- `StormEvents_locations-ftp_v1.0_d2024_c20261119.csv.gz`

The three raw files are included in the `data` folder. The joined file, `StormEvents_joined_data.csv`, is not included because of its size. The R Markdown document creates `StormEvents_joined_data.csv` in the `data` folder the first time the report is knit.

Files downloaded on November 23, 2026.

## Files

| File | Description |
|---|---|
| `FinalAnalysis.Rmd` | R Markdown report with all code, explanations, and results |
| `FinalAnalysis.R` | R script with all code from the report |
| `data/` | Raw NOAA data files for 2024 |
| `README.md` | This file |
| `CodeBook.md` | Study design, processing steps, and variable definitions |
| `FinalAnalysis.html` | Knitted report, the same version published on RPubs |
| `Final Course Project: Analysis of NOAA Storm Database.Rproj` | RStudio project file that sets the working directory |

## Software

The report was produced with:

- R 4.6.1 on macOS Tahoe 26.6.2
- dplyr 1.2.1
- readr 2.2.0
- knitr 1.51 and rmarkdown 2.31 (used to knit the report)

The full session information is at the end of the published report.

## How to reproduce

1. Clone or download this repository.
2. Open `Final Course Project: Analysis of NOAA Storm Database.Rproj` in RStudio.
3. Install the required packages if needed: `install.packages(c("dplyr", "readr"))`.
4. Open `FinalAnalysis.Rmd` and click **Knit**.

All file paths are relative to the project folder, so the report runs on any computer with the project files. If the raw files are missing from the `data` folder, the report downloads them from NOAA when it is knit.

## Key findings

- **Health impact:** Heat (Heat and Excessive Heat combined) caused the most deaths and injuries in 2024 (745), followed closely by tornadoes (711). Heat caused mostly deaths, while tornadoes caused mostly injuries. Kept separate, neither heat category would outrank tornadoes.
- **By state:** Thunderstorm Wind was the most common event in 36 of 51 places (50 states and DC). The other 15 most often recorded events that fit their local climate, such as Hail in Texas and Heat in Oklahoma.
- **By month:** Winter events peaked in January, Hail and Thunderstorm Wind in May, Heat in July, Flash Floods in August, and Drought in November.
- **Economic damage:** Hurricanes caused about $6.8 billion in damage from only 76 events, more than twice any other event type.
