if(!require(googleAnalyticsR)){ install.packages('googleAnalyticsR') }
if(!require(googleAuthR)){ install.packages('googleAuthR') }
if(!require(ggmap)){ install.packages('ggmap') }
if(!require(tidyverse)){ install.packages('tidyverse') }
if(!require(raster)){ install.packages('raster') }


#account authentication
ga_auth()
# options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/analytics.readonly", 
#                                         "https://www.googleapis.com/auth/analytics",
#                                         "https://www.googleapis.com/auth/analytics.edit"))

# ther account structure functions: ga_account_list(), ga_accounts(), ga_view_list(), ga_webproperty_list(), ga_webproperty()
account_list <- ga_accounts()# ga_account_list()
ga_auth(email = " jogodelinguagem@gmail.com")

googleAuthR::gar_set_client("~/dbPepVar/client-web-id.json")

googleAuthR::gar_set_client(web_json = "~/dbPepVar/client-web-id.json", activate = "web")
googleAnalyticsR::ga_auth(email = "ptrckphilo@gmail.com")

gcs_list_buckets(projectId = "dbPepVar")

ga_view_id <- 342002


aa <- ga_accounts()
wp <- ga_webproperty_list(aa$id[1])

ga <- google_analytics(223283232, date_range = c("30daysAgo", "yesterday"), metrics = "sessions")

ga <- google_analytics("G-34TE3RG6BK", date_range = c("30daysAgo", "yesterday"), metrics = "sessions")

