
# COVID-19 Health Dashboard

## Overview

This interactive Shiny dashboard provides an up-to-date visualization and analysis of COVID-19 data for selected countries. Users can explore trends in total cases and deaths, filter data by country and date range, download filtered datasets, and view linear regression-based forecasts of future cases.

## Features

- Select from multiple countries (United States, India, Brazil, France, South Africa).
- Filter data by date range.
- View key metrics as value boxes.
- Interactive plots of cases and deaths over time.
- Forecast future COVID-19 cases using linear regression.
- Download filtered data as CSV.
- Responsive and clean UI using `shinydashboard`.

## Installation

Make sure you have R and RStudio installed. Then install the necessary R packages:

```r
install.packages(c("shiny", "shinydashboard", "tidyverse", "plotly", "DT"))
```

## Running the App

In your R console or RStudio, run:

```r
library(shiny)
runApp("path/to/your/app/folder")
```

Alternatively, open the app folder in RStudio and click the **Run App** button.

## Dependencies

- shiny  
- shinydashboard  
- tidyverse  
- plotly  
- DT  

## Contact

Created by Ray Beckham Onyango  
Email: onyangoraybeckham@gmail.com
