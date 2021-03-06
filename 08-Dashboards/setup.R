###########################################################################
# @jrcajide
# Dashboards
# Sol: https://goo.gl/xtCG2P
##########################################################################

setwd("~/Documents/GitHub/kschool_r/08-Dashboards")


# Configuración acceso a GA -----------------------------------------------

library(googleAnalyticsR)

ga_auth()

# Agregar esta línea al documento RMarkdown o Flex Dashboard
ga_auth(email="kschool.alumnos@gmail.com")



# save(ga_funnel_step_1_df, ga_funnel_step_2_df, ga_channels_df, ga_leads_df, ga_adwords_df, file = "data/ga_data.RData")
# load("data/ga_data.RData")

# File > New file > R Markdown ... > From Template > Flex Dashboard

# Módulos del dashboard ---------------------------------------------------


# Librerías y parámetros del dashboard  ----------------------------------
library(googleAnalyticsR)
ga_auth(email="kschool.alumnos@gmail.com")
library(tidyverse)
library(highcharter)
library(forecast)
library(flexdashboard)

# 1) Embudo de captación de Leads -----------------------------------------
source("01_leads_funnel.R")$value

# 2) Correlaciones entre canales ------------------------------------------
source("02_channels.R")$value

# 3) Predicción de Leads --------------------------------------------------
source("03_leads_forecast.R")$value

# 4) Segmentación de campañas SEM -----------------------------------------
source('04_adwords_campaigns.R')$value




