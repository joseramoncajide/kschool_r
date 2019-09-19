setwd("~/GitHub/kschool_r/07-Reporting")

# Clave de acceso a Google Analytics
Sys.setenv(GA_AUTH_FILE = "ks-alumnos-ga.json")

# Cargamos las librerías necesarias
list.of.packages <- c("tidyverse","googleAuthR", "googleAnalyticsR", "forecast", "highcharter", "lubridate", "openxlsx", "gmailr", "googlesheets", "rsconnect")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

## ------------------------------------------------------------------------

# Obtención de los datos de GA

fecha_actual <- Sys.Date()

ultimo_dia_mes_anterior <- rollback(fecha_actual)

sesiones.df <- google_analytics_3(id = "46728973",
                                start = c("2017-07-01"), 
                                end = ultimo_dia_mes_anterior,
                                metrics = c("sessions"),
                                dimensions = c("yearMonth"),
                                segment = c("sessions::condition::ga:deviceCategory==desktop"), 
                                max_results = 11000)

## ---- include=FALSE------------------------------------------------------
# Convertimos los datos a una serie temporal
sesiones.ts <- ts(sesiones.df$sessions, start = c(2017,07), end = c(2019,08), frequency = 12)
plot(sesiones.ts)

## ------------------------------------------------------------------------
autoplot(sesiones.ts) + 
  theme_minimal() + 
  xlab("") + 
  ylab("Sesiones") + 
  labs(title="Evolución de tráfico", subtitle= "Sesiones en el sitio web", caption = "Fuente: Google Analytics") 

## ---- include=FALSE------------------------------------------------------
# Modelamos la serie temporal
sesiones.modelo <- ets(sesiones.ts)
plot(sesiones.modelo)

## ------------------------------------------------------------------------
autoplot(sesiones.modelo) + 
  theme_minimal() + 
  xlab("") + 
  ylab("Sesiones") + 
  labs(title="Evolución de tráfico", subtitle= "Descomposición de la serie temporal", caption = "Fuente: Google Analytics") 

## ---- include=FALSE------------------------------------------------------
# Realizamos una predicción
# 
meses <- 24
sesiones.prediccion <- forecast( sesiones.modelo, h=meses )
plot(sesiones.prediccion)

## ------------------------------------------------------------------------
autoplot(sesiones.prediccion) + 
  theme_minimal() + 
  xlab("") + 
  ylab("Sesiones") + 
  labs(title="Previsión", subtitle= "Estimación de tráfico para los próximos 6 meses", caption = "Fuente: Google Analytics") 

## ---- eval=FALSE, include=FALSE------------------------------------------
## # Bonus
## # http://jkunst.com/highcharter/index.html
hchart(sesiones.prediccion) %>% hc_title(text = "Sesiones históricas y previstas")

## ---- eval=FALSE, include=FALSE------------------------------------------
## # Bonus
highchart() %>%
   hc_add_series_ts(as.ts(sesiones.prediccion)$x, name = "Real") %>%
  hc_add_series_ts(as.ts(sesiones.prediccion)$fitted, name = "Modelo") %>%
   hc_add_series_ts(as.ts(sesiones.prediccion)$mean, name = "Previsión")  %>%
   hc_title(text = "Sesiones históricas y previstas")

## ------------------------------------------------------------------------
# Exportamos los datos a Excel
workbook <- file.path("sesiones.xlsx")
wb <- createWorkbook()

addWorksheet(wb, "Sesiones Desktop", zoom = 125)
setColWidths(wb, "Sesiones Desktop", cols = c(1:4), widths = c(35,10,10))
writeDataTable(wb, sheet = "Sesiones Desktop", x = sesiones.df , tableStyle = "TableStyleMedium18", keepNA = TRUE)

saveWorkbook(wb, workbook, overwrite = TRUE)

