##########################################################################
# Caso práctico de tratamiento, visualización y modelado de datos de GA
##########################################################################

library(tidyverse)

# Configuración acceso a GA -----------------------------------------------
install.packages("googleAnalyticsR", dependencies = TRUE)
library(googleAnalyticsR)
ga_auth()

ga_account_list()

# Fechas ejercicio original: 2020-08-19 a 2021-01-26
# ga_data_df %>% saveRDS('11-GoogleAnalytics/ga_data_df.Rds')

ga_data_df <- google_analytics_3(id = "46728973", 
                                 start="190daysAgo", 
                                 end="30daysAgo", 
                                 metrics = c("users", "goal1Completions"),
                                 dimensions = c("date", "userType", "channelGrouping"), 
                                 filters = "ga:channelGrouping=~Organic|Direct|Paid",
                                 max_results = "10001")

ga_data_df <- ga_data_df %>% 
  as_tibble()

ga_data_df %>% summary()

# Es correcto?
ga_data_df %>% 
  ggplot(aes(x=date, y= users)) +
  geom_line()

# Y este?
ga_data_df %>% 
  ggplot(aes(x=date, y= users, color=userType)) +
  geom_line()


ga_data_df %>% 
  ggplot(aes(x=date, y= users, color=userType)) +
  geom_line() +
  facet_grid(channelGrouping~.)

# Ejercicio: Modifica el gráfico anterior de tal forma que puedas comparar mejor la evolución por tipo de usuario



# Ejercicio: Calcula el total de usuarios por día y por channelGrouping


# Queremos visualizar users Vs goal1Completions en un mismo gráfico ¿Cómo lo haremos?
# Sol. Necesitamos convertir los datos de un formato ancho a un formato largo
ga_data_df %>% 
  group_by(date) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions))


ga_data_df %>% 
  group_by(date) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions)) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric, color=dimension)) +
  geom_line() 

ga_data_df %>% 
  group_by(date) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions)) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric)) +
  geom_line() +
  facet_grid(dimension~., scales = 'free_y')
  
# Ejercicio: Calcular la tasa de conversión de goal1Completions y díbujala como en el anterior gráfico



# echarts4r ---------------------------------------------------------------
# https://echarts.apache.org/en/index.html
# Mirad estos ejemplos:
# https://echarts.apache.org/examples/en/editor.html?c=calendar-charts
# https://echarts.apache.org/examples/en/editor.html?c=line-marker
# https://echarts.apache.org/examples/en/editor.html?c=heatmap-cartesian


# Ejercicio: Instala echarts4r y haz un gráfico de evolución de goal1Completions y users por fecha en  ga_data_df
# Similar a https://echarts4r.john-coene.com/articles/chart_types.html#line-and-area

library(echarts4r)


# Ejericio: hacer un heatmap con userType, channelGrouping y goal1Completions
# https://echarts4r.john-coene.com/articles/chart_types.html#heatmap




# Ejercicio
# Hacer un calendario como el del ejemplo
# https://echarts4r.john-coene.com/articles/chart_types.html#calendar





# Reto:
# Ajustar todos los parámetros estáticos anteriores. i.e : Año y Valor máximo de la escala de color


# Modelado estadístico ----------------------------------------------------
# Linear regression

library(lubridate)

model_data = ga_data_df %>% 
  mutate(dayOfWeek = wday(date, label=TRUE)) %>% 
  group_by(date, channelGrouping) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions)) %>% 
  ungroup() %>% 
  select(-date)

modelo1 <- lm(goal1Completions~., data = model_data)
summary(modelo1)

model_data <- model_data %>% 
  mutate(id = row_number())

train_index <- sample(1:nrow(model_data), 0.8 * nrow(model_data))
test_index <- setdiff(1:nrow(model_data), train_index)

train_data <- model_data %>% 
  filter(id %in% train_index) %>% 
  select(-id)
test_data <- model_data %>% 
  filter(id %in% test_index) %>% 
  select(-id)

dim(train_data)
dim(test_data)

modelo2 <- lm(goal1Completions~. -1 , data = train_data)
summary(modelo2)
p <- predict(modelo2, test_data)

p
resultados <- test_data %>% 
  select(goal1Completions) %>% 
  mutate(predicciones = p)

test_data$goal1Completions

library(Metrics)

rmse(actual = test_data$goal1Completions, predicted = p)

rmse <- sqrt(sum((p - test_data$goal1Completions)^2)/length(test_data$goal1Completions))
rmse
summary(modelo2)$r.squared

library(rpart)       # performing regression trees
library(rpart.plot)
modelo3 <- rpart(
  formula = goal1Completions ~ .,
  data    = train_data
)
modelo3

rpart.plot(modelo3)
library(rattle)
fancyRpartPlot(modelo3)

p <- predict(modelo3, test_data)
rmse(actual = test_data$goal1Completions, predicted = p)



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
  ggtitle("Classical additive decomposition of total US retail employment")

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


# Vamos a comprobar la predicción con lo ocurrido del 2021-01-27 al 2021-02-25
# ga_data_actual_df %>% saveRDS('11-GoogleAnalytics/ga_data_actual_df.Rds')


ga_data_actual_df <- google_analytics_3()

ga_data_actual_df %>% summary()
  
# Qué falla?
ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df)

ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'date') %>% #as_tsibble %>% autoplot(vars='goal1Completions_obs')
  select(date, starts_with('goal')) %>% 
  e_chart(date) %>% 
  e_line(goal1Completions_obs) %>% 
  e_line(goal1Completions_pred)

# Error absoluto

ga_data_actual_df %>% 
  inner_join(predicciones_modelo_df,suffix = c('_obs', '_pred'),
             by = 'date') %>% 
  select(date, starts_with('goal')) %>% 
  mutate(error = abs(goal1Completions_obs - goal1Completions_pred)) %>% 
  e_chart(date) %>% 
  e_bar(error)

# Combina las tres métricas anteriores en un único gráfico
# Agrega un zoom: https://echarts4r.john-coene.com/articles/brush.html#zoom
# Agrega un tooltip
# Marca los valores máximos de cada serie: https://echarts4r.john-coene.com/articles/mark.html#type
# El '2021-02-13' comenzó una campaña SEM. Agrega una linea vertical para indicarlo https://echarts4r.john-coene.com/articles/mark.html#line
# Agrega líneas horizontales con los valores medios de las dos series (observadas y predicción)




# Ejercicio
# Repite el modelado y la predicción con un modelo ETS ¿Se reduce el error?




# Sol: https://gist.github.com/joseramoncajide/889acc8d110f3d03d9aa3f69efbca08a