# Amazon Sales Dashboard (R Shiny Edition)

This is an individual assignment re-implementing a group project (originally built in Shiny for Python) using **Shiny for R**. 

The application is a sales dashboard that allows users to filter Amazon sales data by product category and region, view aggregate revenue and order metrics, and analyze trends and payment methods.

## Live Application
The deployed application is hosted on Posit Connect Cloud.

👉 **[Link to Live App](https://019ceea9-ca5c-63ee-6497-c1f1aa221ff5.share.connect.posit.cloud)**

*(Note: The link is also available in the GitHub repository's "About" section metadata).*

## How to Run Locally

To run this application on your own machine, follow these steps:

### 1. Prerequisites
Ensure you have the following installed:
* [R](https://cran.r-project.org/)
* [RStudio](https://posit.co/download/rstudio-desktop/)

### 2. Clone the Repository
Open your terminal or command prompt and run:
```bash
git clone https://github.com/hugokwok0119/amazon-sales-r-shiny.git
```

### 3. Open the Project
Double click the amazon-sales-r-shiny.Rproj file to open the project in RStudio. This ensures your working directory is set correctly.

### 4. Install Required Packages

This project uses renv for dependency management to ensure reproducibility. To install all the exact package versions required for this app, run the following in the RStudio Console:

```R
# Install renv if you don't have it
install.packages("renv")

# Restore the project library from the lockfile
renv::restore()
```

### 5. Run the Application

Open the app.R file in RStudio.

Click the green ▶ Run App button at the top right of the script editor.

The dashboard will launch in a new window or your default web browser.
