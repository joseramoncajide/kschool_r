# install.packages('tidyverse')
# install.packages('maps')
library(tidyverse)
library(maps)


## ------------------------------------------------------------------------

# Cargamos el fichero de datos
flights <- read_csv(file = "05-Data-Wrangling/data/669307277_T_ONTIME.csv")

# explora
head(flights)
dim(flights)
# estructura del dataframe en con R
str(flights)

flights$...18 <- NULL

## ----results='hide'------------------------------------------------------
summary(flights)

barplot(table(flights$DAY_OF_MONTH))


## ------------------------------------------------------------------------
# dplyr 
# nota: , = AND
filter(flights, MONTH==12, DAY_OF_MONTH==31)

# nota: | = OR
filter(flights, CARRIER=="AA" | CARRIER=="UA")

## ----results='hide'------------------------------------------------------
filter(flights, CARRIER %in% c("AA", "UA"))

## ------------------------------------------------------------------------
# dplyr
select(flights, DEP_TIME, ARR_TIME, FL_NUM)

# Nota: `starts_with`, `ends_with`, y `matches` (para RegEx) buscan columnas por nombre
select(flights, YEAR:DAY_OF_MONTH, contains("DELAY"), matches("TIME$"))

## ----results='hide'------------------------------------------------------
# Anidamiento:
filter(select(flights, CARRIER, DEP_DELAY), DEP_DELAY > 60)

## ------------------------------------------------------------------------
# Encadenamiento:
flights %>%
    select(CARRIER, DEP_DELAY) %>%
    filter(DEP_DELAY > 60)


## ------------------------------------------------------------------------
# dplyr
flights %>%
    select(CARRIER, DEP_DELAY) %>%
    arrange(DEP_DELAY)

## ----results='hide'------------------------------------------------------
# nota: usar `desc` para descendente
flights %>%
    select(CARRIER, DEP_DELAY) %>%
    arrange(desc(DEP_DELAY))

## ------------------------------------------------------------------------
flights %>% 
  select(DISTANCE, AIR_TIME) %>%
  mutate(SPEED = DISTANCE/AIR_TIME*60)

# lo guardamos
flights <- flights %>% 
  mutate(SPEED = DISTANCE/AIR_TIME*60)

# ## summarise: Reducción de variables a valores
# 
# * Se usa principalmente tras una agrupación de datos
# * `group_by` crea los grupos sobre los que vamos a trabajar
# * `summarise` resume cada grupo

flights %>%
    group_by(DEST) %>%
    summarise(AVG_DELAY = mean(ARR_DELAY, na.rm=TRUE)) %>% 
  arrange(-AVG_DELAY)

## ------------------------------------------------------------------------
# media de vuelos cancelados o desviados por compañía
flights %>%
  group_by(CARRIER) %>%
  summarise(across(.cols = c(CANCELLED, DIVERTED), .fns = mean))

# retrasos máximos y mínimos de salida y llegada por cada compañia
flights %>%
    group_by(CARRIER) %>%
    summarise_each(funs(min(., na.rm=TRUE), max(., na.rm=TRUE)), matches("DELAY"))


# * `n()` nos dice el número de observaciones por grupo
# * `n_distinct(vector)` nos dice el número de elementos únicos que hay en un vector

## ------------------------------------------------------------------------
# Número de vuelos por cada día del mes ordenados descendentemente

flights %>%
  group_by(DAY_OF_MONTH) %>%
  summarise(total = n()) %>%
  ggplot(aes(x = factor(DAY_OF_MONTH), y = total)) + 
  geom_bar(stat = "identity") 

# número total de vuelos y número de aviones distintos que han volado a cada destino
flights %>%
    group_by(DEST) %>%
    summarise(total = n(), 
              aviones = n_distinct(TAIL_NUM)
              )

## ------------------------------------------------------------------------
# Calcular, para cada compañía, que dos días del mes que han tenido mayores retrasos en la salida
flights %>%
    group_by(CARRIER) %>%
    select(DAY_OF_MONTH, DEP_DELAY) %>%
    top_n(3) %>%
    arrange(CARRIER, desc(DEP_DELAY))

# Número de vuelos por mes y cambio respecto al dia anterior 
flights %>%
    group_by(DAY_OF_MONTH) %>%
    summarise(flight_count = n()) %>%
    mutate(change = flight_count - lag(flight_count, 7))


## ------------------------------------------------------------------------
#Cargamos un nuevo conjunto de datos
airports <- read_csv("05-Data-Wrangling/data/airports.csv")
airports

flights %>% 
  group_by(DEST) %>% 
  summarise(average_delay = mean(ARR_DELAY, na.rm = T)) %>% 
  inner_join(airports, by = c('DEST' = 'iata')) %>% 
  drop_na() -> result_df

result_df %>% 
  top_n(3,wt = average_delay) %>% 
  ggplot(aes(x=long, y = lat)) +
  borders("state") + 
  geom_point(aes(colour = average_delay), size = 2, alpha = 0.9) + 
  geom_text(aes(label=city, hjust=-.2), size=1.9) +
  coord_quickmap() +
  theme_light()
  

