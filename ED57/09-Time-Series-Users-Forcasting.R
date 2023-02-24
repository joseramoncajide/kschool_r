#los pinos

ga_data_df <- google_analytics_3(id = "89595964",
                                 start=Sys.Date()-31-365*2,
                                 end=Sys.Date()-31, 
                                 metrics = c("users"),
                                 dimensions = c("date"),
                                 max_results = "10001")

min(ga_data_df$date)
max(ga_data_df$date)

ga_data_ts <- as_tsibble(ga_data_df)
plot(ga_data_ts)
ga_data_ts %>% 
  autoplot(users)

# Seasonal and Trend decomposition using Loess
ga_data_ts %>%
  model(STL(users ~ trend(window=30) + season(window='periodic',period='1 year'),
            robust = TRUE)) %>%
  components() %>%
  autoplot()

ga_data_ts %>% model(MEAN(users)) %>% forecast(h=14) %>% autoplot()


fit <- ga_data_ts %>%
  model(
    snaive = SNAIVE(users ~ lag("week")),
    ets = ETS(users),
    arima = ARIMA(users)
  )
fit
predicciones_modelo_df <- fit %>%
  forecast(h = 30)
predicciones_modelo_df
predicciones_modelo_df %>%
  autoplot(level = NULL) 



predicciones_modelo_df %>% 
  autoplot(ga_data_ts)


min(predicciones_modelo_df$date)


ga_data_actual_df <- google_analytics_3(id = "89595964", 
                                        start=min(predicciones_modelo_df$date), 
                                        end=max(predicciones_modelo_df$date) ,
                                        metrics = c("users"),
                                        dimensions = c("date"), 
                                        max_results = "10001") %>% as_tibble()


ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df)

ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'date') %>% #as_tsibble %>% autoplot(vars='goal1Completions_obs')
  select(date, .model, users_obs, .mean) %>% 
  filter(.model == 'ets') %>% 
  ggplot(aes(x=date)) +
  geom_line(aes(y=users_obs)) +
  geom_line(aes(y=.mean), color = 'tomato')


# Ejercios::


# realiza la predicción para todo el año
