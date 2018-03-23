###########################################################################
# @jrcajide, 2018-03
# Dashboards
##########################################################################

setwd("~/Documents/GitHub/kschool_r/08-Dashboards")


# Configuración acceso a GA -----------------------------------------------

library(googleAnalyticsR)
ga_auth(new_user = T)

file.exists('.httr-oauth')

file.copy('.httr-oauth', 'ga_auth_token.httr-oauth')

.rs.restartR()

Sys.setenv(GA_AUTH_FILE = 'ga_auth_token.httr-oauth')

library(googleAnalyticsR)

ga_account_list()

# load("data/ga_data.RData")

# File > New file > R Markdown ... > From Template > Flex Dashboard

# Módulos del dashboard ---------------------------------------------------


# Librerías y parámetros del dashboard  ----------------------------------
Sys.setenv(GA_AUTH_FILE = 'ga_auth_token.httr-oauth')
library(googleAnalyticsR)
library(tidyverse)
library(highcharter)
library(forecast)
library(flexdashboard)

# Ejemplo consulta a la api de GA -----------------------------------------

ga_data_df <- google_analytics_3(id = "46728973", 
                                 start="30daysAgo", 
                                 end="yesterday", 
                                 metrics = c("users"),
                                 dimensions = c("date"), 
                                 segment = "users::condition::ga:browser=@Chrome",
                                 max_results = "10001")

# 1) Embudo de captación de Leads -----------------------------------------
source("01_leads_funnel.R")$value

# 2) Correlaciones entre canales ------------------------------------------
source("02_channels.R")$value

# 3) Predicción de Leads --------------------------------------------------
source("03_leads_forecast.R")$value

# 4) Segmentación de campañas SEM -----------------------------------------
source('04_adwords_campaigns.R')$value




