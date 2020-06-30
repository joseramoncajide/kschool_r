

# Configuración acceso a GA -----------------------------------------------
install.packages("googleAnalyticsR", dependencies = TRUE)
library(googleAnalyticsR)
googleAuthR::gar_token_info(detail_level = getOption("googleAuthR.verbose", default = 3))
ga_auth()

file.exists('.httr-oauth')

file.copy('.httr-oauth', 'ga_auth_token.httr-oauth')


Sys.setenv(GA_AUTH_FILE = 'ga_auth_token.httr-oauth')


googleAuthR::gar_auth("ga_auth_token.httr-oauth")

library(googleAnalyticsR)

library(tidyverse)

ga_account_list()


ga_data_df <- google_analytics_3(id = "46728973", 
                                 start="190daysAgo", 
                                 end="30daysAgo", 
                                 metrics = c("users", "goal1Completions"),
                                 dimensions = c("date", "userType", "channelGrouping"), 
                                 filters = "ga:channelGrouping=~Organic|Direct|Paid",
                                 max_results = "10001")

ga_data_df <- ga_data_df %>% 
  as_tibble()

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

# Modifica el gráfico anterior de tal forma que puedas comparar mejor la evolución por tipo de usuario
ga_data_df %>% 
  ggplot(aes(x=date, y= users, color=channelGrouping)) +
  geom_line() +
  facet_grid(userType~.)


# Calcula el total de usuarios por día y por channelGrouping
ga_data_df %>% 
  group_by(date, channelGrouping) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions)) %>% 
  ggplot(aes(x=date, y= users, color=channelGrouping)) +
  geom_line() 

# Queremos visualizar users Vs goal1Completions ¿Cómo lo haremos?
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
  
# Calcular la tasa de conversión de goal1Completions y díbujala como en el anterior gráfico
ga_data_df %>% 
  group_by(date) %>% 
  summarise(users = sum(users),
            goal1Completions = sum(goal1Completions),
            conversionRate = goal1Completions / users) %>% 
  pivot_longer(-date, names_to = 'dimension', values_to = 'metric') %>% 
  ggplot(aes(x=date, y= metric)) +
  geom_line() +
  facet_grid(dimension~., scales = 'free_y')


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
  data    = train_data,
  method  = "anova"
)
modelo3

rpart.plot(modelo3)

p <- predict(modelo3, test_data)
rmse(actual = test_data$goal1Completions, predicted = p)

# %>% 
#   do(reg=lm(goal1Completions~users + channelGrouping,data=.))
#   pivot_wider(names_from = channelGrouping, values_from = users)

# TS Forecast goal1Completions


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
    # ets = ETS(goal1Completions),
    # arima = ARIMA(goal1Completions)
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
  forecast() %>%
  autoplot(ga_data_ts)
