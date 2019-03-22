
# http://dataiku.instantmagazine.com/white-papers-and-guidebooks/marketing-attribution-guidebook/what-markov-chain-model/

# install.packages("ChannelAttribution")
# install.packages("arules", dependencies=TRUE)


library(tidyverse)
library(ChannelAttribution)
library(arules)
library(arulesViz)


# Entendiendo el origen de los datos --------------------------------------

channel_data <- data.frame(client_id = sample(c(1:500),
                                              5000,
                                              replace = TRUE),
                           date = sample(c(1:32),
                                         5000,
                                         replace = TRUE),
                           channel = sample(c(0:4),
                                            5000,
                                            replace = TRUE,
                                            prob =  c(0.2, 0.3, 0.1, 0.15, 0.25)))

channel_data$date <- as.Date(channel_data$date, origin = "2016-01-01")
name_channel <- c("Social","Orgánico",
                  "Referencia", "SEM", "Directo")
channel_data$channel <- name_channel[channel_data$channel+1]

head(channel_data)

table(channel_data$channel)

# Lo que vemos en GA

channel_data <- channel_data %>%
  group_by(client_id) %>%
  arrange(date) %>% 
  summarise(path = paste(channel, collapse = ' > '),
            conversions = 1)

head(channel_data)


# Aplicación real ---------------------------------------------------------

rutas <- read_csv('data/rutas_conversion.csv')

head(rutas)
tail(rutas)

?heuristic_models

H <- heuristic_models(Data = rutas, 
                      var_path = "path",
                      var_conv = "total_conversions",
                      var_value="total_conversion_value") 

head(H)

M <- markov_model(Data = rutas, 
                  var_path = "path", 
                  var_conv = "total_conversions", 
                  var_value="total_conversion_value", 
                  out_more = T)

modelo_markov <- M$result
matriz_de_transicion <- M$transition_matrix

# El cambio en la probabilidad de lograr una conversion si eliminamos un canal del grafo 

head(modelo_markov)


library(tidyverse)
modelos <- full_join(H, modelo_markov)

# Ejercicio: comprobad que la suma de conversiones e importe de las conversiones es la misma para todos los canales

modelos %>% 
  summarise(tot_modelo = sum(total_conversion_value), 
            tot_first = sum(first_touch_value))

modelos %>% 
  select(-channel_name) %>% 
  summarise_all(funs(sum))



# Gráfico de conversiones -------------------------------------------------


conversiones <- modelos %>% 
  select(channel_name, ends_with('_conversions')) %>% 
  gather(key = 'model', value = "y", -channel_name) %>% 
  mutate(y = round(y,2))


conversiones %>% ggplot(aes(reorder(channel_name, y), y, fill = model)) +
  geom_col(position = 'dodge', show.legend=F) +
  scale_y_continuous(labels=function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE)) +
  labs(title = "Comparativas de modelos") + 
  labs(y = "Conversiones") +
  labs(x = "Agrupación de canales") +
  coord_flip() +
  theme_light()

# Ejercicio: Hacer lo mismo para el valor de las conversiones




# Matriz de transición ----------------------------------------------------

head(matriz_de_transicion)


ggplot(matriz_de_transicion, aes(y = channel_from, x = channel_to, fill = transition_probability)) +
  theme_minimal() +
  geom_tile(colour = "white", width = .9, height = .9) +
  geom_text(aes(label = round(transition_probability, 2)), fontface = "bold", size = 3, color = 'white') +
  theme(legend.position = 'bottom',
        legend.direction = "horizontal",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title = element_text(size = 20, face = "bold", vjust = 2, color = 'black', lineheight = 0.8),
        axis.title.x = element_text(size = 24, face = "bold"),
        axis.title.y = element_text(size = 24, face = "bold"),
        axis.text.y = element_text(size = 8, face = "bold", color = 'black'),
        axis.text.x = element_text(size = 8, angle = 90, hjust = 0.5, vjust = 0.5, face = "plain")) +
  ggtitle("Transition matrix heatmap")



# REGLAS DE ASOCIACION ----------------------------------------------------

# https://es.wikipedia.org/wiki/Reglas_de_asociaci%C3%B3n



items <- strsplit(as.character(rutas$path), " > ")

txn <- as(items,"transactions")
summary(txn)
sizes <- size(txn)

itemFrequency(txn, type="absolute")
itemFrequencyPlot(txn, topN=10, type="absolute", main="Combinaciones más frequentes de canales")
itemFrequencyPlot(txn, topN=10, type="relative", main="Combinaciones más frequentes de canales")

# support: numero de conversiones en los que aparece el canal / total de rutas de conversion

rules <- apriori (txn, parameter = list(supp = 0.1, conf = .5, minlen= 2))

# lift > 1 indica que ese conjunto aparece una cantidad de veces superior a lo esperado bajo condiciones de independencia 
# lift < 1 indica que ese conjunto aparece una cantidad de veces inferior a lo esperado bajo condiciones de independencia
rules <- sort (rules, by="lift", decreasing=TRUE) # 'high-lift' rules.
inspect(rules)


plot(rules, method="graph", control=list(type="items"))

plot(rules, method="paracoord", control=list(reorder=TRUE))



