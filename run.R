setwd("~/dbPepVar/")
library(shiny)
library(rsconnect)

source("setAccountInfo.R")

runApp(appDir = "~/dbPepVar/", display.mode="showcase")
runApp(appDir = "~/dbPepVar/")

deployApp()
forgetDeployment()
