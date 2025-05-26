#Step 1: Install Necessary Packages
# install.packages(c("shiny", "shinydashboard", "tidyverse", "DT", "plotly"))


#Step 2: Load and Prepare Data
# Load libraries
library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(DT)

# Load COVID-19 data from OWID

covid_data <- read_csv("data/owid-covid-data.csv", show_col_types = FALSE)

# Clean the data
covid_clean <- covid_data %>%
  select(location, date, total_cases, total_deaths) %>%
  filter(!is.na(total_cases), !is.na(total_deaths)) %>%
  filter(location %in% c("United States", "India", "Brazil", "France", "South Africa"))

covid_clean$date <- as.Date(covid_clean$date)

# UI
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = span(" COVID-19 Health Dashboard", style = "font-weight:bold")),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      br(),
      selectInput("country", "Select Country:", choices = unique(covid_clean$location)),
      dateRangeInput("date", "Select Date Range:",
                     start = min(covid_clean$date),
                     end = max(covid_clean$date))
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
      .content-wrapper, .right-side {
        background-color: #f9f9f9;
      }
      .box {
        border-radius: 15px !important;
      }
    "))),
    fluidRow(
      valueBoxOutput("total_cases", width = 6),
      valueBoxOutput("total_deaths", width = 6)
    ),
    fluidRow(
      box(
        title = "COVID-19 Trends", width = 12, solidHeader = TRUE,
        status = "primary", plotlyOutput("trendPlot", height = "350px")
      )
    ),
    fluidRow(
      box(title = "Download Filtered Data", width = 4, solidHeader = TRUE,
          downloadButton("downloadData", "Download CSV", class = "btn-primary")),
      box(title = "Filtered Data Table", width = 8, solidHeader = TRUE,
          DT::dataTableOutput("dataTable"))
    ),
    fluidRow(
      box(title = "Forecasting (Linear Regression)", width = 12, solidHeader = TRUE,
          status = "success", plotlyOutput("regressionPlot", height = "350px"))
    )
  )
)

# Server
server <- function(input, output) {
  
  filtered_data <- reactive({
    covid_clean %>%
      filter(location == input$country,
             date >= input$date[1],
             date <= input$date[2])
  })
  
  output$total_cases <- renderValueBox({
    total <- max(filtered_data()$total_cases, na.rm = TRUE)
    valueBox(format(total, big.mark = ","), "Total Cases", icon = icon("hospital"), color = "blue")
  })
  
  output$total_deaths <- renderValueBox({
    deaths <- max(filtered_data()$total_deaths, na.rm = TRUE)
    valueBox(format(deaths, big.mark = ","), "Total Deaths", icon = icon("skull"), color = "red")
  })
  
  output$trendPlot <- renderPlotly({
    plot_ly(filtered_data(), x = ~date) %>%
      add_lines(y = ~total_cases, name = "Cases", line = list(color = 'blue')) %>%
      add_lines(y = ~total_deaths, name = "Deaths", line = list(color = 'red')) %>%
      layout(title = "Cases and Deaths Over Time", xaxis = list(title = ""), yaxis = list(title = "Count"))
  })
  
  output$regressionPlot <- renderPlotly({
    data <- filtered_data()
    if (nrow(data) < 2) {
      return(plotly_empty())
    }
    
    data <- data %>% mutate(day = as.numeric(date - min(date)))
    model <- lm(total_cases ~ day, data = data)
    
    future_days <- data.frame(day = seq(max(data$day) + 1, max(data$day) + 30))
    pred <- predict(model, newdata = future_days, interval = "confidence")
    future_dates <- seq(max(data$date) + 1, by = "day", length.out = 30)
    
    plot_ly() %>%
      add_lines(x = data$date, y = data$total_cases, name = "Observed", line = list(color = "blue")) %>%
      add_lines(x = future_dates, y = pred[, "fit"], name = "Forecast", line = list(color = "green", dash = "dash")) %>%
      layout(title = "Projected COVID-19 Cases (Next 30 Days)", yaxis = list(title = "Total Cases"))
  })
  
  output$dataTable <- DT::renderDataTable({
    filtered_data()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("covid_data_", gsub(" ", "_", tolower(input$country)), ".csv", sep = "")
    },
    content = function(file) {
      write_csv(filtered_data(), file)
    }
  )
}

shinyApp(ui, server)

