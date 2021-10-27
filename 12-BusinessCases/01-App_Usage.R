library(tidymodels)
library(modeltime)
library(tidyverse)
library(lubridate)
library(timetk)
library(plotly)



# Pregunta de negocio -----------------------------------------------------

# https://shop.googlemerchandisestore.com/
# https://support.google.com/analytics/answer/6367342?hl=es
# ¿Cuáles son las mejores horas para enviar notificaciones push a los usuarios de mi App con el fin de lograr un mayor alcance?

# Origen de los datos: https://console.cloud.google.com/bigquery
# Visualización con Data Studio

df <- read_csv('12-BusinessCases/data/app_usage.csv')

summary(df)


df %>% 
  ggplot(aes(x = event_hour, y= users)) +
  geom_line()

# ¿Cómo haríamos para ver los datos agregados por día en vez de por hora?

df %>% 
  mutate(event_date = date(event_hour)) %>% 
  group_by(event_date) %>% 
  summarise(users= sum(users)) %>% 
  ggplot(aes(x = event_date, y= users)) +
  geom_line()


# timetk::plot_time_series
df %>% 
  plot_time_series(.date_var = event_hour, 
                   .value = users, 
                   .interactive = FALSE)


# Cuáles son las tres horas del día con mayor tráfico por la semana y los fines de semana
df %>% 
  mutate(
    hour= hour(event_hour),
    week_day = wday(event_hour, label = F,week_start = 1),
    is_week_end = (week_day %in% c(6, 7))
  ) %>% 
  group_by(hour, is_week_end) %>% 
  summarise(users = sum(users)) %>% 
  ungroup() %>% 
  group_by(is_week_end) %>% 
  mutate(ranking = rank(-users)) %>% 
  arrange(is_week_end, ranking) %>% 
  filter(ranking <= 3)


# Componentes de una serie temporal -------------------------------------

df %>%
  plot_stl_diagnostics(
    .date_var = event_hour,
    .value =  users,
    .frequency = "auto", 
    .trend = "auto",
    .feature_set = c("observed", "season", "trend", "remainder"),
    .interactive = FALSE)

# Estacionalidad
df %>%
  plot_seasonal_diagnostics(
    .date_var = event_hour,
    .value =  users,
    .interactive = FALSE,
    .geom_outlier_color = 'red')


# Modelado ----------------------------------------------------------------

# Paso 1 - División de los datos en dos grupos: entrenamiento y validación.

splits <- df %>%
  time_series_split(assess = "7 days", 
                    cumulative = TRUE,
                    date_var = event_hour)

splits$out_id

splits %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(.date_var = event_hour,
                           .value =  users, 
                           .interactive = FALSE)


# Paso 2 - Definir y entrena los modelos

model_fit_ets <- exp_smoothing() %>%
  set_engine(engine = "ets") %>%
  fit(users ~ event_hour, data = training(splits))

model_fit_lm <- linear_reg() %>%
  set_engine("lm") %>%
  fit(users ~ as.numeric(event_hour) + factor(wday(event_hour, label = TRUE), ordered = FALSE) + factor(hour(event_hour), ordered = FALSE),
      data = training(splits))


# Paso 3 - Cominamos los modelos en una tabla

models_tbl <- modeltime_table(
  model_fit_ets,
  model_fit_lm
)


# Paso 4 - Evaluamos el modelo con los datos de validación.

calibration_tbl <- models_tbl %>%
  modeltime_calibrate(new_data = testing(splits))


# Paso 5 - Realizamos la predicción y evaluamos el modelo

# 5A - Visualizamos oara comparar la predicción del modelo con los datos de validación

calibration_tbl %>%
  modeltime_forecast(
    new_data    = testing(splits),
    actual_data = df
  ) %>%
  plot_modeltime_forecast(
    .legend_max_width = 25, # For mobile screens
    .interactive      = F
  )


# 5B - Obtenemos las métricas de evaluación de cada modelo

calibration_tbl %>%
  modeltime_accuracy() %>%
  table_modeltime_accuracy(
    .interactive = F
  )


# Paso 6 - Ajustamos o entrenamos el modelo ahora sobre todos los datos disponibles y hacemos una predicción sobre el futuro

refit_tbl <- calibration_tbl %>%
  modeltime_refit(data = df)

refit_tbl %>%
  modeltime_forecast(h = "7 days", actual_data = df) %>%
  plot_modeltime_forecast(
    .interactive      = F
  )


# Paso 7 - Elegimos el mejor modelo y hacemos la predicción para los próximo 7 días
final_model_tbl <- calibration_tbl %>%
  filter(.model_desc == 'LM') %>% 
  modeltime_refit(data = df)

final_model_tbl %>%
  modeltime_forecast(h = "7 days", actual_data = df) %>%
  plot_modeltime_forecast(
    .legend_max_width = 25, # For mobile screens
    .interactive      = F
  )

# Paso 8 - Combinamos los datos históricos con los estimados 

final_model_df <- final_model_tbl %>%
  modeltime_forecast(h = "7 days", actual_data = df) 

table(final_model_df$.model_desc)

final_model_df %>% 
  group_by(.model_desc) %>% 
  count()

# Paso 8 -  Con esto ya tenemos las predicciones para los próximos 7 días
forecast_df <- final_model_df %>% 
  filter(.model_desc == 'LM')


# Paso 9 - Calculamos la media de usuarios por hora para los días de semana y los fines de semana

forecast_df %>% 
  mutate(
    hour= hour(.index),
    week_day = wday(.index, label = F,week_start = 1),
    is_week_end = (week_day %in% c(6, 7))
  ) %>% 
  group_by(hour, is_week_end) %>% 
  summarise(users = sum(.value)) %>% 
  ungroup() -> result_df

result_df %>% 
  ggplot(aes(x=hour, y= users, fill=is_week_end)) + 
  geom_col(position = 'dodge') + 
  facet_wrap(vars(is_week_end ))


# Paso 10 - Seleccionamos las n mejores horas en la semana y los fines de semana con mayor número de usuarios
result_df %>% 
  group_by(is_week_end) %>%
  mutate(ranking = rank(-users)) %>% 
  arrange(is_week_end, ranking) %>% 
  filter(ranking <= 3)

# Comparamos esto con el resultado inicial




