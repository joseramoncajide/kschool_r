##########################################################################
# Caso práctico de modelado de datos de GA con R
##########################################################################
library(tidyverse)

# Configuración acceso a GA -----------------------------------------------
# install.packages("googleAnalyticsR", dependencies = TRUE)
library(googleAnalyticsR)
# ga_auth()

ga_account_list() %>% View()

# Datos de 2021-11-15 a 2022-04-24
ga_data_df <- google_analytics_3(id = "113351594", 
                                 start="2021-11-15", 
                                 end="2022-04-24", 
                                 metrics = c("users", "goal1Completions"),
                                 dimensions = c("date", "userType", "channelGrouping"), 
                                 filters = "ga:channelGrouping=~Organic|Direct|Paid",
                                 max_results = "10001")

ga_data_df <- ga_data_df %>% 
  as_tibble()

ga_data_df %>% summary()


# ¿qué relación hay entre goal1Completions y users?: Calculamos la tasa de conversión
ga_data_df %>% 
  summarise(goal1Completions = sum(goal1Completions),
            users = sum(users)) %>% 
  mutate(cr = goal1Completions / users)


ga_data_df %>% 
  ggplot(aes(x=users, y=goal1Completions)) + 
  geom_point() +
  geom_smooth(method = 'lm')

modelo1 <- lm(goal1Completions ~ users, data = ga_data_df)
summary(modelo1)


# Regresion lineal multiple

ga_data_df %>% 
  ggplot(aes(x=users, y=goal1Completions, color = channelGrouping)) + 
  geom_point()

ga_data_df %>% 
  ggplot(aes(x=users, y=goal1Completions, color = userType)) + 
  geom_point() +
  geom_smooth(method = 'lm')

modelo2 <- lm(goal1Completions ~ users + userType, data = ga_data_df)
summary(modelo2)


modelo3 <- lm(goal1Completions ~ users + userType + channelGrouping, data = ga_data_df)
summary(modelo3)



# Modelado de series temporales -------------------------------------------

library(tsibble)
library(fable)
library(feasts)

ga_data_ts <- ga_data_df %>% 
  group_by(date) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions),
            conversionRate = goal1Completions / users) %>% 
  as_tsibble() 

plot(ga_data_ts)

ga_data_ts %>% 
  autoplot(goal1Completions)

ga_data_ts %>%
  model(classical_decomposition(goal1Completions, type = "additive")) %>%
  components() %>%
  autoplot() + xlab("Year") +
  ggtitle("Descomposición")

ga_data_ts %>%
  model(STL(goal1Completions ~ trend(window=7) + season(window='periodic'),
            robust = TRUE)) %>%
  components() %>%
  autoplot()


ga_data_ts %>% model(MEAN(goal1Completions)) %>% forecast(h=14) %>% autoplot()


fit <- ga_data_ts %>%
  model(
    mean=MEAN(goal1Completions),
    naive=NAIVE(goal1Completions),
    snaive=SNAIVE(goal1Completions),
    ets = ETS(goal1Completions),
    arima = ARIMA(goal1Completions)
  )
fit
fc <- fit %>%
  forecast(h = 31)
fc

fc %>%
  autoplot(ga_data_ts, level = NULL) +
  ggtitle("Forecasts for Snowy Mountains holidays") +
  xlab("Year") +
  guides(colour = guide_legend(title = "Forecast"))


ga_data_ts  %>% 
  model(stlf = decomposition_model(
    STL(goal1Completions ~ trend(window = 7), robust = TRUE),
    NAIVE(season_adjust)
  )) %>%
  forecast(h=30) -> predicciones_modelo_df

predicciones_modelo_df %>% 
  autoplot(ga_data_ts)


# Vamos a comprobar la predicción con lo ocurrido realmente en los últimos 30 días
# Datos de 2021-11-15 a 2022-04-24
as.Date('2022-04-24') + 30
ga_data_actual_df <- google_analytics_3(id = "113351594", 
                                        start="2022-04-25", 
                                        end="2022-05-24", 
                                        metrics = c("goal1Completions"),
                                        dimensions = c("date"), 
                                        filters = "ga:channelGrouping=~Organic|Direct|Paid",
                                        max_results = "10001") %>% as_tibble()

ga_data_actual_df %>% summary()

# Qué falla?
ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df)

ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'date') %>% #as_tsibble %>% autoplot(vars='goal1Completions_obs')
  select(date, starts_with('goal'), .mean) %>% 
  ggplot(aes(x=date)) +
  geom_line(aes(y=goal1Completions_obs)) +
  geom_line(aes(y=.mean), color = 'tomato')


# Error absoluto

ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'date') %>% 
  select(date, starts_with('goal'), .mean) %>% 
  mutate(error = abs(goal1Completions_obs - .mean)) %>%
  ggplot(aes(x=date, y=error)) + geom_col()

