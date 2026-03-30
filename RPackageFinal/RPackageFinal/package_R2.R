library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(forecast)
library(tidyr)
library(shinyWidgets)

data <- read.csv("Final-50-stocks.csv", stringsAsFactors=FALSE)
data$DATE <- as.Date(data$DATE, format="%Y-%m-%d")

findFirstNumeric <- function(column) {
  for(value in column) {
    if(is.numeric(value) && !is.na(value)) {
      return(value)
    }
  }
  return(NA) # Safely return NA if no numeric value is found
}

growthRate <- function(df) {
  result <- data.frame(Column=character(), GrowthRate_in_percent=numeric(), stringsAsFactors=FALSE)
  
  if (nrow(df) < 2) return(result)
  
  for(colName in colnames(df)) {
    if(colName != "DATE") {
      firstNumericValue <- findFirstNumeric(df[[colName]])
      
      if (!is.na(firstNumericValue) && firstNumericValue != 0) {
        maxVal <- df[[nrow(df), colName]]
        growth_rate <- ((maxVal / firstNumericValue) * 100) - 100
        result <- rbind(result, data.frame(Column=colName, GrowthRate_in_percent=growth_rate))
      }
    }
  }
  
  return(result)
}

# Define sector groupings once to avoid repeating in UI and Server
sectors <- list(
  tech = c("HCLTECH", "INFY", "TCS", "WIPRO", "TECHM"),
  banking = c("AXISBANK", "SBIN", "HDFCBANK", "ICICIBANK", "INDUSBANK", "KOTAKBANK"),
  petroleum = c("BPCL", "IOC"),
  automobile = c("EICHERMOTOR", "HEROMOTOCO", "MARUTI", "TATAMOTORS", "BAJAJ.AUTO"),
  financial = c("BAJAJFINSERV", "BAJAJFINANCE"),
  steel = c("TATASTEEL", "JSWSTEEL"),
  cement = c("SHREECEM", "ULTRACEMO", "GRASIM"),
  pharma = c("DRREDDYS", "CIPLA", "SUNPHARMA"),
  food = c("BRITANNIA", "NESTLEIND"),
  government = c("COALINDIA", "NTPC", "ONGC"),
  chemical = c("UPL", "M.M"),
  power = c("ADANIPORTS", "HINDALCO", "POWERGRID"),
  largeScale = c("ITC", "HINDUNILVR"),
  industry = c("RELIANCE", "LT", "TITAN", "ADANIPORTS", "BHARTIARTL", "ASIANPAINT", "M.M")
)

ui <- dashboardPage(
  dashboardHeader(title="Stock Price Analysis & Prediction"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName="dashboard", icon=icon("dashboard")),
      menuItem("Growth Rate", tabName="growthRates", icon=icon("chart-bar")),
      menuItem("Top 10 stocks", tabName="top10Stocks", icon=icon("chart-line")),
      menuItem("Statistics", tabName="statistics", icon=icon("calculator")),
      menuItem("Tech Sector", tabName="tech", icon=icon("laptop")),
      menuItem("Banking Sector", tabName="banking", icon=icon("university")),
      menuItem("Petroleum Sector", tabName="petroleum", icon=icon("gas-pump")),
      menuItem("Automobile Sector", tabName="automobile", icon=icon("car")),
      menuItem("Financial Sector", tabName="financial", icon=icon("coins")),
      menuItem("Steel Sector", tabName="steel", icon=icon("industry")),
      menuItem("Cement Sector", tabName="cement", icon=icon("truck")),
      menuItem("Large Scale", tabName="largeScale", icon=icon("boxes")),
      menuItem("Pharma Sector", tabName="pharma", icon=icon("medkit")),
      menuItem("Food Sector", tabName="food", icon=icon("utensils")),
      menuItem("Government Sector", tabName="government", icon=icon("university")),
      menuItem("Chemical Sector", tabName="chemical", icon=icon("flask")),
      menuItem("Power Sector", tabName="power", icon=icon("bolt")),
      menuItem("Industry Sector", tabName="industry", icon=icon("industry")),
      menuItem("Predictions", tabName="predictions", icon=icon("chart-line")),
      menuItem("Download Data", tabName="download", icon=icon("download"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName="dashboard",
              fluidRow(
                box(title="Select Date Range", width=6, dateRangeInput("dateRange", "Date Range:", start=min(data$DATE,na.rm=TRUE), end=max(data$DATE,na.rm=TRUE))),
                box(title="Select Company", width=6, pickerInput("companyPicker", "Select Companies:", choices=colnames(data)[-1], selected=c("TCS","WIPRO","RELIANCE"), multiple=TRUE))
              ),
              fluidRow(
                box(title="Stock Prices", width=12, plotlyOutput("pricePlot"))
              )
      ),
      
      tabItem(tabName="growthRates",
              fluidRow(
                box(title="Growth Rates by Companies (Based on Filter)", width=12, plotlyOutput("growthPlot")),
                box(title="Growth Rate Data", width=12, tableOutput("growthTable"))
              )
      ),
      
      tabItem(tabName="top10Stocks",
              fluidRow(
                box(title="Top 10 Stocks (Based on Filter)", width=12, tableOutput("top10Table"))
              )
      ),
      
      # UI for Sectors utilizing plotly for interactivity
      tabItem(tabName="tech", fluidRow(box(title="Tech Sector", width=12, plotlyOutput("techPlot")))),
      tabItem(tabName="banking", fluidRow(box(title="Banking Sector", width=12, plotlyOutput("bankPlot")))),
      tabItem(tabName="petroleum", fluidRow(box(title="Petroleum Sector", width=12, plotlyOutput("petrolPlot")))),
      tabItem(tabName="automobile", fluidRow(box(title="Automobile Sector", width=12, plotlyOutput("autoPlot")))),
      tabItem(tabName="financial", fluidRow(box(title="Financial Sector", width=12, plotlyOutput("financePlot")))),
      tabItem(tabName="steel", fluidRow(box(title="Steel Sector", width=12, plotlyOutput("steelPlot")))),
      tabItem(tabName="cement", fluidRow(box(title="Cement Sector", width=12, plotlyOutput("cementPlot")))),
      tabItem(tabName="largeScale", fluidRow(box(title="Large Scale Sector", width=12, plotlyOutput("largeScalePlot")))),
      tabItem(tabName="pharma", fluidRow(box(title="Pharma Sector", width=12, plotlyOutput("pharmaPlot")))),
      tabItem(tabName="food", fluidRow(box(title="Food Sector", width=12, plotlyOutput("foodPlot")))),
      tabItem(tabName="government", fluidRow(box(title="Government Sector", width=12, plotlyOutput("governmentPlot")))),
      tabItem(tabName="chemical", fluidRow(box(title="Chemical Sector", width=12, plotlyOutput("chemicalPlot")))),
      tabItem(tabName="power", fluidRow(box(title="Power Sector", width=12, plotlyOutput("powerPlot")))),
      tabItem(tabName="industry", fluidRow(box(title="Industry Sector", width=12, plotlyOutput("industryPlot")))),
      
      tabItem(tabName="predictions",
              fluidRow(
                box(title="Predicted Stock Prices (30 Days)", width=12, selectInput("predictionCompany", "Select Company:", choices=colnames(data)[-1]), plotlyOutput("predictionPlot")),
                box(title="Winning/Losing Stocks", width=12, verbatimTextOutput("winnerLoserOutput"))
              )
      ),
      
      tabItem(tabName="statistics",
              fluidRow(
                box(title="Select Company", width=6, pickerInput("statCompanyPicker", "Select Company:", choices=colnames(data)[-1], selected=colnames(data)[2])),
                box(title="Statistics", width=6, tableOutput("statTable"))
              )
      ),
      
      tabItem(tabName="download",
              fluidRow(
                box(title="Download Data", width=6, downloadButton("downloadCSV", "Download Filtered Data")),
                box(title="Download Single Company Analysis", width=6, pickerInput("analysisCompanyPicker", "Select Company: ", choices=colnames(data)[-1]), downloadButton("downloadAnalysis", "Download Analysis")),
                box(title="Download All Companies Analysis", width=6, downloadButton("downloadAllAnalysis", "Download All Companies Analysis"))
              )
      )
    )
  )
)


server <- function(input, output) {
  
  # Centralized reactive dataset filtered by date
  filteredData <- reactive({
    req(input$dateRange)
    data %>%
      filter(DATE >= input$dateRange[1] & DATE <= input$dateRange[2]) %>%
      drop_na()
  })
  
  # Dashboard price plot uses plotly
  output$pricePlot <- renderPlotly({
    req(input$companyPicker)
    df <- filteredData() %>%
      select(DATE, all_of(input$companyPicker)) %>%
      pivot_longer(cols=-DATE, names_to="Company", values_to="Value")
    
    p <- ggplot(df, aes(x=DATE, y=Value, color=Company, group=Company)) + 
      geom_line() + 
      labs(title="Stock Price Trends", x="Date", y="Price") + 
      theme_minimal() + theme(legend.position="bottom")
    
    ggplotly(p)
  })
  
  # Centralized reactive growth rate calculation
  reactiveGrowthRate <- reactive({
    req(nrow(filteredData()) > 1)
    growthRate(filteredData())
  })
  
  # Growth plot using plotly
  output$growthPlot <- renderPlotly({
    growthData <- reactiveGrowthRate()
    req(nrow(growthData) > 0)
    
    p <- ggplot(growthData, aes(x=Column, y=GrowthRate_in_percent, text=paste("Company:", Column, "<br>Growth:", round(GrowthRate_in_percent, 2), "%"))) + 
      geom_bar(stat="identity", fill="lightgreen") + 
      labs(title="Growth Rate by Companies", x="Companies", y="Growth Rate (%)") + 
      theme_minimal() + theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
    
    ggplotly(p, tooltip="text")
  })
  
  output$growthTable <- renderTable({
    reactiveGrowthRate()
  })
  
  output$top10Table <- renderTable({
    reactiveGrowthRate() %>%
      arrange(desc(GrowthRate_in_percent)) %>%
      head(10)
  })

  # --- DRY SERVER LOGIC ---
  # Single helper function to render sector plots dynamically
  render_sector_plot <- function(sector_tickers, sector_name) {
    renderPlotly({
      df <- filteredData() %>%
        select(DATE, any_of(sector_tickers)) %>%
        pivot_longer(cols=-DATE, names_to="Company", values_to="Value") %>%
        filter(!is.na(Value))
      
      p <- ggplot(df, aes(x=DATE, y=Value, color=Company, group=Company)) + 
        geom_line() + 
        labs(title=paste(sector_name, "Stock Prices"), x="Date", y="Price") + 
        theme_minimal()
      
      ggplotly(p)
    })
  }
  
  # Dynamically assign to all sector tab outputs
  output$techPlot <- render_sector_plot(sectors$tech, "Tech Sector")
  output$bankPlot <- render_sector_plot(sectors$banking, "Banking Sector")
  output$petrolPlot <- render_sector_plot(sectors$petroleum, "Petroleum Sector")
  output$autoPlot <- render_sector_plot(sectors$automobile, "Automobile Sector")
  output$financePlot <- render_sector_plot(sectors$financial, "Financial Sector")
  output$largeScalePlot <- render_sector_plot(sectors$largeScale, "Large Scale Company Sector")
  output$steelPlot <- render_sector_plot(sectors$steel, "Steel Sector")
  output$cementPlot <- render_sector_plot(sectors$cement, "Cement Sector")
  output$pharmaPlot <- render_sector_plot(sectors$pharma, "Pharma Sector")
  output$foodPlot <- render_sector_plot(sectors$food, "Food Sector")
  output$governmentPlot <- render_sector_plot(sectors$government, "Government Sector")
  output$chemicalPlot <- render_sector_plot(sectors$chemical, "Chemical Sector")
  output$powerPlot <- render_sector_plot(sectors$power, "Power Sector")
  output$industryPlot <- render_sector_plot(sectors$industry, "Industrial Sector")
  
  # Predictions with error handling
  output$predictionPlot <- renderPlotly({
    req(input$predictionCompany)
    company <- input$predictionCompany
    companyData <- data %>%
      select(DATE, !!sym(company)) %>%
      filter(!is.na(!!sym(company))) %>%
      arrange(DATE)
    
    if (nrow(companyData) < 10) return(NULL) # Requires minimum data points
    
    etsModel <- tryCatch({
      ets(companyData[[2]])
    }, error=function(e) NULL)
    
    if (is.null(etsModel)) return(NULL)
    
    forecastedData <- forecast(etsModel, h=30)
    
    forecastDF <- data.frame(
      DATE = seq(max(companyData$DATE) + 1, by="day", length.out=30), 
      Value = forecastedData$mean
    )
    
    p <- ggplot() + 
      geom_line(data=companyData, aes(x=DATE, y=!!sym(company)), color='blue', size=0.5) + 
      geom_line(data=forecastDF, aes(x=DATE, y=Value), color='red', linetype="dashed") + 
      labs(title=paste(company, "Stock Price Forecast"), x="Date", y="Price") + 
      theme_minimal()
      
    ggplotly(p)
  })
  
  output$winnerLoserOutput <- renderPrint({
    # More robust prediction on most recent available data chunk
    recentData <- data %>% filter(DATE >= (max(DATE) - 30))
    
    if(nrow(recentData) < 2) return("Insufficient recent data available.")
    
    predictedReturns <- sapply(colnames(recentData)[-1], function(company) {
      compData <- recentData %>% select(DATE, !!sym(company)) %>% filter(!is.na(!!sym(company)))
      
      if (nrow(compData) < 5) return(NA)
      
      tryCatch({
        model <- ets(compData[[2]])
        pred <- forecast(model, h=1)$mean
        as.numeric(pred)
      }, error=function(e) NA)
    })
    
    predictedReturns <- sort(predictedReturns, decreasing=TRUE, na.last=NA)
    
    if(length(predictedReturns) == 0 || is.na(names(predictedReturns[1]))) {
       return("Cannot calculate winning stocks due to lack of standard data.")
    }
    
    winner <- names(predictedReturns[1])
    loser <- names(predictedReturns[length(predictedReturns)])
    
    cat(sprintf("Predicted Winner: %s with the highest predicted return.\n", winner))
    cat(sprintf("Predicted Loser: %s with the lowest predicted return.\n", loser))
  })
  
  output$statTable <- renderTable({
    req(input$statCompanyPicker)
    selected_company <- input$statCompanyPicker
    stats_data <- filteredData() %>% 
      select(DATE, !!sym(selected_company)) %>% 
      drop_na()
    
    if (nrow(stats_data) == 0) return(NULL)
    
    data.frame(
      Statistic = c("Mean", "Median", "Variance", "Standard Deviation"),
      Value = c(
        mean(stats_data[[2]], na.rm=TRUE),
        median(stats_data[[2]], na.rm=TRUE),
        var(stats_data[[2]], na.rm=TRUE),
        sd(stats_data[[2]], na.rm=TRUE)
      )
    )
  })
  
  output$downloadCSV <- downloadHandler(
    filename = function() { paste("filtered_data_", Sys.Date(), ".csv", sep="") },
    content = function(file) { write.csv(filteredData(), file, row.names=FALSE) }
  )
  
  output$downloadAnalysis <- downloadHandler(
    filename = function() { paste(input$analysisCompanyPicker, "_analysis_", Sys.Date(), ".txt", sep="") },
    content = function(file) {
      req(input$analysisCompanyPicker)
      selected_company <- input$analysisCompanyPicker
      
      company_data <- filteredData() %>%
        select(DATE, !!sym(selected_company)) %>%
        drop_na()
      
      analysis_text <- paste(
        "Company: ", selected_company, "\n",
        "Mean: ", mean(company_data[[2]], na.rm=TRUE), "\n",
        "Median: ", median(company_data[[2]], na.rm=TRUE), "\n",
        "Variance: ", var(company_data[[2]], na.rm=TRUE), "\n",
        "Standard Deviation: ", sd(company_data[[2]], na.rm=TRUE), "\n",
        sep=""
      )
      
      writeLines(analysis_text, file)
    }
  )
  
  output$downloadAllAnalysis <- downloadHandler(
    filename = function() { paste("all_companies_analysis_", Sys.Date(), ".txt", sep="") },
    content = function(file) {
      all_analysis <- ""
      
      for (company in colnames(data)[-1]) {
        company_data <- filteredData() %>%
          select(DATE, !!sym(company)) %>%
          drop_na()
        
        if (nrow(company_data) > 0) {
          analysis_text <- paste(
            "Company:", company, "\n",
            "Mean:", mean(company_data[[2]], na.rm=TRUE), "\n",
            "Median:", median(company_data[[2]], na.rm=TRUE), "\n",
            "Variance:", var(company_data[[2]], na.rm=TRUE), "\n",
            "Standard Deviation:", sd(company_data[[2]], na.rm=TRUE), "\n\n",
            sep=""
          )
          all_analysis <- paste(all_analysis, analysis_text, sep="")
        }
      }
      
      writeLines(all_analysis, file)
    }
  )
}

shinyApp(ui=ui, server=server)
