library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(readr)
library(lubridate)
library(scales)
library(bsicons)

# =============================================================================
# 1. Data Loading and Preprocessing
# =============================================================================
data_path <- "data/raw/amazon_sales_dataset.csv"

if (file.exists(data_path)) {
  df <- read_csv(data_path, show_col_types = FALSE)
} else {
  warning("CSV not found. Loading simulated data for testing.")
  df <- data.frame(
    order_date = as.Date("2023-01-01") + sample(1:365, 1000, replace = TRUE),
    total_revenue = runif(1000, 50, 500),
    order_id = paste0("ORD", 1000:1999),
    product_category = sample(c("Electronics", "Clothing", "Home", "Sports", "Beauty"), 1000, replace = TRUE),
    customer_region = sample(c("North America", "Europe", "Asia", "Middle East"), 1000, replace = TRUE),
    payment_method = sample(c("Credit Card", "PayPal", "Gift Card", "Debit"), 1000, replace = TRUE)
  )
}

# Clean and format data
df <- df %>%
  mutate(
    order_date = ymd(order_date), 
    month_start = floor_date(order_date, "month"),
    total_revenue = as.numeric(total_revenue)
  )

# Extract unique choices for UI
categories <- sort(unique(df$product_category))
regions <- sort(unique(df$customer_region))

# =============================================================================
# 2. User Interface (UI)
# =============================================================================
ui <- page_sidebar(
  title = "Amazon Sales Dashboard (R Edition)",
  theme = bs_theme(preset = "shiny"),
  
  # Sidebar inputs
  sidebar = sidebar(
    title = "Filters",
    selectInput("category", "Categories",
                choices = categories,
                selected = categories[1:min(3, length(categories))],
                multiple = TRUE,
                selectize = TRUE),
    
    checkboxGroupInput("region", "Regions",
                       choices = regions,
                       selected = regions),
    hr(),
    helpText("Use these filters to slice the sales data.")
  ),
  
  # Top Row: Value Boxes
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Total Revenue",
      value = textOutput("revenue_val"),
      theme = "primary"
    ),
    value_box(
      title = "Total Orders",
      value = textOutput("orders_val"),
      theme = "info"
    )
  ),
  
  # Bottom Row: Plots
  layout_columns(
    col_widths = c(8, 4),
    card(
      card_header("Monthly Revenue Trend"),
      plotOutput("trend_plot")
    ),
    card(
      card_header("Revenue by Payment Method"),
      plotOutput("payment_plot")
    )
  )
)

# =============================================================================
# 3. Server Logic
# =============================================================================
server <- function(input, output, session) {
  
  filtered_data <- reactive({
    req(input$category, input$region)
    
    df %>%
      filter(
        product_category %in% input$category,
        customer_region %in% input$region
      )
  })
  
  output$revenue_val <- renderText({
    total_rev <- sum(filtered_data()$total_revenue, na.rm = TRUE)
    dollar(total_rev)
  })
  
  output$orders_val <- renderText({
    total_ord <- n_distinct(filtered_data()$order_id)
    comma(total_ord)
  })
  
  output$trend_plot <- renderPlot({
    d <- filtered_data()
    
    if(nrow(d) == 0) {
      return(ggplot() + annotate("text", x = 1, y = 1, label = "No data matching filters") + theme_void())
    }
    
    trend_data <- d %>%
      group_by(month_start, product_category) %>%
      summarise(revenue = sum(total_revenue, na.rm = TRUE), .groups = "drop")
    
    ggplot(trend_data, aes(x = month_start, y = revenue, color = product_category)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      scale_y_continuous(labels = label_dollar()) +
      labs(x = "Month", y = "Revenue", color = "Category") +
      theme_minimal(base_size = 14) +
      theme(legend.position = "bottom")
  })
  
  output$payment_plot <- renderPlot({
    d <- filtered_data()
    
    if(nrow(d) == 0) {
      return(ggplot() + theme_void())
    }
    
    payment_data <- d %>%
      group_by(payment_method) %>%
      summarise(revenue = sum(total_revenue, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(revenue))
    
    ggplot(payment_data, aes(x = reorder(payment_method, revenue), y = revenue, fill = payment_method)) +
      geom_col() +
      coord_flip() +
      scale_y_continuous(labels = label_dollar()) +
      labs(x = NULL, y = "Revenue") +
      theme_minimal(base_size = 14) +
      theme(legend.position = "none")
  })
}

shinyApp(ui = ui, server = server)