
# list.of.packages <- c("tidyverse", "googleAnalyticsR", "knitr")
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages)
# lapply(list.of.packages, require, character.only = TRUE)


library(tidyverse)

# googleAnalyticsR



#Autenticación
ga_auth()

# Fecha de inicio: 2016-09-01
# Fecha de fin: 2017-03-05
# Métricas: usuarios, nuevos usuarios, sesiones
# Dimensiones: fecha
# Segemento: sesiones de Google / CPC



mis_datos_de_ga <- google_analytics(...)
)

# Exportar los datos a un CSV

...