setwd("~/dbPepVar/")

# Load libraries
library(shiny)
#library(rsconnect)

# Run on local RStudio
runApp(appDir = "~/dbPepVar/")
#runApp(appDir = "~/dbPepVar/", display.mode="showcase")

# Load login and token of shinyapps.io account in a separated file added to .gitignore:
# rsconnect::setAccountInfo(name='terrematte', token='xxxxxx', secret='xxxx')
# source("setAccountInfo.R")
# options(rsconnect.max.bundle.files=100000)

# Deploy to shinyapps.io 
# deployApp()

# UnDeploy of shinyapps.io 
#forgetDeployment()

