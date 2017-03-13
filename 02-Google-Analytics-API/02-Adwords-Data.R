

list.of.packages <- c("tidyverse", "googleAnalyticsR", "knitr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

#Autenticación
ga_auth()

# Fecha de inicio: 2016-09-01
# Fecha de fin: 2017-03-05
# Métricas: impresiones, clicks, costes y cpc
# Dimensiones: fecha y campaña


metricas_adwords <- google_analytics(id = "",
                                       start="2016-09-01", end="2017-03-05",
                                       metrics = c("ga:impressions,ga:adClicks,ga:adCost,ga:cpc"),
                                       dimensions = c("ga:date","ga:campaign"),
                                       max=99999999, 
                                       samplingLevel="HIGHER_PRECISION")