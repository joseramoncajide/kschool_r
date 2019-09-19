###########################################################################
# Leads forecast
##########################################################################

# Obtención de datos ------------------------------------------------------

# ¿Cúantos eventos únicos mensuales han tenido lugar para la categoría de evento 'Conversion' y la acción de evento 'Form' desde 2017-01-01 hasta el 2019-08-31?

# yearMonth uniqueEvents
# 201701           151
# 201702           126
# 201703           203

ga_leads_df <- google_analytics_3(...)


# Transformación de los datos en una serie temporal -----------------------

ga_leads_ts <- ts(...)
plot(ga_leads_ts)


# Modelado de la serie temporal -------------------------------------------

leads_model <- ...
leads_forecast <-  ...


# Visualización predicción de leads ---------------------------------------

# http://jkunst.com/highcharter/hchart.html#forecast-package
hchart(...) 