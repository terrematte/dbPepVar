#setwd("~/bdbPepVar/")
library(shiny)
library(rsconnect)

source("setAccountInfo.R")

runApp(appDir = "~/bio/dbPepVar/", display.mode="showcase")
runApp(appDir = "~/bio/dbPepVar/")

deployApp()
forgetDeployment()

