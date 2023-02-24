##########################################################################
# Caso práctico de tratamiento, visualización y modelado de datos de GA
##########################################################################

library(tidyverse)

# Configuración acceso a GA -----------------------------------------------
# install.packages("googleAnalyticsR", dependencies = TRUE)
library(googleAnalyticsR)
ga_auth()

ga_account_list()



ga_data_df <- google_analytics_3(id = "12617825", #ID de la vista (www.pasonoroeste.com)
                                 start="360daysAgo", 
                                 end="yesterday", 
                                 metrics = c("sessions", "bounces"),
                                 dimensions = c("date", "userType", "channelGrouping"), 
                                 max_results = "10001")

ga_data_df <- ga_data_df %>% 
  as_tibble()

ga_data_df %>% summary()

# Es correcto?
ga_data_df %>% 
  ggplot(aes(x=date, y= sessions)) +
  geom_line()

# Y este?
ga_data_df %>% 
  ggplot(aes(x=date, y= sessions, color=userType)) +
  geom_line()


ga_data_df %>% 
  ggplot(aes(x=date, y= sessions, color=userType)) +
  geom_line() +
  facet_grid(channelGrouping~.)

# Ejercicio: Modifica el gráfico anterior de tal forma que puedas comparar mejor la evolución por tipo de usuario



# Ejercicio: Calcula el total de usuarios por día y por channelGrouping




# Queremos visualizar sessions Vs bounces en un mismo gráfico ¿Cómo lo haremos?
# Sol. Necesitamos convertir los datos de un formato ancho a un formato largo
ga_data_df %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions),
            bounces = sum(bounces)) 


ga_data_df %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions),
            bounces = sum(bounces)) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric, color=dimension)) +
  geom_line() 

ga_data_df %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions),
            bounces = sum(bounces)) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric)) +
  geom_line() +
  facet_grid(dimension~., scales = 'free_y')

# Ejercicio: Calcular la tasa de rebote y díbujala como en el anterior gráfico

ga_data_df %>% 
  mutate(bounce_rate = bounces / sessions) %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions),
            bounces = sum(bounces),
            bounce_rate = sum(bounces) / sum(sessions)) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric)) +
  geom_line() +
  facet_grid(dimension~., scales = 'free_y')

# echarts4r ---------------------------------------------------------------

# Ejercicio: Instala echarts4r y haz un gráfico de evolución de sessions por canal   ga_data_df
# Similar a https://echarts4r.john-coene.com/articles/chart_types.html#line-and-area

library(echarts4r)

ga_data_df %>% 
  group_by(date,channelGrouping) %>% 
  summarise(sessions = sum(sessions)) %>% 
  ungroup() %>% 
  group_by(channelGrouping) %>% 
  e_charts(x=date) %>% 
  e_line(serie = sessions) 
  


# Modelado estadístico ----------------------------------------------------
# Regresión lineal

library(lubridate)

model_data = ga_data_df %>% 
  mutate(dayOfWeek = wday(date,abbr = F, label=TRUE)) %>% 
  group_by(date, channelGrouping, dayOfWeek) %>% 
  summarise(sessions = sum(sessions),
            bounces = sum(bounces)) %>% 
  ungroup() %>% 
  select(-date)

modelo1 <- lm(bounces~., data = model_data)
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

modelo2 <- lm(bounces~. -1 , data = train_data)
summary(modelo2)
p <- predict(modelo2, test_data)

p
resultados <- test_data %>% 
  select(bounces) %>% 
  mutate(predicciones = p)


resultados %>% 
  ggplot(aes(x=bounces, y=predicciones)) + geom_point()

test_data$bounces

library(Metrics)

rmse(actual = test_data$bounces, predicted = p)

rmse <- sqrt(sum((p - test_data$bounces)^2)/length(test_data$bounces))
rmse
summary(modelo2)$r.squared

library(rpart)       
library(rpart.plot)
modelo3 <- rpart(
  formula = bounces ~ .,
  data    = train_data
)
modelo3

rpart.plot(modelo3)
library(rattle)
fancyRpartPlot(modelo3)

p <- predict(modelo3, test_data)
rmse(actual = test_data$bounces, predicted = p)

