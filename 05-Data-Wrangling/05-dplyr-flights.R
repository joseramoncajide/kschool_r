## ------------------------------------------------------------------------
# Cargamos la librerías necesarias
list.of.packages <- c("tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

## ------------------------------------------------------------------------

suppressMessages(library(dplyr))
library(ggplot2)

# Cargamos el fichero de datos
flights <- read_csv("05-Data-Wrangling/data/669307277_T_ONTIME.csv.zip")

print(object.size(get('flights')), units='auto')


# explora
head(flights)

dim(flights)


# estructura del dataframe en con R
str(flights)

# con dplyr
glimpse(flights)

flights$X18 <- NULL



## ----results='hide'------------------------------------------------------
# Para ver más filas
print(flights, n=20)

# Y si queremos ver todas las variables
data.frame(head(flights))

## ----results='hide'------------------------------------------------------
# Vuelos del 31/12/2015
flights
str(flights)

barplot(table(flights$DAY_OF_MONTH))


## ------------------------------------------------------------------------
# dplyr 
# nota: , = AND
filter(flights, MONTH==12, DAY_OF_MONTH==31)

# nota: | = OR
filter(flights, CARRIER=="AA" | CARRIER=="UA")

## ----results='hide'------------------------------------------------------
filter(flights, CARRIER %in% c("AA", "UA"))

## ----results='hide'------------------------------------------------------
# base R
flights[, c("DEP_TIME", "ARR_TIME", "FL_NUM")]

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

## ----results='hide'------------------------------------------------------
# base R 
flights[order(flights$DEP_DELAY), c("CARRIER", "DEP_DELAY")]

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

## ----results='hide'------------------------------------------------------
# base R: Nueva variable SPEED (en mph)
flights$SPEED <- flights$DISTANCE / flights$AIR_TIME*60
flights[, c("DISTANCE", "AIR_TIME", "SPEED")]

## ------------------------------------------------------------------------
# dplyr: comprobamos que es correcto
flights %>% select(DISTANCE, AIR_TIME) %>%
  mutate(SPEED = DISTANCE/AIR_TIME*60)

# lo guardamos
flights %>% mutate(SPEED = DISTANCE/AIR_TIME*60)

## ----results='hide'------------------------------------------------------
# base R: retraso medio por destino
head(with(flights, tapply(ARR_DELAY, DEST, mean, na.rm=TRUE)))
head(aggregate(ARR_DELAY ~ DEST, flights, mean))

## ------------------------------------------------------------------------
# dplyr:
flights %>%
    group_by(DEST) %>%
    summarise(AVG_DELAY = mean(ARR_DELAY, na.rm=TRUE))

## ------------------------------------------------------------------------
# media de vuelos cancelados o desviados por compañía
flights %>%
    group_by(CARRIER) %>%
    summarise_each(funs(mean), CANCELLED, DIVERTED)

# retrasos máximos y mínimos de salida y llegada por cada compañia
flights %>%
    group_by(CARRIER) %>%
    summarise_each(funs(min(., na.rm=TRUE), max(., na.rm=TRUE)), matches("DELAY"))


## ------------------------------------------------------------------------
# Número de vuelos por cada día del mes ordenados descendentemente
barplot(table(flights$DAY_OF_MONTH))

flights %>%
    group_by(DAY_OF_MONTH) %>%
    summarise(total = n()) %>%
    arrange(desc(total)) %>% ggplot(aes(x = factor(DAY_OF_MONTH), y = total)) + geom_bar(stat = "identity") 
# más simple
flights %>%
    group_by(DAY_OF_MONTH) %>%
    tally(sort = TRUE)

# número total de vuelos y número de aviones distintos que han volado a cada destino
flights %>%
    group_by(DEST) %>%
    summarise(total = n(), aviones = n_distinct(TAIL_NUM))

## ------------------------------------------------------------------------
# número total de vuelos cancelados y no cancelados por destino
flights %>%
    group_by(DEST) %>%
    select(CANCELLED) %>%
    table() %>%
    head()


## ----results='hide'------------------------------------------------------
# Calcular, para cada compañía, que dos días del mes han tenido mayores retrasos en la salida
# Nota: al valor más pequeño, ranked le asigna un 1, por lo qye habrá que ordenar descendentemente DEP_DELAY para hacer un rank por el valor más grande
flights %>%
    group_by(CARRIER) %>%
    select(DAY_OF_MONTH, DEP_DELAY) %>%
    filter(min_rank(desc(DEP_DELAY)) <= 2) %>%
    arrange(CARRIER, desc(DEP_DELAY))

## ------------------------------------------------------------------------
# más simple con `top_n`
flights %>%
    group_by(CARRIER) %>%
    select(MONTH, DAY_OF_MONTH, DEP_DELAY) %>%
    top_n(2) %>%
    arrange(CARRIER, desc(DEP_DELAY))

# Número de vuelos por mes y cambio respecto al dia anterior 
flights %>%
    group_by(DAY_OF_MONTH) %>%
    summarise(flight_count = n()) %>%
    mutate(change = flight_count - lag(flight_count))

# delta

pct <- function(x) {x/lag(x)}

flights %>%
    group_by(DAY_OF_MONTH) %>%
    summarise(flight_count = n()) %>%
    mutate_each(funs(pct), flight_count)

## ------------------------------------------------------------------------
# muestra aleatoria sin reemplazo
flights %>% sample_n(5)

# muestra aleatoria con reemplazo
flights %>% sample_frac(0.25, replace=TRUE)



## ------------------------------------------------------------------------
#Cargamos un nuevo conjunot de datos
airports <- read_csv("data/airports.csv")
airports

location <- airports %>% 
  select(DEST = iata, name = airport, lat, long)
location

delays <- flights %>%
  group_by(DEST) %>%
  summarise(ARR_DELAY = mean(ARR_DELAY, na.rm = TRUE), n = n()) %>%
  arrange(desc(ARR_DELAY)) %>%
  inner_join(location)


ggplot(delays, aes(long, lat)) + 
  borders("state") + 
  geom_point(aes(colour = ARR_DELAY), size = 5, alpha = 0.9) + 
  scale_colour_gradient2() +
  coord_quickmap()

delays <- delays %>% filter(ARR_DELAY < 0)


