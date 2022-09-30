##########################################################################
# Caso práctico de modelado de datos de GA con R
##########################################################################


# Ejercicio para unos 30 minutos de explicación

library(tidyverse)

# Configuración acceso a GA -----------------------------------------------
# install.packages("googleAnalyticsR", dependencies = TRUE)
library(googleAnalyticsR)
ga_auth()

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

