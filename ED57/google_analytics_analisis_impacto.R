##########################################################################
# Jose Cajide - @jrcajide
# Análisis de impacto
##########################################################################


# En este ejercicio ficticio cuantificaremos el impacto económico que ha tenido un echo relevante (COVID) en el tráfico
# de un sitio web y en sus ingresos por publicidad
# Trataremos de cuantificar las pérdidas anuales de un sitio web a consecuencia de la disminución del tráfico

library(tidyverse)
library(tsibble)
library(forecast)
library(fable)
library(feasts)
library(googleAnalyticsR)
# ga_auth()


# VARIABLES
ctr <- 0.0317
cpc <- 1.69 # euros
cpm <- 20 # euros


# Páginas vistas????


# Contexto -------------------------------------------------------
ga_data_df <- google_analytics_3(id = "12617825", #ID de la vista
                                 start=Sys.Date()-365*8, 
                                 end="yesterday", 
                                 metrics = c("pageviews"),
                                 dimensions = c("date"), 
                                 max_results = "10001")

ga_data_df %>% 
  ggplot(aes(x=date, y= pageviews)) +
  geom_line()


# Datos históricos --------------------------------------------------------
historico_df <- google_analytics_3(id = "12617825", 
                                 start="2015-01-01", 
                                 end="2019-12-31", 
                                 metrics = c("pageviews"),
                                 dimensions = c("date"), 
                                 max_results = "10001") %>% 
  as_tibble()

historico_df

historico_df %>% 
  ggplot(aes(x=date, y= pageviews)) +
  geom_line()

# Datos pandemia --------------------------------------------------------
pandemia_df <- google_analytics_3(id = "12617825", #ID de la vista (www.pasonoroeste.com)
                                 start="2020-01-01", 
                                 end="2020-12-31", 
                                 metrics = c("pageviews"),
                                 dimensions = c("date"), 
                                 max_results = "10001") %>% 
  as_tibble()

pandemia_df

pandemia_df %>% 
  ggplot(aes(x=date, y= pageviews)) +
  geom_line()


historico_df %>% 
  bind_rows(pandemia_df) %>% 
  ggplot(aes(x=date, y= pageviews)) +
  geom_line()

# Diferenciando ambas series
historico_df %>% 
  mutate(tipo="historico") %>% 
  bind_rows(pandemia_df %>% mutate(tipo="pandemia")) %>% 
  ggplot(aes(x=date, y= pageviews, color=tipo)) +
  geom_line()



# Series temporales -------------------------------------------------------

historico_ts <- as_tsibble(historico_df)

historico_ts <- historico_ts %>% 
  index_by(Year_Month = ~ yearmonth(.)) %>% 
  summarise(pageviews = sum(pageviews)) 

historico_ts %>% autoplot()


# Qué hubiera pasados si .... ---------------------------------------------

historico_modelo <- historico_ts %>%
  model(
    snaive = SNAIVE(pageviews ~ lag("year")),
    # ets = ETS(pageviews),
    arima = ARIMA(pageviews),
    # holt_winters = ETS(pageviews ~ error("A") + trend("A") + season("A")),
    # search = ARIMA(pageviews, stepwise=FALSE)
  )
predicciones_modelo_df <- 
  historico_modelo %>%
  forecast(h = 12) 

predicciones_modelo_df %>% 
  autoplot(level = NULL)

predicciones_modelo_df %>% 
  autoplot(historico_ts)



# Comparando con lo real --------------------------------------------------

pandemia_ts <- as_tsibble(pandemia_df)

pandemia_ts <- pandemia_ts %>% 
  index_by(Year_Month = ~ yearmonth(.)) %>% 
  summarise(pageviews = sum(pageviews)) 


pandemia_ts %>% 
  as_tibble() %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'Year_Month') %>% 
  dplyr::select(Year_Month, .model, pageviews_obs, .mean) %>% 
  filter(.model == 'arima') -> resultado_final_df
  
resultado_final_df %>% 
  ggplot(aes(x=Year_Month)) +
  geom_line(aes(y=pageviews_obs)) +
  geom_line(aes(y=.mean), color = 'tomato')


resultado_final_df %>% 
  mutate(desviacion = pageviews_obs - .mean) %>% 
  ggplot(aes(x=Year_Month, y= abs(desviacion))) +
  geom_bar(stat = 'identity')

resultado_final_df %>% 
  mutate(desviacion = pageviews_obs - .mean) %>% 
  summarise(total_pv = sum(desviacion))


# Análisis económico ------------------------------------------------------
resultado_final_df %>% 
  mutate(desviacion = abs(pageviews_obs - .mean)) %>% 
  mutate(ctr = ctr,
         cpc = cpc,
         cpm = cpm,
         modelo_cpc = desviacion * ctr * cpc, 
         modelo_cpm = (desviacion /1000) * cpm) -> informe_df

informe_df %>% 
  pivot_longer(names_to = "model", cols = starts_with('model')) %>% 
  ggplot(aes(x=Year_Month, y= value, fill=model)) + 
  geom_col(position = 'dodge')

  
  
informe_df %>% 
  summarise(modelo_cpc = sum(modelo_cpc), 
            mensual_cpc = sum(modelo_cpc) / n(),
            modelo_cpm =sum(modelo_cpm),
            mensual_cpm = sum(modelo_cpm) / n())

